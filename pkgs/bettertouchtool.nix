# When BetterTouchTool releases a new version:
#   1. Find the new version and build number at https://folivora.ai/releases/
#      (or run `brew info --cask bettertouchtool`).
#   2. Run: nix store prefetch-file --hash-type sha256 https://folivora.ai/releases/btt<version>-<build>.zip
#   3. Replace `version`, `build`, and `hash` below with the new values.
#   4. Run `darwin-rebuild switch` to install the new version.
{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "bettertouchtool";
  version = "6.861";
  build = "2026092506";

  src = fetchurl {
    url = "https://folivora.ai/releases/btt${finalAttrs.version}-${finalAttrs.build}.zip";
    hash = "sha256-akJDdWxnenwEFfuYeyWZLB0hlgy/3XeJRraV1PDzfN0=";
  };

  nativeBuildInputs = [ unzip ];

  sourceRoot = ".";

  # Disable fixup to prevent shebang patching from breaking the code signature.
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications"
    cp -r BetterTouchTool.app "$out/Applications/"
    runHook postInstall
  '';

  meta = {
    description = "Customize input devices and automate workflows on macOS";
    homepage = "https://folivora.ai";
    platforms = lib.platforms.darwin;
    license = lib.licenses.unfree;
  };
})
