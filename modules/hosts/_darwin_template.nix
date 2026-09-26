{ den, ... }: {
  # host aspect
  den.aspects.template =
    { lib, ... }:
    let
      computerName = "template";
      hostName = lib.toLower computerName;
    in
    {
      includes = [
        den.batteries.hostname

        den.aspects.baseDarwin
        den.aspects.winbox
        den.aspects.syncthing
        den.aspects.zed
      ];

      networking = {
        computerName = computerName;
        hostName = hostName;
      };

      darwin =
        { pkgs, ... }:
        {
          environment.systemPackages = [ pkgs.hello ];
        };

      # host provides default home environment for its users
      provides.to-users.homeManager =
        { ... }:
        {
          home.packages = [ ];
        };
    };

}
