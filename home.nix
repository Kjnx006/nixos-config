{ inputs, config, lib, pkgs, ... }:
let
  # REAPER wrapped with libsndfile
  reaper-with-libsndfile = pkgs.reaper.overrideAttrs (oldAttrs: {
    nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
    postInstall = (oldAttrs.postInstall or "") + ''
      wrapProgram $out/bin/reaper \
        --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [ pkgs.libsndfile ]}"
    '';
  });
   cfgdir = "${config.home.homeDirectory}/.config";
in
{

  imports = [
    inputs.matugen.nixosModules.default
    inputs.zen-browser.homeModules.twilight
  ];

  home = {
    username = "kaluna";
    homeDirectory = "/home/kaluna";
    stateVersion = "25.11";

   file.".local/share/icons".source = config.lib.file.mkOutOfStoreSymlink "/home/kaluna/Pictures/icons"; #icons symlink
   file."matugen/templates" = {
    source = ./templates;
    target = "${cfgdir}/matugen/templates";
    recursive = true;
   };
   file.".config/matugen/config2.toml".text = ''
[config]

[templates.cava]
input_path = '${./templates/cava-colors.ini}'
output_path = '${cfgdir}/cava/themes/matugen.ini'
post_hook = 'pkill -USR1 cava'

[templates.rmpc]
input_path = '${./templates/rmpc.ron}'
output_path = '${cfgdir}/rmpc/themes/matugen.ron'
  '';

    packages = with pkgs; [
      # -- System Tools & Utilities --
      fastfetch               # System info
      bat                     # Better 'cat'
      appimage-run            # use this if you want to run an AppImage
      pavucontrol             # Audio control GUI
      libnotify               # Notification denpendency
      yt-dlp                  # yt downloader
      qemu
      virt-manager
      kdePackages.kate

      # -- Desktop Environment & UI --
      waybar                  # Status bar
      swww                    # Wallpaper daemon
      swaynotificationcenter  # Notification center 
      rofi                    # App launcher / Menu
      wofi
      faugus-launcher         # Alternative launcher
      hyprshade
      nmgui
      yad

      # -- Audio Production (Pro Audio) --
      reaper-with-libsndfile  # DAW (Custom wrapper)
      libsndfile              # Library audio
      easyeffects             # System-wide audio effects
      yabridge                # VST bridge (Windows plugins)
      yabridgectl             # Control tool for yabridge
      
      # -- Multimedia & Graphics --
      mpv                     # Video player
      imv                     # Image viewer
      zathura                 # PDF viewer
      obs-studio              # Recording & streaming
      swappy                  # Screenshot editor
      slurp                   # Screen area selection
      grim                    # Screenshot tool
      
      # -- Social & Internet --
      vesktop                 # Discord client (optimized)
      vencord                 # Discord tweaks
      qbittorrent             # Torrent client
      thunderbird	      # Mail client
      
      # -- Gaming & Misc --
      heroic
      protonplus              # Proton manager (Wine/Steam)
      rmpc                    # Music player
      kdePackages.qtstyleplugin-kvantum
      kdePackages.qt6ct
    ];
    activation = {
  setDolphinIcons = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group Icons --key Theme "Fluent-teal-dark"
  '';
    };
  };

  gtk = {
    enable = true;
    theme = {
      name = "Qogir-Dark";
      #package = pkgs.nordic;
      package = pkgs.qogir-theme;
    };

    iconTheme = {
      name = "Fluent-teal-dark"; # Using local icons so I don't need nixpkgs
    };

    gtk3.extraConfig = {
      Settings = "gtk-application-prefer-dark-theme=1"; # for dark-theme
    };

    gtk4.extraConfig = {
      Settings = "gtk-application-prefer-dark-theme=1"; # for dark-theme
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "qt6ct";
    style.name = "kvantum";
  };

xdg = { 
  mimeApps = {
  enable = true;
  defaultApplications = { # < default app
    # Text & empty file
    "text/plain" = [ "nvim.desktop" ];
    "application/x-zerosize" = [ "nvim.desktop" ];

    # Directory
    "inode/directory" = [ "thunar.desktop" ];

    # Images
    "image/png"  = [ "imv.desktop" ];
    "image/jpeg" = [ "imv.desktop" ];
    "image/webp" = [ "imv.desktop" ];
    "image/gif"  = [ "imv.desktop" ];

    # Video
    "video/mp4" = [ "mpv.desktop" ];
    "video/x-matroska" = [ "mpv.desktop" ];

    # PDF
    "application/pdf" = [ "org.pwmt.zathura.desktop" ];

    # Archive → Ark
    "application/zip" = [ "org.kde.ark.desktop" ];
    "application/x-tar" = [ "org.kde.ark.desktop" ];
    "application/x-7z-compressed" = [ "org.kde.ark.desktop" ];
    "application/x-rar" = [ "org.kde.ark.desktop" ];
    };
  };
  configFile."mimeapps.list".force = true; # < force replacing the mimeapps file
};

systemd.user = {
   sessionVariables = {
     QT_QPA_PLATFORMTHEME = "qt6ct";
     QT_STYLE_OVERRIDE = "kvantum";
     QT_QPA_PLATFORM = "wayland";

     XDG_SESSION_TYPE = "wayland";
    
     ELECTRON_OZONE_PLATFORM_HINT = "auto";

     LIBVA_DRIVER_NAME = "nvidia";
     GBM_BACKEND = "nvidia-drm";
     __GLX_VENDOR_LIBRARY_NAME = "nvidia";
   };

# This is autostart service, idk this is work or not
   services = {

     swaync = {
       Unit = {
         Description = "Sway Notification Center";
         After = [ "graphical-session.target" ];
       };
       Service = {
         ExecStart = "${pkgs.swaynotificationcenter}/bin/swaync";
         Restart = "always";
       };
       Install.WantedBy = [ "graphical-session.target" ];
     };

     waybar = {
       Unit.After = [ "graphical-session.target" ];
       Service = {
         ExecStart = "${pkgs.waybar}/bin/waybar";
         Restart = "on-failure";
       };
       Install.WantedBy = [ "graphical-session.target" ];
     };

     swww = {
       Unit.After = [ "graphical-session.target" ];
       Service = {
         ExecStart = "${pkgs.swww}/bin/swww-daemon";
         Restart = "on-failure";
       };
       Install.WantedBy = [ "graphical-session.target" ];
     };
 };
};
programs = { 
   home-manager.enable = true; # Let Home Manager install and manage itself.
   zen-browser.enable = true;
   matugen.enable = true;
   git = {
    enable = true;
    settings.user.name = "Kjnx006";
    settings.user.email = "tempesto.music@gmail.com";
    settings = {
    init.defaultBranch = "main";
    };
   };
  };
}
