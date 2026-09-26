{
  den.aspects.shell = {
    homeManager = { ... }:
    let
      baseSettings = builtins.fromTOML (builtins.readFile ./starship.toml);
    in
    {
      programs.starship = {
        enable = true;
        settings = baseSettings;
      };
    };
  };
}
