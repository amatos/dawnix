# When Muro releases a new version:
#   1. Find the new release at https://github.com/MrRockySL/Muro/releases
#   2. Run: nix store prefetch-file --hash-type sha256 https://github.com/MrRockySL/Muro/releases/download/vX.Y/Muro-X.Y.dmg
#   3. Replace `version` and `hash` below with the new values.
#   4. Run `darwin-rebuild switch` to install the new version.
{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "muro";
  version = "5.0";

  src = fetchurl {
    url = "https://github.com/MrRockySL/Muro/releases/download/v${finalAttrs.version}/Muro-${finalAttrs.version}.dmg";
    hash = "sha256-x9MQ2NYXfHzwGpt70+7pTqXYGBL4VDNxop6G3kThYMs=";
  };

  # hdiutil needs to mount a disk image; the Nix sandbox blocks that on Darwin.
  __noChroot = true;

  # Disable fixup to prevent shebang patching from breaking the code signature.
  dontFixup = true;

  unpackPhase = ''
    mnt=$(mktemp -d)
    /usr/bin/hdiutil attach -nobrowse -readonly -mountpoint "$mnt" "$src"
    /usr/bin/ditto "$mnt/Muro.app" Muro.app
    /usr/bin/hdiutil detach "$mnt"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications"
    /usr/bin/ditto Muro.app "$out/Applications/Muro.app"
    runHook postInstall
  '';

  meta = {
    description = "Live wallpaper player for macOS";
    homepage = "https://github.com/MrRockySL/Muro";
    platforms = lib.platforms.darwin;
    license = lib.licenses.free;
  };
})
