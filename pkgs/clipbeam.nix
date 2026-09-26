# When Clipbeam releases a new version, update the URL and hash:
#   1. Find the new DMG URL at https://clipbeam.com/#download
#   2. Run: nix store prefetch-file --hash-type sha256 <url>
#   3. Replace `hash` and `version` below.
#   4. Run `darwin-rebuild switch` to install the new version.
{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "clipbeam";
  version = "1.1.3";

  src = fetchurl {
    url = "https://clipbeam.ams3.digitaloceanspaces.com/Clipbeam_${finalAttrs.version}.dmg";
    hash = "sha256-Hp7cuBxoaHL41T7esH8UfEiKi/avUWhbGcLs/bvr7SA=";
  };

  # hdiutil needs to mount a disk image; the Nix sandbox blocks that on Darwin.
  __noChroot = true;

  # Disable fixup to prevent shebang patching from breaking the code signature.
  dontFixup = true;

  # undmg only handles HFS; use hdiutil (available on Darwin) for APFS DMGs.
  unpackPhase = ''
    mnt=$(mktemp -d)
    /usr/bin/hdiutil attach -nobrowse -readonly -mountpoint "$mnt" "$src"
    # ditto preserves macOS extended attributes and resource forks.
    /usr/bin/ditto "$mnt/Clipbeam.app" Clipbeam.app
    /usr/bin/hdiutil detach "$mnt"
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications"
    /usr/bin/ditto Clipbeam.app "$out/Applications/Clipbeam.app"
    runHook postInstall
  '';

  meta = {
    description = "Private AI super-memory that runs entirely on your computer";
    homepage = "https://clipbeam.com";
    platforms = lib.platforms.darwin;
    license = lib.licenses.unfree;
  };
})
