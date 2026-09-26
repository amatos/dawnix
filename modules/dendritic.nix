{ inputs, ... }:
{
  imports = [
    (inputs.flake-file.flakeModules.dendritic or { })
    (inputs.den.flakeModules.dendritic or { })
  ];

  # other inputs may be defined at a module using them.
  flake-file.inputs = {
    den.url = "git+ssh://git@github.com/denful/den.git";
    flake-file.url = "git+ssh://git@github.com/vic/flake-file.git";
    home-manager = {
      url = "git+ssh://git@github.com/nix-community/home-manager.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "git+ssh://git@github.com/LnL7/nix-darwin.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
