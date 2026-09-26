{ den, ... }: {
  den.aspects.obsidian = {
    includes = [
      (den.batteries.unfree [ "obsidian" ])
    ];

    darwin = {
      homebrew.casks = [ "obsidian" ];
    };

    homeManager = { pkgs, ... }: {
      programs.obsidian = {
        enable = true;
        package = null;
        cli.enable = true;
      };
    };
  };
}
