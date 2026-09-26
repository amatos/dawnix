{
  den.aspects.kaleidoscope = {
    darwin = {
      homebrew.casks = [ "kaleidoscope" ];
    };

    homeManager = {
      programs.git = {
        settings = {
          diff = {
            tool = "kaleidoscope";
          };
          difftool = {
            "kaleidoscope" = {
              cmd = "ksdiff --partial-changeset --relative-path \"$MERGED\" -- \"$LOCAL\" \"$REMOTE\"";
            };
            prompt = false;
            trustExitCode = true;
          };
          merge = {
            tool = "kaleidoscope";
          };
          mergetool = {
            "kaleidoscope" = {
              cmd = "ksdiff --merge --output \"$MERGED\" --base \"$BASE\" -- \"$LOCAL\" --snapshot \"$REMOTE\" --snapshot \"$LOCAL\"";
              trustExitCode = true;
            };
          };
        };
      };
      programs.jujutsu = {
        enable = true;
        settings = {
          ui = {
            diff-formatter = "ksdiff";
            merge-editor = "ksdiff";
          };
          merge-tools.ksdiff = {
            diff-invocation-mode = "file-by-file";
            diff-args = [
              "--partial-changeset"
              "$left"
              "$right"
            ];
            merge-args = [
              "--merge"
              "--output"
              "$output"
              "--base"
              "$base"
              "$left"
              "$right"
            ];
          };
        };
      };
    };
  };
}
