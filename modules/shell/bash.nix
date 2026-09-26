{
  den.aspects.shell = {
    homeManager =
      {
        config,
        pkgs,
        ...
      }:

      {
        programs.bash = {
          enable = true;
          # dotDir = "${config.xdg.configHome}/bash";
          # initContent = ''
          #   [ -f ${config.xdg.configHome}/op/plugins.sh ] && source ${config.xdg.configHome}/op/plugins.sh
          # '';
        };
      };
  };
}
