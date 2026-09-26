{
  den.aspects.just = {
    homeManager = { pkgs, ... }: {
      home.packages = [
        pkgs.just
        pkgs.just-lsp
        pkgs.just-formatter
      ];
    };
  };
}
