{
  den.aspects.darwin.screencapture = { user, ... }: {
    darwin.system.defaults.screencapture = {
      location = "/Users/${user.userName}/Pictures/Screenshots/unsorted";
      type = "png"; # png, jpg, gif, pdf, tiff
      disable-shadow = true;
      include-date = true;
    };
  };
}
