{ den, ... }:
{
  den.aspects.discord = {
    includes = [
      den.aspects.draculaTheme
    ];
    darwin = {
      homebrew.casks = [
        "discord"
        "betterdiscord-installer"
      ];
    };
  };
}
