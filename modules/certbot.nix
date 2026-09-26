# Wires certbot + the certbot-dns-luadns plugin (pkgs/python/certbot-dns-luadns.nix)
# into a renewal timer that keeps existing certs renewed — launchd on darwin,
# systemd on nixos.
#
# nix-darwin has no `services.certbot` (that's NixOS-only), so renewal is a
# plain `certbot renew` on a timer instead of a fully declarative cert block.
# `renew` is idempotent and needs no domain argument — it just re-processes
# whatever's already under /etc/letsencrypt/renewal, so the schedule below
# works unconditionally, before any cert has ever been issued.
#
# Declarative issuance: set `local.certbot.fqdns` and `local.certbot.email`
# on the host. A boot-time service issues any listed FQDN not yet present
# under /etc/letsencrypt/renewal, then the renewal timer takes over. Issuance
# is idempotent — already-present lineages are skipped every boot.
#
# Manual issuance still works if preferred:
#   certbot certonly --dns-luadns \
#     --dns-luadns-credentials /run/agenix/certbot-luadns \
#     -d example.com
#
# /etc/letsencrypt/archive/<lineage> is 0700 root:root (0700 root:wheel on
# darwin), so no non-root service (e.g. home-manager's syncthing, running as
# the user) can read the key material there even from a chown'd copy of just
# the files -- the directory itself blocks traversal. Rather than loosen
# certbot's own directory perms (which it may reset on a future renewal),
# each platform's deploy-hook below copies each renewed lineage out to
# /etc/letsencrypt-certs/<lineage> instead: 0400 owned by the host's primary
# user on darwin, 0440 owned by a dedicated group on nixos (no single
# "primary user" concept there). Consumers (see
# modules/syncthing/syncthing.nix) read certs from there, not from
# /etc/letsencrypt directly. This only runs on an actual renewal, so after
# the very first issuance (manual or via local.certbot.fqdns), run the same
# copy once by hand before anything can read the cert.
{ den, inputs, ... }: {
  den.aspects.certbot = {
    # ragenix + the nix-secrets input are wired in by modules/base/secrets.nix
    includes = [ den.aspects.secrets ];

    darwin =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        cfg = config.local.certbot;

        certbotWithPlugins = pkgs.certbot.withPlugins (cp: [
          (cp.callPackage ../pkgs/python/certbot-dns-luadns.nix { })
        ]);

        deployHook = pkgs.writeShellApplication {
          name = "certbot-deploy-copy-for-user";
          runtimeInputs = [ pkgs.coreutils ];
          text = ''
            target_user=${lib.escapeShellArg config.system.primaryUser}
            lineage="$(basename "$RENEWED_LINEAGE")"
            dest="/etc/letsencrypt-certs/$lineage"
            install -d -m 0755 /etc/letsencrypt-certs
            install -d -o "$target_user" -m 0700 "$dest"
            install -o "$target_user" -m 0400 "$RENEWED_LINEAGE/fullchain.pem" "$dest/fullchain.pem"
            install -o "$target_user" -m 0400 "$RENEWED_LINEAGE/privkey.pem" "$dest/privkey.pem"
          '';
        };

        # FQDNs are passed as "$@" so the script is valid even when the list
        # is empty (it's only instantiated as a daemon when fqdns != []).
        issueScript = pkgs.writeShellApplication {
          name = "certbot-issue-certs";
          runtimeInputs = [
            certbotWithPlugins
            pkgs.coreutils
          ];
          text = ''
            credentials=${lib.escapeShellArg config.age.secrets.certbot-luadns.path}
            for fqdn in "$@"; do
              if [[ ! -f "/etc/letsencrypt/renewal/$fqdn.conf" ]]; then
                certbot certonly \
                  --dns-luadns \
                  --dns-luadns-credentials "$credentials" \
                  --non-interactive \
                  --agree-tos \
                  --email ${lib.escapeShellArg cfg.email} \
                  --deploy-hook ${lib.getExe deployHook} \
                  -d "$fqdn"
              fi
            done
          '';
        };
      in
      {
        options.local.certbot = {
          email = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "ACME registration email. Required when fqdns is non-empty.";
          };
          fqdns = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "FQDNs to issue certificates for on first boot. Ongoing renewals are automatic.";
          };
        };

        config = {
          age.secrets.certbot-luadns.file = "${inputs.nix-secrets}/services/certbot-luadns.age";

          environment.systemPackages = [ certbotWithPlugins ];

          launchd.daemons.certbot-renew = {
            command = "${certbotWithPlugins}/bin/certbot renew --non-interactive --deploy-hook ${lib.getExe deployHook}";
            serviceConfig = {
              StartInterval = 60 * 60 * 24 * 30; # every 30 days
              StandardOutPath = "/var/log/certbot-renew.log";
              StandardErrorPath = "/var/log/certbot-renew.log";
            };
          };

          launchd.daemons.certbot-issue = lib.mkIf (cfg.fqdns != [ ]) {
            serviceConfig = {
              ProgramArguments = [ (lib.getExe issueScript) ] ++ cfg.fqdns;
              RunAtLoad = true;
              StandardOutPath = "/var/log/certbot-issue.log";
              StandardErrorPath = "/var/log/certbot-issue.log";
            };
          };
        };
      };

    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        cfg = config.local.certbot;

        certbotWithPlugins = pkgs.certbot.withPlugins (cp: [
          (cp.callPackage ../pkgs/python/certbot-dns-luadns.nix { })
        ]);

        # NixOS has no nix-darwin-style single "primary user", so grant read
        # access via a dedicated group instead of chowning to one account.
        certReaders = lib.attrNames (lib.filterAttrs (_: u: u.isNormalUser or false) config.users.users);

        deployHook = pkgs.writeShellApplication {
          name = "certbot-deploy-copy-for-user";
          runtimeInputs = [ pkgs.coreutils ];
          text = ''
            lineage="$(basename "$RENEWED_LINEAGE")"
            dest="/etc/letsencrypt-certs/$lineage"
            install -d -m 0755 /etc/letsencrypt-certs
            install -d -g cert-readers -m 0750 "$dest"
            install -g cert-readers -m 0440 "$RENEWED_LINEAGE/fullchain.pem" "$dest/fullchain.pem"
            install -g cert-readers -m 0440 "$RENEWED_LINEAGE/privkey.pem" "$dest/privkey.pem"
          '';
        };

        issueScript = pkgs.writeShellApplication {
          name = "certbot-issue-certs";
          runtimeInputs = [
            certbotWithPlugins
            pkgs.coreutils
          ];
          text = ''
            credentials=${lib.escapeShellArg config.age.secrets.certbot-luadns.path}
            for fqdn in "$@"; do
              if [[ ! -f "/etc/letsencrypt/renewal/$fqdn.conf" ]]; then
                certbot certonly \
                  --dns-luadns \
                  --dns-luadns-credentials "$credentials" \
                  --non-interactive \
                  --agree-tos \
                  --email ${lib.escapeShellArg cfg.email} \
                  --deploy-hook ${lib.getExe deployHook} \
                  -d "$fqdn"
              fi
            done
          '';
        };
      in
      {
        options.local.certbot = {
          email = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "ACME registration email. Required when fqdns is non-empty.";
          };
          fqdns = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = "FQDNs to issue certificates for on first boot. Ongoing renewals are automatic.";
          };
        };

        config = {
          age.secrets.certbot-luadns.file = "${inputs.nix-secrets}/services/certbot-luadns.age";

          environment.systemPackages = [ certbotWithPlugins ];

          users.groups.cert-readers.members = certReaders;

          systemd.services.certbot-renew = {
            description = "Renew certbot certificates";
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${certbotWithPlugins}/bin/certbot renew --non-interactive --deploy-hook ${lib.getExe deployHook}";
            };
          };

          systemd.timers.certbot-renew = {
            description = "Renew certbot certificates every 30 days";
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnBootSec = "10m";
              OnUnitActiveSec = "30d";
              Persistent = true;
            };
          };

          systemd.services.certbot-issue = lib.mkIf (cfg.fqdns != [ ]) {
            description = "Issue certbot certificates for declared FQDNs";
            after = [ "network-online.target" ];
            wants = [ "network-online.target" ];
            wantedBy = [ "multi-user.target" ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
              ExecStart = "${lib.getExe issueScript} ${lib.concatStringsSep " " cfg.fqdns}";
            };
          };
        };
      };
  };
}
