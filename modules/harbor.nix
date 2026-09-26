{ den, ... }: {
  den.aspects.harbor = {
    darwin =
      { pkgs, ... }:
      let
        harbor = pkgs.callPackage ../pkgs/harbor.nix { };
      in
      {
        environment.systemPackages = [ harbor ];
      };
  };
}
