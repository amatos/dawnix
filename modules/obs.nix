{ den, ... }: {
  den.aspects.obsStudio = {
    darwin = { pkgs, ... }: {
      homebrew.casks = [
        "obs"
      ];
    };

    nixos = { pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        obs-studio
        obs-do
        obs-cli
        obs-studio-plugins.obs-vnc
        obs-studio-plugins.obs-tuna
        obs-studio-plugins.obs-noise
        obs-studio-plugins.pixel-art
        obs-studio-plugins.input-overlay
        obs-studio-plugins.obs-3d-effect
      ];
    };
  };
}
