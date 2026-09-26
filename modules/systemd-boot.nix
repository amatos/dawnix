{
  den.aspects.systemd_boot = {
    boot.loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      tmp = {
        cleanOnBoot = true;
        useTmpfs = true;
      };
    };
  };
}
