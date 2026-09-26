# Dynamic DNS updater for LuaDNS, using LuaDNS's own dyndns2-protocol
# endpoint (https://www.luadns.com/dyndns.html) rather than the full REST
# API.
#
# Every `interval` seconds, a root-owned oneshot job:
#   1. reads this host's current public IP from an HTTPS IP-echo service
#      (no gateway/router API assumed — unlike a fleet of UniFi-fronted
#      boxes, dawnix hosts can be anywhere)
#   2. compares it to the last IP recorded in the module's state file
#   3. if changed, calls LuaDNS's dyndns2 endpoint over HTTPS
#      (https://app.luadns.com/nic/update) to update the A record, using
#      the email+token pair from the dyndns-luadns age secret
#
# The target hostname's A (and/or AAAA) record must already exist in LuaDNS
# before including this aspect — the dyndns2 protocol updates existing
# records, it does not create them.
#
# Usage — on a host:
#   den.aspects.<host> = {
#     includes = [ den.aspects.dyndns-luadns ];
#     nixos.local.dyndnsLuadns.hostname = "home.matos.cc"; # or `darwin.local...`
#   };
{ den, inputs, ... }:
let
  stateFileName = "current-ip";

  mkRunScript =
    {
      pkgs,
      lib,
      stateDir,
      credentialsPath,
      hostname,
      ipLookupUrl,
    }:
    pkgs.writeShellScript "dyndns-luadns-run" ''
      set -euo pipefail

      luadnsEmail=$(sed -n 's/^dns_luadns_email *= *//p' ${lib.escapeShellArg credentialsPath} | tr -d '[:space:]')
      luadnsToken=$(sed -n 's/^dns_luadns_token *= *//p' ${lib.escapeShellArg credentialsPath} | tr -d '[:space:]')
      if [ -z "$luadnsEmail" ] || [ -z "$luadnsToken" ]; then
        echo "dyndns-luadns: could not read dns_luadns_email/dns_luadns_token from ${credentialsPath}" >&2
        exit 1
      fi

      currentIp=$(${pkgs.curl}/bin/curl -fsS "${ipLookupUrl}" | tr -d '[:space:]')
      if ! printf '%s' "$currentIp" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'; then
        echo "dyndns-luadns: could not parse a public IPv4 address from ${ipLookupUrl}: $currentIp" >&2
        exit 1
      fi

      install -d -m 0700 ${lib.escapeShellArg stateDir}
      stateFile=${lib.escapeShellArg "${stateDir}/${stateFileName}"}

      lastIp=""
      if [ -f "$stateFile" ]; then
        lastIp=$(cat "$stateFile")
      fi

      if [ "$currentIp" = "$lastIp" ]; then
        echo "dyndns-luadns: public IP unchanged ($currentIp)"
        exit 0
      fi

      echo "dyndns-luadns: public IP changed (''${lastIp:-none} -> $currentIp), updating LuaDNS"

      # dyndns2 update — HTTPS only (LuaDNS does not support plain HTTP here).
      # No -f: dyndns2 servers report failures (badauth, abuse, 911, ...) as a
      # 200 response with a status body, not a non-2xx HTTP status.
      response=$(${pkgs.curl}/bin/curl -sS \
        -u "$luadnsEmail:$luadnsToken" \
        "https://app.luadns.com/nic/update?hostname=${hostname}&myip=$currentIp")

      # LuaDNS replies with just the status word (e.g. "good"), not the
      # "good <ip>" form some other dyndns2 servers use — match on the first
      # word only so either form works.
      case "''${response%% *}" in
        good|nochg)
          printf '%s' "$currentIp" > "$stateFile"
          echo "dyndns-luadns: LuaDNS update result: $response"
          ;;
        *)
          echo "dyndns-luadns: LuaDNS update FAILED: $response" >&2
          exit 1
          ;;
      esac
    '';

  mkOptions = lib: {
    hostname = lib.mkOption {
      type = lib.types.str;
      example = "home.matos.cc";
      description = ''
        LuaDNS-hosted hostname to keep pointed at this host's current
        public IP. The A record must already exist in the zone — dyndns2
        updates it, it does not create it.
      '';
    };

    ipLookupUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://ipv4.icanhazip.com";
      description = ''
        HTTPS URL that echoes back this host's public IPv4 address as
        plain text, used in place of a gateway/router API.
      '';
    };

    interval = lib.mkOption {
      type = lib.types.ints.positive;
      default = 3600; # 1 hour
      description = "How often, in seconds, to check the public IP for changes.";
    };
  };
in
{
  den.aspects.dyndns-luadns = {
    includes = [ den.aspects.secrets ];

    nixos =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        cfg = config.local.dyndnsLuadns;
        stateDir = "/var/lib/dyndns-luadns";
      in
      {
        options.local.dyndnsLuadns = mkOptions lib;

        config = {
          age.secrets.dyndns-luadns.file = "${inputs.nix-secrets}/services/dyndns-luadns.age";

          systemd.services.dyndns-luadns = {
            description = "LuaDNS dyndns2 update for ${cfg.hostname}";
            after = [ "network-online.target" ];
            wants = [ "network-online.target" ];
            serviceConfig = {
              Type = "oneshot";
              User = "root";
              ExecStart = mkRunScript {
                inherit pkgs lib stateDir;
                credentialsPath = config.age.secrets.dyndns-luadns.path;
                inherit (cfg) hostname ipLookupUrl;
              };
              PrivateTmp = true;
              ProtectSystem = "strict";
              ReadWritePaths = [ stateDir ];
            };
          };

          systemd.timers.dyndns-luadns = {
            description = "LuaDNS dyndns2 update timer";
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnBootSec = "2min";
              OnUnitInactiveSec = toString cfg.interval;
              Persistent = true;
            };
          };
        };
      };

    darwin =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      let
        cfg = config.local.dyndnsLuadns;
        stateDir = "/var/db/dyndns-luadns";
      in
      {
        options.local.dyndnsLuadns = mkOptions lib;

        config = {
          age.secrets.dyndns-luadns.file = "${inputs.nix-secrets}/services/dyndns-luadns.age";

          launchd.daemons.dyndns-luadns = {
            command = "${mkRunScript {
              inherit pkgs lib stateDir;
              credentialsPath = config.age.secrets.dyndns-luadns.path;
              inherit (cfg) hostname ipLookupUrl;
            }}";
            serviceConfig = {
              RunAtLoad = true;
              StartInterval = cfg.interval;
              StandardOutPath = "/var/log/dyndns-luadns.log";
              StandardErrorPath = "/var/log/dyndns-luadns.log";
            };
          };
        };
      };
  };
}
