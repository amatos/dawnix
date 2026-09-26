{ den, ... }: {
  den.aspects.alberth.darwinCustomizations = {
    includes = with den.aspects.darwin; [
      controlCenter
      dock
      finder
      menuExtraClock
      nsGlobalDomain
      screencapture
      softwareUpdate
      loginWindow
      screenSaver
      trackpad
    ];

  };
}
