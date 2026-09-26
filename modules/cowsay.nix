{
  den.aspects.shell = {
    homeManager = { pkgs, ... }: {
      home.packages = [
        pkgs.cowsay
      ];
    };
  };
}
