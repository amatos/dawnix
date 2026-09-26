{
  den.aspects.tex = {
    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        texlab
      ];
    };
  };
}
