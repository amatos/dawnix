{ den, ... }: {
  den.aspects.desktop = {
    includes = with den.aspects; [
      _1password
      # aerospace
      alberth.darwinCustomizations
      alberth.scripts
      alberth.ssh
      browsers
      claudeCode
      crossover
      devLanguages
      discord
      draculaTheme
      elgato
      fonts
      ghostty
      gpg
      keyboard-maestro
      lazyvim
      little-snitch
      mac-app-store
      obsidian
      orbstack
      pandoc
      setapp
      skim
      sound
      spamsieve
      syncthing
      tex
      textexpander
      utm
      zapp
      zed
      zoom
      zsaVoyager
    ];
  };
}
