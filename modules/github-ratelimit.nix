# Gives the machine itself (root, not a logged-in user) an SSH identity for
# github.com. Nix's flake-input fetches use git+ssh:// URLs rather than the
# github: shorthand (see e.g. dendritic.nix, secrets.nix) specifically to
# avoid GitHub's REST/tarball API rate limit (60 req/hr unauthenticated) that
# the github: fetcher is subject to -- plain git-over-ssh isn't. This has to
# be its own machine-level key rather than the user's normal GitHub key
# (modules/users/alberth/ssh.nix, via the 1Password agent) because the Nix
# daemon fetches flake inputs as root, headless, with no user session or
# agent socket available.
{ den, inputs, ... }:
{
  den.aspects.github-ratelimit = {
    includes = [ den.aspects.secrets ];

    darwin =
      { config, ... }:
      {
        age.secrets.github-ratelimit.file = "${inputs.nix-secrets}/services/github-ratelimit.age";

        # No IdentitiesOnly here: this is system-wide (/etc/ssh/ssh_config),
        # so it also applies to interactive user sessions. IdentitiesOnly
        # isn't a per-Host-block "first match wins" override for IdentityFile
        # (that's cumulative) but it IS for the IdentitiesOnly keyword itself
        # -- setting it here would become the effective value for the user's
        # own github.com sessions too (their block in
        # modules/users/alberth/ssh.nix never sets it) and suppress the
        # 1Password-agent-provided personal key, since that key has no
        # IdentityFile entry anywhere for IdentitiesOnly to admit it through.
        programs.ssh.extraConfig = ''
          Host github.com
            IdentityFile ${config.age.secrets.github-ratelimit.path}
        '';
      };

    nixos =
      { config, ... }:
      {
        age.secrets.github-ratelimit.file = "${inputs.nix-secrets}/services/github-ratelimit.age";

        # No IdentitiesOnly here: this is system-wide (/etc/ssh/ssh_config),
        # so it also applies to interactive user sessions. IdentitiesOnly
        # isn't a per-Host-block "first match wins" override for IdentityFile
        # (that's cumulative) but it IS for the IdentitiesOnly keyword itself
        # -- setting it here would become the effective value for the user's
        # own github.com sessions too (their block in
        # modules/users/alberth/ssh.nix never sets it) and suppress the
        # 1Password-agent-provided personal key, since that key has no
        # IdentityFile entry anywhere for IdentitiesOnly to admit it through.
        programs.ssh.extraConfig = ''
          Host github.com
            IdentityFile ${config.age.secrets.github-ratelimit.path}
        '';
      };
  };
}
