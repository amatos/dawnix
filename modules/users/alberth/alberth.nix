{ den, inputs, ... }:
{
  # user aspect
  den.aspects.alberth =
    { config, ... }:
    {
      includes = [
        den.batteries.define-user
        den.batteries.host-aspects
        (den.batteries.user-shell "fish")

        # den.aspects.shell

      ];

      # Inlined equivalent of den.batteries.primary-user: that battery's
      # userToHostContext is a `{ user, host, ... }` function, which (on this
      # fleet, with alberth on both NixOS and Darwin hosts) leaks its
      # `nixos.users.users.<name>.extraGroups` content into the Darwin build
      # instead of being filtered out for non-NixOS hosts. Declaring the same
      # settings as plain (non-host-context) aspect content avoids the leak.
      darwin.system.primaryUser = config.meta.username;

      homeManager =
        { pkgs, ... }:
        {
          home.packages = [ pkgs.htop ];
          programs.man.package = pkgs.man-db; # or another valid package
          programs.man.generateCaches = true;

          home.sessionVariables = {
            YUBIAGE = "${inputs.nix-secrets}/age-yubikey-identity-b4d67c6f.txt";
          };
        };

      user = {
        createHome = true;
        description = config.meta.fullName;

        # initialPassword = "id";
      };

      # extraGroups and openssh are NixOS-only users.users options
      # (not supported by nix-darwin's users.users submodule).
      nixos.users.users.${config.meta.username} = {
        extraGroups = [
          "dialout" # Or else: Permission denied: ‘/dev/ttyUSB0’
          "input"
          "tty"
        ];

        openssh.authorizedKeys.keys = config.meta.authorizedKeys;
      };

      meta = {
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILfxNl1S0Fvzh2aOAG6FuIwB96eqnUqY1nl2p2jSnTOD"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJmQ75w1oH1osbRwMjjem52/8Oc8YYbmTbMxSIEw9Xy8 alberth@darwintron"
        ];

        email = "alberth@matos.cc";
        fullName = "Alberth Matos";
        key = "F41BDBF6171A3BB4"; # ed25519/0xF41BDBF6171A3BB4

        keygrip = [
          "5FC8FE1141FA769594E91E48F41BDBF6171A3BB4"
        ];

        username = "alberth";
      };

      # user can provide NixOS configurations
      # to any host it is included on
      provides.to-hosts.nixos = { ... }: { };
      provides.to-hosts.darwin = { ... }: { };

    };
}
