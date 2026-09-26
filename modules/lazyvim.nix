{ inputs, ... }: {
  flake-file.inputs.lazyvim.url = "git+ssh://git@github.com/pfassina/lazyvim-nix.git";

  den.aspects.lazyvim = {
    homeManager =
      { pkgs, ... }:
      let
        nvimAliases = {
          vim = "nvim";
          vi = "nvim";
          vimdiff = "nvim -d";
        };
      in
      {
        imports = [ inputs.lazyvim.homeManagerModules.default ];

        home.sessionVariables = {
          EDITOR = "nvim";
        };

        programs = {
          lazyvim = {
            enable = true;
            ignoreBuildNotifications = true;

            config = {
              options = ''
                vim.opt.relativenumber = false
                vim.opt.wrap = true
              '';
            };
            extras = {
              lang = {
                nix.enable = true;
                python = {
                  enable = true;
                  installDependencies = true;
                  installRuntimeDependencies = true;
                };
              };
            };
            extraPackages = with pkgs; [
              nixd # Nix LSP
              nil # Nix formatter
            ];
            plugins = {
              colorscheme = ''
                return {
                  "catppuccin",
                  opts = { flavour = "macchiato" },
                }
              '';
            };
          };

          bash.shellAliases = nvimAliases;
          zsh.shellAliases = nvimAliases;
          fish.shellAliases = nvimAliases;
        };
      };
  };
}
