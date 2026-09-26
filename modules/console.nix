{
  den.aspects.base = {
    nixos =
      { pkgs, ... }:
      {
        console = {
          earlySetup = true;
          font = "ter-124b";

          packages = with pkgs; [
            terminus_font
          ];

          useXkbConfig = true;
        };
      };
  };
}
