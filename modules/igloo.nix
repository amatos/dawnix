{ den, ... }:
{
  # host aspect
  den.aspects.igloo = {
    includes = [
      den.batteries.hostname

      den.aspects.baseNixos
      den.aspects.desktop
    ];
    # host configuration
    den.hosts.igloo.hostname = "igloo";
    nixos = { pkgs, ... }: {

      environment.systemPackages = [ pkgs.hello ];

      # Minimal config required for a bootable NixOS system (VM target).
      fileSystems."/" = {
        device = "/dev/vda";
        fsType = "ext4";
      };
      boot.loader.grub.device = "/dev/vda";
    };

    # host provides default home environment for its users
    provides.to-users.homeManager =
      { ... }:
      {
        home.packages = [ ];
      };
  };
}
