{ den, ... }: {
  den.aspects.browsers.orion = {
    includes = [
      (den.batteries.unfree [ "orion-browser" ])
    ];

    homeManager = { pkgs, ... }: {
      home.packages = [
        pkgs.orion-browser
      ];
    };
  };
}
