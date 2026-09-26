{ den, ... }: {
  den.aspects.betterdisplay = {
    includes = [
      (den.batteries.unfree [ "betterdisplay" ])
    ];
    homeManager = { pkgs, ... }: {
      home.packages = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
        pkgs.betterdisplay
      ];
    };
  };
}
