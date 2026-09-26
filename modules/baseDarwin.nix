{ den, ... }: {
  den.aspects.baseDarwin = {
    includes = with den.aspects; [
      _1password
      base
      desktop
      hello
      homebrew
      nixDarwin
      topnotch
      bettertouchtool
    ];

    darwin = {
      home-manager.backupFileExtension = "hm-bak";

      environment.etc."sudoers.d/nix-rebuild-sudoers" = {
        text = ''
          %staff ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/darwin-rebuild
        '';
      };
    };
  };
}
