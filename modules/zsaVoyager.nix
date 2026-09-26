{ den, ... }: {
  den.aspects.zsaVoyager = {
    includes = [
      (den.provides.unfree [ "keymapp"])

      den.aspects.zapp
    ];

    darwin = {
      homebrew.casks = [ "zed" ];
    };

    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        keymapp
      ];
    };
  };
}
