# Wires ragenix into every host so aspects can reference age-encrypted
# secrets from the private nix-secrets repo via:
#   age.secrets.<name>.file = "${inputs.nix-secrets}/<path>.age";
#
# The homeManager face decrypts with the user's own identity (age.identityPaths
# defaults to ~/.ssh/id_ed25519 / id_rsa, extended below with every
# age-yubikey-identity-*.txt from nix-secrets) rather than a host key, so it's
# for secrets a user's home-manager config needs directly (e.g. a per-user GUI
# password), separate in trust model from the darwin/nixos faces above.
#
# Deliberately no raw private key lives in nix-secrets or here: that would let
# anyone who can read the repo decrypt everything in it, defeating the point.
# ~/.ssh/id_ed25519 (a personal, non-fleet age key) has to be provisioned
# out-of-band per machine. The YubiKey identity files are safe to commit --
# each is a stub naming a physical key's serial/slot/PIN-policy, useless
# without that hardware plugged in -- so any host with one of the user's
# YubiKeys attached can decrypt without further provisioning.
{ inputs, ... }:
{
  flake-file.inputs.ragenix.url = "git+ssh://git@github.com/yaxitech/ragenix.git";
  flake-file.inputs.nix-secrets.url = "git+ssh://git@github.com/amatos/nix-secrets.git";

  den.aspects.secrets = {
    darwin = {
      imports = [ inputs.ragenix.darwinModules.default ];
    };

    nixos = {
      imports = [ inputs.ragenix.nixosModules.default ];
    };

    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        imports = [ inputs.ragenix.homeManagerModules.default ];

        home.packages = [ pkgs.age-plugin-yubikey ];

        age.identityPaths = [
          "${config.home.homeDirectory}/.ssh/id_ed25519"
          "${config.home.homeDirectory}/.ssh/id_rsa"
        ]
        ++ map (name: "${inputs.nix-secrets}/age-yubikey-identity-${name}.txt") [
          "0634d1c4"
          "2ab5ff2f"
          "49705840"
          "7cb1cad0"
          "b4d67c6f"
          "be7a2b66"
        ];

        # launchd agents don't inherit an interactive shell's PATH, so `age`
        # can't find the age-plugin-yubikey binary it shells out to for the
        # identity files above unless it's put on PATH explicitly here.
        launchd.agents.activate-agenix = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
          config.EnvironmentVariables.PATH = lib.mkForce "${pkgs.age-plugin-yubikey}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
        };
      };
  };
}
