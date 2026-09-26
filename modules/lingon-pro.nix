{ den, ... }: {
  den.aspects.lingonPro = {
    includes = [
      (den.batteries.unfree [
        "lingon-pro"
      ])
    ];

    darwin =
      { pkgs, ... }:
      let
        lingonPro = pkgs.callPackage ../pkgs/lingon-pro.nix { };
      in
      {
        environment.systemPackages = [ lingonPro ];
      };
  };
}
