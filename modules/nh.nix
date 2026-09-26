# Exposes flake apps under the name of each host / home for building with nh,
# and installs the nh CLI itself so it's actually available to run.
{ den, ... }: {
  den.aspects.nh = {
  };

  perSystem = { pkgs, ... }: {
    packages = den.lib.nh.denPackages { fromFlake = true; } pkgs;
  };
}
