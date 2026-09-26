let
  batAliases = {
    cat = "bat  --style=header,grid";
  };
in
{
  den.aspects.shell = {
    homeManager = {
      programs = {
        bat = {
          enable = true;
          config = {
            theme = "Monokai Extended";
            style = "numbers,changes";
          };
        };
        bash.shellAliases = batAliases;
        zsh.shellAliases = batAliases;
        fish.shellAliases = batAliases;
      };
    };
  };
}
