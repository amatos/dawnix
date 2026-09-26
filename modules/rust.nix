{
  den.aspects.rust = {
    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        rustup
      ];
    };
  };
}
