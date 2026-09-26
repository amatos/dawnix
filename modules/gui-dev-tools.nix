{ den, ... }: {
  den.aspects.guiDevTools = {
    includes = with den.aspects; [
      git-tower
      kaleidoscope
    ];
  };
}
