{
  den.aspects.ruby = {
    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        ruby
        rubyfmt
      ];
    };
  };
}
