{ den, ... }: {
  den.aspects.muro = {
    darwin =
      { pkgs, ... }:
      let
        muro = pkgs.callPackage ../pkgs/muro.nix { };
      in
      {
        environment.systemPackages = [ muro ];
      };
  };
}
