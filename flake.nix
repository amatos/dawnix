# DO-NOT-EDIT. This file was auto-generated using github:denful/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

  inputs = {
    darwin = {
      url = "git+ssh://git@github.com/LnL7/nix-darwin.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    den.url = "git+ssh://git@github.com/denful/den.git";
    flake-file.url = "git+ssh://git@github.com/vic/flake-file.git";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    home-manager = {
      url = "git+ssh://git@github.com/nix-community/home-manager.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    import-tree.url = "github:denful/import-tree";
    lazyvim.url = "git+ssh://git@github.com/pfassina/lazyvim-nix.git";
    nix-homebrew.url = "git+ssh://git@github.com/zhaofengli/nix-homebrew.git";
    nix-secrets.url = "git+ssh://git@github.com/amatos/nix-secrets.git";
    nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
    ragenix.url = "git+ssh://git@github.com/yaxitech/ragenix.git";
  };
}
