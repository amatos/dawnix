{ den, ... }: {
  den.aspects.orbstack = {
    includes = [
      (den.batteries.unfree [
        "orbstack"
      ])
    ];

    homeManager = { pkgs, ... }: {
      home.packages = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ pkgs.orbstack ];
    };
  };
}
