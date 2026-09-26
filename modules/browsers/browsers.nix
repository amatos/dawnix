{ den, ... }: {
  den.aspects.browsers = {
    includes = with den.aspects.browsers; [
      helium
      orion
    ];
  };
}
