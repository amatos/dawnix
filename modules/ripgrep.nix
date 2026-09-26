{
  den.aspects.shell = {
    homeManager =
      let
        rgAliases = {
          grep = "rg";
        };
      in
      {
        programs = {
          ripgrep.enable = true;

          bash.shellAliases = rgAliases;
          zsh.shellAliases = rgAliases;
          fish.shellAliases = rgAliases;
        };
      };
  };
}
