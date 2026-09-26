{ den, ... }: {
  den.aspects._1password-cli = {
    includes = [
      (den.batteries.unfree [ "1password-cli" ])
    ];

    homeManager = { pkgs, ... }: {
      home.packages = [
        pkgs._1password-cli
      ];
    };
  };
}
