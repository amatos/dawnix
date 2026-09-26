{
  den.aspects.shell = {
    homeManager = { pkgs, ... }: {
      home.packages = [
        pkgs.htop
      ];
    };
  };
}
