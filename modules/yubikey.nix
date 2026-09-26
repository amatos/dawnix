{
  den.aspects.base = {
    nixos = {
      services.pcscd.enable = true;
    };
    homeManager = { pkgs, ... }: {
      home = {
        packages = [
          pkgs.yubikey-manager
        ];
      };
    };
  };
}
