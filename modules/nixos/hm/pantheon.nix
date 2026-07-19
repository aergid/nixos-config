{ config, lib, pkgs, ... }:
with lib.hm.gvariant;
{
  dconf.settings = {
		"io/elementary/settings-daemon/prefers-color-scheme" = {
			prefer-dark-schedule = "sunset-to-sunrise";
		};

    "io/elementary/desktop/wingpanel" = {
      use-transparency = false;
    };

    "io/elementary/desktop/wingpanel/datetime" = {
      clock-format = "24h";
    };

    "io/elementary/desktop/wingpanel/sound" = {
      max-volume = 100.0;
    };

    "io/elementary/desktop/wingpanel/power" = {
      show-percentage = true;
    };


    "io/elementary/settings-daemon/datetime" = {
      show-weeks = true;
    };


    "net/launchpad/plank/docks/dock1" = {
      alignment = "center";
      hide-mode = "window-dodge";
      icon-size = 48;
      pinned-only = false;
      position = "bottom";
      theme = "Transparent";
    };

		"org/gnome/desktop/session" = {
			idle-delay = 0;
		};

    "org/gnome/desktop/datetime" = {
      automatic-timezone = true;
    };

		"org/gnome/desktop/peripherals/touchpad" = {
			natural-scroll = false;
			disable-while-typing = true;
		};

    "org/gnome/desktop/interface" = {
      clock-format = "24h";
      cursor-size = 32;
      cursor-theme = "elementary";
      # document-font-name = "Work Sans 12";
      # font-name = "Work Sans 12";
      gtk-theme = "io.elementary.stylesheet.blueberry";
      gtk-enable-primary-paste = true;
      icon-theme = "elementary";
      monospace-font-name = "FiraCode Nerd Font Medium 13";
      text-scaling-factor = 1.0;
    };

    "org/gnome/desktop/input-sources" = {
      xkb-options = [ "grp:caps_toggle" ];
      sources = [
        (mkTuple [ "xkb" "us" ])
        (mkTuple [ "xkb" "ru" ])
      ];
    };

    "org/gnome/desktop/sound" = {
      theme-name = "elementary";
    };

    "org/gnome/desktop/wm/keybindings" = {
      switch-to-workspace-left = [ "<Primary><Alt>Left" ];
      switch-to-workspace-right = [ "<Primary><Alt>Right" ];
      # Default binds <Alt>space here, colliding with the custom
      # launcher binding below — clear it so <Alt>space is free.
      activate-window-menu = [ ];
    };

   "org/gnome/settings-daemon/plugins/xsettings" = {
    overrides = ''
      {'Gtk/DialogsUseHeader': <0>, 'Gtk/ShellShowsAppMenu': <0>, 'Gtk/EnablePrimaryPaste': <0>, 'Gtk/DecorationLayout': <'close,minimize,maximize:menu'>, 'Gtk/ShowUnicodeMenu': <0>}
    '';
    };

    "org/gnome/desktop/wm/preferences" = {
      titlebar-font = "Work Sans Semi-Bold 12";
      audible-bell = false;
      button-layout = ":minimize,maximize,close";
      # num-workspaces = 8;
      # workspace-names = ["Web" "Work" "Chat" "Code" "Virt" "Cast" "Fun" "Stuff"];
    };

    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left = [ "<Super>Left" ];
      toggle-tiled-right = [ "<Super>Right" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
      ];
    };

		"io/elementary/files/preferences" = {
			restore-tabs = true;
			date-format = "informal";
		};

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>e";
      command = "io.elementary.files -n ~/";
      name = "io.elementary.files -n ~/";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "<Alt>space";
      command = "ulauncher-toggle";
      name = "ulauncher-toggle";
    };

    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "suspend";
      sleep-inactive-ac-timeout = 0;
      sleep-inactive-ac-type = "nothing";
    };

		"org/gnome/settings-daemon/plugins/color" = {
			night-light-enabled = true;
		};

    "org/pantheon/desktop/gala/appearance" = {
      button-layout = ":minimize,maximize,close";
    };

    "org/pantheon/desktop/gala/behavior" = {
      dynamic-workspaces = false;
			move-fullscreened-workspace = true;
      overlay-action = "io.elementary.wingpanel --toggle-indicator=app-launcher";
    };

    "org/pantheon/desktop/gala/mask-corners" = {
      enable = false;
    };
  };

  gtk = {
    enable = true;
    cursorTheme = {
      name = "elementary";
      package = pkgs.pantheon.elementary-icon-theme;
      size = 32;
    };

    font = {
      name = "Work Sans 12";
      package = pkgs.work-sans;
    };

    iconTheme = {
      name = "elementary";
      package = pkgs.pantheon.elementary-icon-theme;
    };

    theme = {
      name = "io.elementary.stylesheet.blueberry";
      package = pkgs.pantheon.elementary-gtk-theme;
    };

    # Keep gtk4 apps matching the gtk3 theme above (nixpkgs default flipped to null).
    gtk4.theme = config.gtk.theme;
  };

  home.pointerCursor = {
    enable = true;
    package = pkgs.pantheon.elementary-icon-theme;
    name = "elementary";
    size = 32;
    gtk.enable = true;
    x11.enable = true;
  };

  home.file = {
    "${config.xdg.configHome}/autostart/enable-appcenter.desktop".text = ''
			[Desktop Entry]
			Name=Enable AppCenter
			Comment=Enable AppCenter
			Type=Application
			Exec=flatpak remote-add --user --if-not-exists appcenter https://flatpak.elementary.io/repo.flatpakrepo
			Categories=
			Terminal=false
			NoDisplay=true
			StartupNotify=false
		'';

    "${config.xdg.configHome}/autostart/ulauncher.desktop".text = ''
			[Desktop Entry]
			Name=Ulauncher
			Comment=Application launcher
			Type=Application
			Exec=${pkgs.ulauncher}/bin/ulauncher --hide-window
			Terminal=false
			NoDisplay=true
			StartupNotify=false
		'';
  };

}

