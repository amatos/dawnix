# Minimal NixOS host — exists solely as a CI build target (see ci.yml's
# build-ephemeraltron job), never provisioned or switched to interactively.
# This config intentionally omits secrets management, home-manager, certbot,
# and Tailscale, since none of that is needed just to build the closure. It also
# carries no networking, users, SSH, or sudo config — nothing here is ever
# booted or logged into.

{ den, ... }: {
  # host aspect
  den.aspects.ephemeraltron =
    { lib, ... }:
    let
      computerName = "Ephemeraltron";
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
