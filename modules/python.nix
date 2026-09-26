{
  den.aspects.python = {
    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        black
        pylint
        pyrefly
        python3
      ];
    };
  };
}
