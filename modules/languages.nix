{ den, ... }: {
  den.aspects.devLanguages = {
    includes = with den.aspects; [
      build-tools
      java
      nodejs
      php
      python
      ruby
      rust
      nixDev
      jq
      just
    ];
  };
}
