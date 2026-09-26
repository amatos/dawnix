# Points a host's Postfix at the LAN smart mail relay (smtp.home.matos.cc)
# instead of delivering mail directly, so cron/launchd job failures, `mail`,
# etc. all funnel through one outbound relay.
#
# Connects via SMTPS (implicit TLS, port 465) and verifies the relay's
# certificate against this host's own certbot-issued chain — the relay's
# cert and every host's cert come from the same Let's Encrypt/LuaDNS
# pipeline (modules/certbot), so that chain is sufficient to validate it.
#
# nixos ships no MTA by default, so it needs `services.postfix.enable`.
# darwin already ships Postfix; it's configured in place with `postconf -e`
# rather than replacing main.cf wholesale, so Apple's stock defaults survive.
#
# This aspect is meant to be included fleet-wide (see modules/base/default.nix)
# and excluded on whichever host is the relay itself — see the `excludes` on
# den.aspects.huginn in modules/hosts/huginn.nix.
{ den, ... }:
let
  relayHost = "smtp.home.matos.cc";
  relayPort = 465;

  certDir = hostname: "/etc/letsencrypt/live/${hostname}.home.matos.cc";
in
{
  den.aspects.smtp-relay-client = {
    includes = [ den.aspects.certbot ];

    nixos =
      { config, ... }:
      {
        services.postfix = {
          enable = true;
          settings.main = {
            relayhost = [ "[${relayHost}]:${toString relayPort}" ];
            smtp_tls_wrappermode = true;
            smtp_tls_security_level = "verify";
            smtp_tls_CAfile = "${certDir config.networking.hostName}/chain.pem";
          };
        };
      };

    darwin =
      { config, ... }:
      {
        system.activationScripts.postActivation.text = ''
          echo "smtp-relay-client: pointing postfix at ${relayHost}..." >&2
          /usr/sbin/postconf -e \
            'relayhost = [${relayHost}]:${toString relayPort}' \
            'smtp_tls_wrappermode = yes' \
            'smtp_tls_security_level = verify' \
            'smtp_tls_CAfile = ${certDir config.networking.hostName}/chain.pem'
          if /usr/sbin/postfix status >/dev/null 2>&1; then
            /usr/sbin/postfix reload
          else
            /usr/sbin/postfix start
          fi
        '';
      };
  };
}
