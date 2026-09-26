{
  den.aspects.aerospace = {
    homeManager = { ... }: {
      programs.aerospace = {
        enable = true;
        launchd.enable = true;
        settings = {
          config-version = 2;
          start-at-login = true;
          after-startup-command = [ ];
          auto-reload-config = true;
          gaps.inner.horizontal = 5;
          gaps.inner.vertical = 5;
          gaps.outer.left = 0;
          gaps.outer.bottom = 0;
          gaps.outer.top = 0;
          gaps.outer.right = 0;
        };
      };
    };
  };
}
