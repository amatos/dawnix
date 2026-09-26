{
  den.aspects.base = {
    nixos = {
      security = {
        sudo-rs = {
          enable = true;
          wheelNeedsPassword = false;
        };
      };
    };
    darwin = {
      security.pam.services.sudo_local.touchIdAuth = true;
    };
  };
}
