{ den, ... }: {
  den.aspects.baseNixos = {
    includes = with den.aspects; [
      base
      nixosKernel
      systemd_boot
      bluetooth
      fwupd
      hello
    ];

    nixos =
      { config, lib, ... }:
      {
        home-manager.backupFileExtension = "hm-bak";
        networking.firewall.allowPing = true;

        # home-manager's installPackages step fetches from substituters, so it
        # needs a working resolver. Without this ordering, the service can start
        # mid-network-reconfiguration (e.g. dhcpcd→NetworkManager transition)
        # and hit DNS failures.
        systemd.services = lib.mapAttrs' (
          name: _:
          lib.nameValuePair "home-manager-${name}" {
            after = [ "network-online.target" ];
            wants = [ "network-online.target" ];
          }
        ) config.home-manager.users;
      };
  };
}
