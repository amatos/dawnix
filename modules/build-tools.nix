{
  den.aspects.build-tools = {
    homeManager = { pkgs, ... }: {
      home.packages = with pkgs; [
        cmake
        cmake-format
        cmake-language-server
        cmake-lint
        meson
        mesonlsp
        meson-tools
        ninja
      ];
    };
  };
}
