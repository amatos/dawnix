# Wires ragenix + a shared, reusable Tailscale auth key (from the private
# nix-secrets repo) into the aspect so any host that includes it joins the
# tailnet automatically, without a manual `tailscale login`.
{ den, inputs, ... }:
let
  # The macOS app bundles its own tailscaled/CLI; nix-darwin never installs
  # pkgs.tailscale there, so both the shell alias and the completion scripts
  # below need this literal path instead of a package binary.
  darwinTailscaleBin = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
in
{
  den.aspects.tailscale = {
    includes = [ den.aspects.secrets ];

    darwin =
      { config, pkgs, ... }:
      {
        services.tailscale.enable = false;
        homebrew.masApps = {
          "Tailscale" = 1475387142;
        };

        environment.shellAliases.tailscale = darwinTailscaleBin;
        # environment.shellAliases only reaches bash/zsh rc files on
        # nix-darwin; fish's system alias block is generated separately
        # from programs.fish.shellAliases (see modules/shell/fish.nix).
        programs.fish.shellAliases.tailscale = darwinTailscaleBin;
      };

    nixos =
      { config, ... }:
      {
        services.tailscale.enable = true;
        # Opens the tailscale UDP port so peers can connect directly
        # instead of always relaying through DERP.
        services.tailscale.openFirewall = true;

        age.secrets.tailscale-authkey.file = "${inputs.nix-secrets}/services/tailscale-authkey.age";
        services.tailscale.authKeyFile = config.age.secrets.tailscale-authkey.path;

        networking.firewall.enable = true;
        # tailscale0 is the "local" network device: traffic arriving over
        # the tailnet is treated as coming from a trusted local network.
        networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 22 ];
      };

    homeManager =
      { pkgs, ... }:
      let
        # On nixos the real `tailscale` package is already on PATH via
        # services.tailscale.enable above; on darwin there's no such
        # package, so fall back to the app bundle's CLI (see darwinTailscaleBin).
        tailscaleBin = if pkgs.stdenv.hostPlatform.isDarwin then darwinTailscaleBin else "tailscale";
      in
      {
        programs.bash.initExtra = ''
          source <(${tailscaleBin} completion bash)
        '';

        programs.zsh.initContent = ''
          source <(${tailscaleBin} completion zsh)
        '';

        programs.fish.interactiveShellInit = ''
          ${tailscaleBin} completion fish | source
        '';
      };
  };
}
