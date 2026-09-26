{
  den.aspects.zoom = {
    darwin = {
      homebrew.casks = [ "zoom" ];
    };

    homeManager = { pkgs, ... }: {
      home.packages = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [ pkgs.zoom ];
    };
  };
}
