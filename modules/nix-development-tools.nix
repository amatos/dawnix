{ ... }:
let
  nixPackages =
    pkgs: with pkgs; [
      nixd
      nil
      nh
      alejandra
    ];
in
{
  den.aspects.nixDev = {
    homeManager = { pkgs, ... }: {
      home.packages = nixPackages pkgs;
    };
  };
}
