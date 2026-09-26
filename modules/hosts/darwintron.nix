{ den, ... }: {
  # host aspect
  den.aspects.darwintron =
    { lib, ... }:
    let
      computerName = "Darwintron";
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

      # host configuration
      # den.hosts.darwintron.hostname = computerName;
      #
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
