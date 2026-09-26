{ den, ... }: {
  # host aspect
  den.aspects.nixDarwin = {
    nix = {
      gc = {
        automatic = true;
        interval = [
          {
            Hour = 1;
            Minute = 23;
            Weekday = 7;
          }
        ];
      };
      optimise = {
        automatic = true;
        interval = [
          {
            Hour = 2;
            Minute = 34;
            Weekday = 7;
          }
        ];
      };
      settings = {
        auto-optimise-store = true;
        cores = 0;
      };
      power = {
        restartAfterFreeze = true;
      };
    };
  };
}
