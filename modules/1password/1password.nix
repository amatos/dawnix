{ den, ... }: {
  den.aspects._1password = {
    includes = [
      (den.batteries.unfree [
        "1password"
        "1password-gui"
      ])
    ];

    nixos = { config, ... }: {
      programs = {
        _1password = {
          enable = true;
        };
        _1password-gui = {
          enable = true;
          # Certain features, including CLI integration and system authentication support,
          # require enabling PolKit integration on some desktop environments (e.g. Plasma).
          polkitPolicyOwners = [ "${config.home.username}" ];
        };
      };
    };

    darwin = {
      programs = {
        _1password = {
          enable = true;
        };
        _1password-gui = {
          enable = true;
         };
      };
    };
  };
}
