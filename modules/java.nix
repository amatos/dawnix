{
  den.aspects.java = {
    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        openjdk21
        maven3
        gradle
        groovy
        plantuml
      ];
    };
  };
}
