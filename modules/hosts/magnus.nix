{ den, ... }: {
  # host aspect
  den.aspects.magnus =
    { lib, ... }:
    let
      computerName = "Magnus";
      hostName = lib.toLower computerName;
    in
    {
      includes = [
        den.batteries.hostname
      ]
      ++ (with den.aspects; [
        arq
        lingonPro
        audioApps
        baseDarwin
        claudeCode
        devLanguages
        guiDevTools
        obsStudio
        orbstack
        steam
        supaSideBar
        syncthing
        tailscale
        utm
        winbox
        zed
        zsaVoyager
        alfred
        lmstudio
        clipbeam
        muro
        harbor
        texpile
        pelmet
        syntaxHighlight
        betterdisplay
        games.battleNet
      ]);

      # host configuration
      den.hosts.${computerName}.hostname = computerName;
      networking = {
        computerName = computerName;
        hostName = hostName;
      };

      darwin =
        { lib, pkgs, ... }:
        {
          local.certbot = {
            email = "alberth@matos.cc";
            fqdns = [
              "${hostName}.home.matos.cc"
              "${hostName}.ts.matos.cc"
            ];
          };

          environment.systemPackages = [ pkgs.hello ];

          # Dedicated APFS volume backing OrbStack's container data (Docker images,
          # volumes, Linux VMs). disk3 is darwin's internal APFS container; re-check
          # with `diskutil apfs list` if the physical disk layout ever changes.
          system.activationScripts.extraActivation.text = lib.mkAfter ''
            if ! diskutil apfs list disk3 2>/dev/null | grep -q "ContainerData"; then
              echo "creating ContainerData APFS volume..." >&2
              diskutil apfs addVolume disk3 APFS ContainerData
            fi
          '';
        };

      # host provides default home environment for its users
      provides.to-users.homeManager =
        { ... }:
        {
          home.packages = [ ];
        };
    };

}
