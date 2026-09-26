{
  den.aspects.base = {
    homeManager = {
      programs.zellij = {
        enable = true;
        # attachExistingSession = true;
        enableFishIntegration = false;

        settings = {
          copy_on_select = true;
          default_layout = "welcome";
          default_mode = "locked";
          mouse_mode = true;
          pane_frames = true;
          # See https://zellij.dev/documentation/options.html
          show_startup_tips = true;
          simplified_ui = false;
          theme_light = "catppuccin-latte";
          theme_dark = "catppuccin-macchiato";
        };
      };
    };
  };
}
