{ den, ... }: {
  # host aspect
  den.aspects.bjorn =
    { lib, ... }:
    let
      computerName = "Bjorn";
      hostName = lib.toLower computerName;
    in
    {
      includes = [
        den.batteries.hostname

        den.aspects.baseNixos
      ];

      # host configuration
      den.hosts.${hostName}.hostname = hostName;

      nixos = { pkgs, ... }: {
        local.certbot = {
          email = "alberth@matos.cc";
          fqdns = [
            "${hostName}.home.matos.cc"
            "${hostName}.ts.matos.cc"
          ];
        };

        imports = [ ./_hardware-configuration.nix ];
        environment.systemPackages = [ pkgs.hello ];

        # the host is real EFI hardware (see the vfat /boot in
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
