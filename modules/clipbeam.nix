{ den, ... }: {
  den.aspects.clipbeam = {
    includes = [
      (den.batteries.unfree [ "clipbeam" ])
    ];

    darwin =
      { pkgs, ... }:
      let
        clipbeam = pkgs.callPackage ../pkgs/clipbeam.nix { };
      in
      {
        environment.systemPackages = [ clipbeam ];
      };
  };
}
