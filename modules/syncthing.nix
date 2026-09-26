{ den, inputs, ... }:
{
  den.aspects.syncthing = {
    includes = [ den.aspects.secrets ];

    nixos = { pkgs, ... }: {
      environment.systemPackages = [
        pkgs.syncthing
      ];
      networking.firewall = {
        allowedTCPPorts = [ 22000 ];
        allowedUDPPorts = [
          21027
          22000
        ];
        extraInputRules = ''
          ip  saddr 10.0.4.0/22 tcp dport 8384 accept
        '';
      };
    };

    darwin = { pkgs, ... }: {
      environment.systemPackages = [
        pkgs.syncthing-macos
      ];
    };

    homeManager =
      {
        config,
        lib,
        pkgs,
        osConfig,
        ...
      }:
      let
        # certbot issues one SAN cert per host, `-d <host>.home.matos.cc [-d
        # <host>.ts.matos.cc]`; certbot's lineage directory always takes the
        # name of the first -d domain, so it's always .home.matos.cc here
        # even though tailscale (always on via the base aspect) also puts
        # <host>.ts.matos.cc on the cert.
        #
        # Read from the letsencrypt-certs copy, not /etc/letsencrypt/live
        # directly: the live/archive directories are 0700 root:root, so this
        # user-level service can't read them. See the certbot deploy-hook in
        # modules/certbot/default.nix, which keeps this copy in sync.
        certDir = "/etc/letsencrypt-certs/${osConfig.networking.hostName}.home.matos.cc";

        guiAddress = config.services.syncthing.guiAddress;

        # Mirrors home-manager's own syncthing module's config-dir lookup, so
        # this finds the same config.xml that module manages.
        syncthingDirShell =
          if pkgs.stdenv.hostPlatform.isDarwin then
            ''syncthing_dir="$HOME/Library/Application Support/Syncthing"''
          else
            ''
              syncthing_state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/syncthing"
              syncthing_config_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/syncthing"
              if [[ -e "$syncthing_state_dir/config.xml" || ! -e "$syncthing_config_dir/config.xml" ]]; then
                  syncthing_dir="$syncthing_state_dir"
              else
                  syncthing_dir="$syncthing_config_dir"
              fi
            '';

        # Sets the syncthing GUI username/password from agenix secrets at
        # activation time. Bypasses `services.syncthing.guiCredentials`
        # because that option types `username` as a literal Nix string, which
        # home-manager always bakes into the world-readable store regardless
        # of where the value came from -- there's no way to make it come from
        # a secret decrypted only at activation, the way `passwordFile`
        # already does. So both credentials go through the same runtime path
        # instead, read straight from the agenix-decrypted files.
        setGuiCredentials = pkgs.writeShellApplication {
          name = "syncthing-set-gui-credentials";
          runtimeInputs = [
            pkgs.curl
            pkgs.jq
            pkgs.libxml2
            pkgs.mkpasswd
          ];
          text = ''
            ${syncthingDirShell}

            # Not escaped: on darwin, agenix's default secretsDir embeds a
            # `$(getconf ...)` command substitution meant to be evaluated by
            # this shell, not a literal path -- see agenix's homeManagerModules
            # age-home.nix `userDirectory`.
            until [[ -r "${config.age.secrets.syncthing-gui-userid.path}" \
                  && -r "${config.age.secrets.syncthing-gui-password.path}" ]]; do
              sleep 1
            done
            username="$(cat "${config.age.secrets.syncthing-gui-userid.path}")"
            password="$(cat "${config.age.secrets.syncthing-gui-password.path}")"

            api_key=""
            until [[ -n "$api_key" ]]; do
              api_key="$(xmllint --xpath 'string(configuration/gui/apikey)' "$syncthing_dir/config.xml" 2>/dev/null || true)"
              [[ -n "$api_key" ]] || sleep 1
            done

            _curl() {
              curl -sSLk -H "X-API-Key: $api_key" --retry 1000 --retry-delay 1 --retry-all-errors "$@"
            }

            current="$(_curl "${guiAddress}/rest/config/gui")"
            current_username="$(jq -r .user <<<"$current")"
            current_password="$(jq -r .password <<<"$current")"

            if [[ "$current_username" != "$username" ]]; then
              jq -n --arg username "$username" '{user: $username}' \
                | _curl --json @- -X PATCH "${guiAddress}/rest/config/gui"
            fi

            if [[ -z "$current_password" ]] \
                || { [[ "$current_password" != "$password" ]] \
                     && ! mkpasswd --stdin --salt "$current_password" <<<"$password" &>/dev/null; }; then
              jq -n --arg password "$password" '{password: $password}' \
                | _curl --json @- -X PATCH "${guiAddress}/rest/config/gui"
            fi

            if jq -e .requiresRestart <<<"$(_curl "${guiAddress}/rest/config/restart-required")" >/dev/null; then
              _curl -X POST "${guiAddress}/rest/system/restart"
            fi
          '';
        };
      in
      {
        age.secrets.syncthing-gui-userid.file = "${inputs.nix-secrets}/services/syncthing-gui-userid.age";
        age.secrets.syncthing-gui-password.file = "${inputs.nix-secrets}/services/syncthing-gui-password.age";

        services.syncthing = {
          # Disabled on darwin: syncthing-macos.app runs its own daemon
          # there (see the comment on `copyCerts` above), so home-manager's
          # `cert`/`key` distribution below only takes effect on nixos --
          # `syncthing-copy-certs` covers darwin instead.
          enable = !pkgs.stdenv.hostPlatform.isDarwin;
          cert = "${certDir}/fullchain.pem";
          key = "${certDir}/privkey.pem";
        };

        systemd.user.services.syncthing-gui-credentials = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
          Unit = {
            Description = "Set Syncthing GUI credentials from agenix secrets";
            After = [
              "syncthing.service"
              "agenix.service"
            ];
          };
          Service = {
            Type = "oneshot";
            ExecStart = lib.getExe setGuiCredentials;
            RemainAfterExit = true;
          };
          Install.WantedBy = [ "default.target" ];
        };

        launchd.agents.syncthing-gui-credentials = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
          enable = true;
          config = {
            ProgramArguments = [ (lib.getExe setGuiCredentials) ];
            RunAtLoad = true;
            ProcessType = "Background";
            StandardOutPath = "${config.home.homeDirectory}/Library/Logs/Syncthing/syncthing-gui-credentials-stdout.log";
            StandardErrorPath = "${config.home.homeDirectory}/Library/Logs/Syncthing/syncthing-gui-credentials-stderr.log";
          };
        };
      };
  };
}
