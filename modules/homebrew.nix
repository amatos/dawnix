# Packages are kept current via `brew autoupdate` (homebrew/autoupdate tap), which
# runs `brew update && brew upgrade --greedy --cleanup` every 30 hours in the
# background via a launchd LaunchAgent. The autoupdate plist is (re)created on
# every `darwin-rebuild switch` via a postActivation script.
#
# Our configuration:
#   - onActivation.autoUpdate = false  → Keeps rebuilds fast (no 45MB index download)
#   - onActivation.upgrade = false     → Rebuilds don't run brew upgrade (autoupdate handles it)
#   - brew autoupdate: every 30h       → Background upgrade with --greedy --cleanup
#   - Passive auto-update: Enabled     → >5 minutes trigger on command invocation
#
# == How Packages Get Updated ==
#
# 1. AUTOMATIC: brew autoupdate runs every 30 hours (background launchd agent)
# 2. MANUAL: Run `brew update && brew upgrade --greedy` for immediate updates

{ inputs, den, ... }: {
  flake-file.inputs.nix-homebrew.url = "git+ssh://git@github.com/zhaofengli/nix-homebrew.git";

  # Create a global or specific aspect for Homebrew
  den.aspects.homebrew =
    { host, user, ... }:
    {
      homeManager = {
        home.sessionPath = [ "/opt/homebrew/bin" ];
      };

      # Target the nix-darwin class configuration
      darwin =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          # 30 hours in seconds — brew autoupdate requires interval in seconds
          autoupdateInterval = 108000;

          configureBrewAutoupdateScript = pkgs.writeShellApplication {
            name = "configure-brew-autoupdate";
            runtimeInputs = [ ];
            text = builtins.readFile ./users/alberth/scripts/configure-brew-autoupdate.sh;
          };
        in
        {
          imports = [ inputs.nix-homebrew.darwinModules.default ];

          nix-homebrew = {
            enable = true;
            enableRosetta = false; # Set to true if on Apple Silicon (M1/M2/M3)
            user = user.userName;
            mutableTaps = true; # Set to false for full declarative management
          };

          # Declare what apps you want to install through Homebrew
          homebrew = {
            enable = true;
            enableBashIntegration = true;
            enableFishIntegration = true;
            enableZshIntegration = true;
            onActivation = {
              # Don't download 45MB index on every rebuild - keeps rebuilds fast and deterministic.
              # Homebrew's passive auto-update still works (triggers on command invocation after >5 minutes).
              autoUpdate = false;
              cleanup = "zap"; # Removes unlisted packages automatically
              # Upgrades handled by brew autoupdate (every 30h) — not during darwin-rebuild.
              # This keeps rebuilds fast. Run `brew upgrade --greedy` manually for immediate updates.
              upgrade = false;
            };
            taps = [
              {
                name = "domt4/autoupdate";
                trusted = true;
              }
            ];
            brews = [
              "mas" # Mac App Store CLI
            ];
          };

          # (Re)create the brew autoupdate LaunchAgent plist on every darwin-rebuild switch.
          # All logic lives in scripts/configure-brew-autoupdate.sh; this binding only
          # passes the configured interval through as an env var and invokes the script.
          system.activationScripts.postActivation.text = lib.mkAfter ''
            AUTOUPDATE_INTERVAL=${lib.escapeShellArg (toString autoupdateInterval)} \
              ${lib.getExe configureBrewAutoupdateScript} || true
          '';
        };
    };
}
