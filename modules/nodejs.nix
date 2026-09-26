{
  den.aspects.nodejs = {
    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        nodejs
      ];
    };
  };
}
