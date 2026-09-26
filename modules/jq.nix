{
  den.aspects.jq = {
    homeManager = { pkgs, ... }: {
      home.packages = [
        pkgs.jq
        pkgs.jqfmt
        pkgs.jq-lsp
      ];
    };
  };
}
