let
  ezaAliases = {
    l = "eza";
    ll = "eza -l --icons auto";
    la = "eza -la --icons auto";
    lt = "eza -lT --icons auto";
    ltt = "eza -lT --level=2 --icons auto";
    tree = "eza -T --all --level=3 --icons auto";
    ls = "eza -abghlUm --icons auto";
    big = "eza -lSh --icons auto";
  };
in
{
  den.aspects.shell = {
    homeManager = {
      programs = {
        eza = {
          enable = true;
        };
        bash.shellAliases = ezaAliases;
        zsh.shellAliases = ezaAliases;
        fish.shellAliases = ezaAliases;
      };
    };
  };
}
