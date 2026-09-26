# Basic devShell for working on this flake.
{
  perSystem =
    { pkgs, ... }:
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          git
          direnv
          nixfmt
          nil
          deadnix
          statix
          nh
        ];
      };
    };
}
