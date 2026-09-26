# When Lingon Pro releases a new version, the ZIP is published at the same URL.
# To update:
#   1. Run: nix store prefetch-file --hash-type sha256 https://www.peterborgapps.com/downloads/LingonPro10.zip
#   2. Replace the `hash` value below with the output.
#   3. Update `version` to match the new release.
#   4. Run `darwin-rebuild switch` to install the new version.
{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "lingon-pro";
  version = "10";

  src = fetchurl {
    url = "https://www.peterborgapps.com/downloads/LingonPro10.zip";
    hash = "sha256-A69FoylOBSSm+Ye3+f6n/ZU6OoVbd8lhe483GHDFAAg=";
  };

  nativeBuildInputs = [ unzip ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/Applications"
    cp -r "Lingon Pro.app" "$out/Applications/"
    runHook postInstall
  '';

  meta = {
    description = "Schedule and manage launchd agents and daemons on macOS";
    homepage = "https://www.peterborgapps.com/lingon/";
    platforms = lib.platforms.darwin;
    license = lib.licenses.unfree;
  };
})
