{
  den.aspects.shell = {
    homeManager = { pkgs, ... }: {
      home.packages = [
        pkgs.dos2unix
      ];
    };
  };
}
