{ den, ... }: {
  den.aspects.base = {
    includes = with den.aspects; [
      _1password-cli
      certbot
      git
      github-ratelimit
      jujutsu
      lazyvim
      micro
      nh
      nix-tools
      secrets
      shell
      smtp-relay-client
      tailscale
      git
    ];

  };
}
