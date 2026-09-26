{ den, ... }: {
  den.aspects.audioApps = {
    includes = with den.aspects.audio; [
      airfoil
      audioHijack
      focusriteControl
      farrago
      piezo
      fission
      soundsource
    ];
  };
}
