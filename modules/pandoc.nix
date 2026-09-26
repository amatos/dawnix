{
  den.aspects.pandoc = {
    homeManager = { pkgs, ... }: {
      home.packages = [
        pkgs.pandoc
      ];
    };
  };
}
