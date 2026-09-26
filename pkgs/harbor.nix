# When Harbor releases a new version:
#   1. Find the new release at https://github.com/thsnkhn/harbor/releases
#   2. Run: nix store prefetch-file --hash-type sha256 https://github.com/thsnkhn/harbor/releases/download/vX.Y.Z/Harbor-X.Y.Z.dmg
#   3. Replace `version` and `hash` below with the new values.
#   4. Run `darwin-rebuild switch` to install the new version.
{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "harbor";
  version = "1.8.1";

  src = fetchurl {
    url = "https://github.com/thsnkhn/harbor/releases/download/v${finalAttrs.version}/Harbor-${finalAttrs.version}.dmg";
    hash = "sha256-1uQXYnFTjzMnCc8M4dy2CqujKmKTLizh3YRkmWxuQvM=";
  };

  # hdiutil needs to mount a disk image; the Nix sandbox blocks that on Darwin.
  __noChroot = true;

  # Disable fixup to prevent shebang patching from breaking the code signature.
  dontFixup = true;

  unpackPhase = ''
    mnt=$(mktemp -d)
    /usr/bin/hdiutil attach -nobrowse -readonly -mountpoint "$mnt" "$src"
    /usr/bin/ditto "$mnt/Harbor.app" Harbor.app
    /usr/bin/hdiutil detach "$mnt"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications"
    /usr/bin/ditto Harbor.app "$out/Applications/Harbor.app"
    runHook postInstall
  '';

  meta = {
    description = "Mac downloader for torrents, magnet links, YouTube, and other public URLs";
    homepage = "https://thsnkhn.github.io/harbor/";
    platforms = lib.platforms.darwin;
    license = lib.licenses.gpl3Only;
  };
})
