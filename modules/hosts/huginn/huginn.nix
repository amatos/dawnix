{ den, ... }: {
  # host aspect
  den.aspects.huginn =
    { lib, ... }:
    let
      computerName = "Huginn";
      hostName = lib.toLower computerName;
    in
    {
      includes = [
        den.batteries.hostname

        den.aspects.baseNixos
        den.aspects.tailscale
        den.aspects.smtp-relay-smarthost
        den.aspects.dyndns-luadns
        den.aspects.syncthing
      ];

      # huginn IS the smart mail relay (smtp.home.matos.cc), so it must not
      # relay through itself — override base's fleet-wide inclusion of the
      # relay-client aspect. See modules/smtp-relay-client.nix.
      excludes = [ den.aspects.smtp-relay-client ];

      # host configuration
      den.hosts.huginn.hostname = "huginn";

      nixos = { pkgs, ... }: {
        local = {
          dyndnsLuadns.hostname = "home.matos.cc";
          certbot = {
            email = "alberth@matos.cc";
            fqdns = [
              "${hostName}.home.matos.cc"
              "${hostName}.ts.matos.cc"
              "mail.home.matos.cc"
              "mail.ts.matos.cc"
              "smtp.home.matos.cc"
              "smtp.ts.matos.cc"
            ];
          };
        };

        imports = [ ./_hardware-configuration.nix ];
        environment.systemPackages = [ pkgs.hello ];

        # huginn is real EFI hardware (see the vfat /boot in
        # _hardware-configuration.nix) — systemd-boot, not grub.
        boot.loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };
      };

      # host provides default home environment for its users
      provides.to-users.homeManager =
        { ... }:
        {
          home.packages = [ ];
        };
    };
}
