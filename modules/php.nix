{
  den.aspects.php = {
    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        php
        phpantom-lsp
      ];
    };
  };
}
