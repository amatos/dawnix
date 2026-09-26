{
  den.aspects.hello = {
    homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.hello ];
    };
  };
}
