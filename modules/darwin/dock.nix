{
  den.aspects.darwin.dock = { user, ... }: {
    darwin.system.defaults = {
      dock = {
        # ==========================================================================
        # Dock Appearance
        # ==========================================================================

        # Size of dock icons (in pixels)
        # Default: 64, Your preference: 64 (clean number)
        tilesize = 64;

        # Enable icon magnification on hover
        # Default: false
        magnification = false;

        # Magnified icon size (16-128 pixels)
        # Default: 128
        largesize = 128;

        # Dock position on screen: "bottom", "left", or "right"
        # Default: "bottom"
        orientation = "bottom";

        # ==========================================================================
        # Dock Behavior
        # ==========================================================================

        # Automatically hide and show the Dock
        # Default: false
        autohide = true;

        # Delay before Dock shows when hidden (seconds)
        # Default: 0.24
        # Only applies when autohide = true
        autohide-delay = 0.24;

        # Animation speed for hide/show (seconds)
        # Default: 1.0
        # Lower = faster animation
        autohide-time-modifier = 1.0;

        # Animate opening applications (bounce effect)
        # Default: true
        launchanim = true;

        # Show indicator dots for running applications
        # Default: true
        show-process-indicators = true;

        # Show recent applications section in Dock
        # Default: true
        # Enabled: allows temporary/non-Nix-managed apps to appear on the right
        # side of the dock without polluting the persistent-apps list. Recent
        # apps rotate automatically, keeping the dock clean.
        show-recents = true;

        # Minimize windows into their application icon
        # Default: false
        minimize-to-application = false;

        # Window minimize animation: "genie", "suck", or "scale"
        # Default: "genie"
        mineffect = "genie";

        # Make hidden app icons translucent
        # Default: false
        showhidden = true;

        # Show only open applications (hide persistent apps)
        # Default: false
        static-only = false;

        # ==========================================================================
        # Spaces & Mission Control
        # ==========================================================================

        # Automatically rearrange Spaces based on most recent use
        # Default: true
        # false = keep spaces in fixed order
        mru-spaces = true;

        # Group windows by application in Mission Control
        # Default: true
        expose-group-apps = true;

        # Mission Control animation duration (seconds)
        # Default: not set (uses system default)
        # expose-animation-duration = 0.15;

        # ==========================================================================
        # Trackpad Gestures (Dock-related)
        # ==========================================================================

        # Four-finger spread to show Desktop
        showDesktopGestureEnabled = true;

        # Four-finger pinch to show Launchpad
        showLaunchpadGestureEnabled = true;

        # Three-finger swipe up for Mission Control
        showMissionControlGestureEnabled = true;

        # Three-finger swipe down for App Exposé
        showAppExposeGestureEnabled = true;

        # ==========================================================================
        # Hot Corners
        # ==========================================================================
        #
        # Action values:
        #   1  = Disabled
        #   2  = Mission Control
        #   3  = Application Windows (App Exposé)
        #   4  = Desktop
        #   5  = Start Screen Saver
        #   6  = Disable Screen Saver
        #   10 = Put Display to Sleep
        #   11 = Launchpad
        #   12 = Notification Center
        #   13 = Lock Screen
        #   14 = Quick Note
        #
        # Your current configuration:

        # Top-left corner: Mission Control
        wvous-tl-corner = 1;

        # Top-right corner: Notification Center
        wvous-tr-corner = 1;

        # Bottom-left corner: Application Windows (App Exposé)
        wvous-bl-corner = 1;

        # Bottom-right corner: Quick Note
        wvous-br-corner = 1;

        # ==========================================================================
        # Advanced Options
        # ==========================================================================

        # Display app switcher on all displays
        # Default: false (only main display)
        # appswitcher-all-displays = false;

        # Scroll up on Dock icon to show all windows in that Space
        # Default: true
        scroll-to-open = true;

        # Spring loading for Dock items (drag files over apps)
        # Default: false
        enable-spring-load-actions-on-all-items = true;

        # Highlight hover effect for stack grid view
        # Default: false
        mouse-over-hilite-stack = true;

        # Hold Shift for slow-motion minimize animation
        # Default: false
        # slow-motion-allowed = false;

        # Dock Persistent Apps
        #
        # Apps appear in the Dock in this exact order.
        # Manual Dock changes WILL BE OVERWRITTEN on rebuild.
        #
        # App locations:
        #   - System apps: /System/Applications/
        #   - Nix system packages: /Applications/Nix Apps/
        #   - Home Manager apps (copyApps): ~/Applications/Home Manager Apps/
        #   - Manual installs: /Applications/
        #   - User apps: ~/Applications/
        #
        # NOTE: TCC-sensitive apps (Ghostty, VS Code, Discord) use copyApps (migrated
        # from mac-app-util trampolines) for stable paths that persist macOS TCC
        # permissions across darwin-rebuild.

        # ========================================================================
        # Left side of Dock (before separator) - Main apps
        # ========================================================================
        persistent-apps = [
          "/System/Applications/Apps.app"
          "/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app"
          "/Users/alberth/Applications/Home Manager Apps/Orion.app"
          "/Applications/Helium.app"
          "/System/Applications/Messages.app"
          "/System/Applications/Mail.app"
          "/System/Applications/Maps.app"
          "/System/Applications/FaceTime.app"
          "/System/Applications/Phone.app"
          "/System/Applications/Calendar.app"
          "/System/Applications/Contacts.app"
          "/System/Applications/Reminders.app"
          "/System/Applications/Notes.app"
          "/System/Applications/Photos.app"
          "/System/Applications/TV.app"
          "/System/Applications/Music.app"
          "/System/Applications/Games.app"
          "/System/Applications/App Store.app"
          "/System/Applications/iPhone Mirroring.app"
          "/System/Applications/System Settings.app"
          "/System/Applications/Preview.app"
          "/Applications/Ghostty.app"
          "/Applications/Zed.app"
          "/Applications/Claude.app"
        ];

        # ========================================================================
        # Right side of Dock (after separator) - Folders & utilities
        # ========================================================================
        persistent-others = [
          # {
          #   folder = {
          #     path = "/Volumes";
          #     showas = "automatic";
          #     displayas = "folder";
          #     arrangement = "name";
          #   };
          # }
          {
            folder = {
              path = "/Users/${user.userName}/Downloads";
              showas = "fan";
              displayas = "stack";
              arrangement = "date-modified";
            };
          }
        ];
      };
    };
  };
}
