{ den, ... }: {
  den.aspects.texpile = {
    darwin =
      { pkgs, ... }:
      let
        texpile = pkgs.callPackage ../pkgs/texpile.nix { };
      in
      {
        environment.systemPackages = [ texpile ];
      };

    nixos =
      { pkgs, ... }:
      let
        texpile = pkgs.callPackage ../pkgs/texpile.nix { };
      in
      {
        environment.systemPackages = [ texpile ];
      };
  };
}
