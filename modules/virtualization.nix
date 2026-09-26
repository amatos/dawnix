{ ... }: {
  den.aspects.utm = {
    homeManager = { pkgs, ... }: {
      home.packages = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ pkgs.utm ];
    };
  };
}
