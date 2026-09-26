# Postfix "smarthost": the one host in the fleet that actually holds outbound
# mail credentials. Listens on SMTPS (port 465, implicit TLS) for mail from
# other hosts on the local networks — LAN and the tailnet (tailscale0) — and
# relays it out through Fastmail (smtp.fastmail.com:587) using SASL auth.
#
# Every other host's local postfix points at this one instead of delivering
# mail itself — see modules/smtp-relay-client.nix. Meant to be included only
# on the host that IS the smarthost (huginn); see the `excludes` on
# den.aspects.huginn in modules/hosts/huginn.nix, which drops the fleet-wide
# smtp-relay-client inclusion there so huginn doesn't try to relay through
# itself.
#
# TLS listener cert comes from modules/certbot's deploy-hook copy at
# /etc/letsencrypt-certs/<hostname>.home.matos.cc/ (0440, group cert-readers) —
# not /etc/letsencrypt/live directly, which is 0700 root:root and unreadable
# by the postfix service user. See modules/certbot/default.nix and
# modules/syncthing/syncthing.nix, which reads its own cert the same way.
#
# nixos ships no MTA by default, so this needs `services.postfix.enable`.
{ den, inputs, ... }:
let
  relayHost = "smtp.fastmail.com";
  relayPort = 587;

  # Networks allowed to relay through this host without SASL auth of their
  # own: loopback, the LAN, and the Tailscale CGNAT range (covers every peer
  # reachable over tailscale0, without hardcoding a single tailnet address).
  myNetworks = [
    "127.0.0.0/8"
    "[::1]/128"
    "10.0.4.0/22"
    "100.64.0.0/10" # Tailscale CGNAT
  ];

  certDir = hostname: "/etc/letsencrypt-certs/${hostname}.home.matos.cc";
in
{
  den.aspects.smtp-relay-smarthost = {
    includes = [ den.aspects.certbot ];

    nixos =
      { config, ... }:
      let
        saslSecretPath = config.age.secrets.smtp-relay-sasl-fastmail.path;
      in
      {
        # Postfix passwd map: `[smtp.fastmail.com]:587 user@example.com:app-password`
        age.secrets.smtp-relay-sasl-fastmail.file = "${inputs.nix-secrets}/services/smtp-relay-sasl-fastmail.age";

        # Lets the postfix service user read the certbot-deployed TLS cert
        # copy (see module header). certbot/default.nix also populates this
        # group's membership from normal users; list-typed options merge
        # across modules, so this just adds postfix to it.
        users.groups.cert-readers.members = [ "postfix" ];

        # Fastmail rejects senders whose address isn't fully-qualified (e.g.
        # "user@huginn" from a mail client that builds From straight off
        # gethostname()). This rewrites the bare-hostname domain to the LAN
        # FQDN on outbound mail, regardless of what produced the address.
        # "@<host>" as a generic(5) key matches any local-part in that
        # domain. texthash: needs no postmap run.
        #
        # Kept outside /etc/postfix/ — NixOS's postfix module manages that
        # whole directory as a bind-mount, so environment.etc can't inject a
        # single extra file into it.
        environment.etc."postfix-generic-map".text = ''
          @${config.networking.hostName} ${config.networking.hostName}.home.matos.cc
        '';

        networking.firewall = {
          enable = true;
          interfaces."tailscale0".allowedTCPPorts = [ 465 ];
          extraInputRules = ''
            ip  saddr 10.0.4.0/22 tcp dport 465  accept
            ip  saddr 10.0.4.0/22 tcp dport 25   accept
          '';
        };

        services.postfix = {
          enable = true;

          # Only the implicit-TLS SMTPS listener (465) — no plaintext SMTP-25
          # or explicit-TLS submission-587 listener.
          enableSmtp = false;
          enableSubmissions = true;
          submissionsOptions = {
            # Local-network senders are already trusted via mynetworks below;
            # no SASL auth required from them (that's for the outbound leg
            # to Fastmail, configured separately).
            smtpd_client_restrictions = "permit_mynetworks,reject";
          };

          settings.main = {
            myhostname = "${config.networking.hostName}.home.matos.cc";
            smtp_generic_maps = "texthash:/etc/postfix-generic-map";

            inet_interfaces = "all";
            inet_protocols = "all";
            mynetworks = myNetworks;

            relayhost = [ "[${relayHost}]:${toString relayPort}" ];

            # This host relays only — no local mailbox delivery.
            mydestination = "";
            local_transport = "error:local delivery disabled";

            # SASL auth to Fastmail on the outbound leg.
            smtp_sasl_auth_enable = true;
            smtp_sasl_password_maps = "texthash:${saslSecretPath}";
            smtp_sasl_security_options = "noanonymous";
            smtp_sasl_type = "cyrus"; # nixpkgs builds Postfix with --with-cyrus-sasl
            smtp_tls_security_level = "encrypt";

            smtpd_tls_chain_files = [
              "${certDir config.networking.hostName}/privkey.pem"
              "${certDir config.networking.hostName}/fullchain.pem"
            ];
          };
        };
      };
  };
}
