{ den, ... }: {
  den.aspects.bettertouchtool = {
    includes = [
      (den.batteries.unfree [ "bettertouchtool" ])
    ];

    darwin =
      { pkgs, ... }:
      let
        bettertouchtool = pkgs.callPackage ../pkgs/bettertouchtool.nix { };
      in
      {
        environment.systemPackages = [ bettertouchtool ];
      };
  };
}
