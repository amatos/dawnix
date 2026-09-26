{ den, ... }: {
  den.aspects.lmstudio = {
    includes = [
      (den.batteries.unfree [
        "lmstudio"
      ])
    ];

    homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.lmstudio ];
    };
  };
}
