{ den, ... }: {
  den.aspects.base = {
    # "networkmanager" is a NixOS-only users.users.<name>.extraGroups concept
    # (not supported by nix-darwin's users.users submodule), so it's declared
    # directly under `nixos` (keyed per user) instead of the generic `user`
    # class, which routes unconditionally to whichever OS class the host is.
    includes = [
      den.provides.hostname
      ({ user, ... }: {
        nixos.users.users.${user.userName}.extraGroups = [ "networkmanager" ];
      })
    ];

    nixos = {
      boot.initrd.systemd.network.wait-online.enable = false;

      networking = {
        dhcpcd.enable = false;
        networkmanager.enable = true;
      };

      services.resolved.enable = true;
      systemd.network.wait-online.enable = false;
    };
  };
}
