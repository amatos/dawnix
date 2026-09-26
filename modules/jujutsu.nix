{ den, ... }:
let
  jjPackages =
    pkgs: with pkgs; [
      jujutsu
      jjui
      jj-fzf
      jj-vine
      jj-starship
      lazyjj
    ];
in
{
  den.aspects.jujutsu = {
    homeManager =
      { config, pkgs, ... }:
      {
        home.packages = jjPackages pkgs;

        programs.jujutsu = {
          enable = true;
          settings = {
            user = {
              name = den.aspects.${config.home.username}.meta.fullName;
              email = den.aspects.${config.home.username}.meta.email;
            };
            ui = {
              default-command = [
                "log"
                "--reversed"
              ];
              show-cryptographic-signatures = true;
            };
            signing = {
              behavior = "own";
              backend = "gpg";
              key = den.aspects.${config.home.username}.meta.key;
            };
          };
        };
      };
  };
}
