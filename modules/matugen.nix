{ inputs, config, lib, ... }:

let
  cfgdir = "${config.home.homeDirectory}/.config";
in {
  imports = [
    inputs.matugen.nixosModules.default
  ];

 
    programs.matugen = {
      enable = true;
     
    };

    # Copy semua templates secara recursive
    home.file.".config/matugen/templates" = {
      source = ./templates;
      target = "${cfgdir}/matugen/templates";
      recursive = true;
    };

    # Config TOML Matugen
    home.file.".config/matugen/config.toml".text = ''
[config]
      
[templates.rmpc]
input_path = '${./templates/rmpc.ron}'
output_path = '${cfgdir}/rmpc/themes/matugen.ron'

[templates.qt5ct]
input_path = '${./templates/qtct-colors.conf}'
output_path = '${cfgdir}/matugen/generated/qt5ct-colors.conf'

[templates.qt6ct]
input_path = '${./templates/qtct-colors.conf}'
output_path = '~/.config/matugen/generated/qt6ct-colors.conf'

[templates.swaync]
input_path = '${./templates/colors.css}'
output_path = '${cfgdir}/matugen/generated/swaync-colors.css'
post_hook = 'swaync-client -rs || true'

[templates.swayosd]
input_path = '${./templates/swayosd-colors.css}'
output_path = '${cfgdir}/matugen/generated/swayosd-colors.css'
post_hook = '~/user_scripts/swayosd/restart_swayosd.sh'

[templates.kitty]
input_path = '${./templates/kitty-colors.conf}'
output_path = '${cfgdir}/matugen/generated/kitty-colors.conf'
post_hook = 'ln -nfs $HOME/.config/matugen/generated/kitty-colors.conf $HOME/.config/kitty/kitty-colors.conf; pkill -SIGUSR1 kitty || true'

[templates.neovim]
input_path = '${./templates/neovim/template.lua}'
output_path = '${cfgdir}/matugen/generated/neovim-colors.lua'
post_hook = 'pkill -SIGUSR1 nvim || true'

[templates.yazi]
input_path = '${./templates/yazi-theme.toml}'
output_path = '${cfgdir}/matugen/generated/yazi-theme.toml'
post_hook = 'ln -nfs $HOME/.config/matugen/generated/yazi-theme.toml $HOME/.config/yazi/theme.toml'

[templates.zathura]
input_path = '${./templates/zathura-colors}'
output_path = '${cfgdir}/matugen/generated/zathura-colors'
post_hook = 'ln -nfs ${cfgdir}/matugen/generated/zathura-colors ${cfgdir}/zathura/zathurarc'

[templates.starship]
input_path = '${./templates/starship-colors.toml}'
output_path = '${cfgdir}/matugen/generated/starship-colors.toml'
post_hook = 'ln -nfs ${cfgdir}/matugen/generated/starship-colors.toml ${cfgdir}/starship.toml'

[templates.tmux]
input_path = '${./templates/tmux-colors.conf}'
output_path = '${cfgdir}/matugen/generated/tmux-colors.conf'
post_hook = 'tmux source-file ${cfgdir}/matugen/generated/tmux-colors.conf' 

[templates.btop]
input_path = '${./templates/btop.theme}'
output_path = '${cfgdir}/matugen/generated/btop-colors.theme'
post_hook = 'mkdir -p ${cfgdir}/btop/themes; ln -nfs ${cfgdir}/matugen/generated/btop-colors.theme ${cfgdir}/btop/themes/matugen.theme'

[templates.rofi]
input_path = '${./templates/rofi-colors.rasi}'
output_path = '${cfgdir}/matugen/generated/rofi-colors.rasi'

[templates.hyprland]
input_path = '${./templates/hyprland-colors.conf}'
output_path = '${cfgdir}/matugen/generated/hyprland-colors.conf'
post_hook = 'hyprctl reload'

[templates.hyprlock]
input_path = '${./templates/hyprlock-colors.conf}'
output_path = '${cfgdir}/matugen/generated/hyprlock-colors.conf'

[templates.wlogout]
input_path = '${./templates/colors.css}'
output_path = '${cfgdir}/matugen/generated/wlogout-colors.css'

[templates.cava]
input_path = '${./templates/cava-colors.ini}'
output_path = '${cfgdir}/matugen/generated/cava-colors.ini'
post_hook = 'mkdir -p ${cfgdir}/cava/themes; ln -nfs ${cfgdir}/matugen/generated/cava-colors.ini ${cfgdir}/cava/themes/cava-colors.ini; pkill -USR1 cava || true'

[templates.waybar]
input_path = '${./templates/colors.css}'
output_path = '${cfgdir}/matugen/generated/waybar-colors.css'
post_hook = 'pkill -SIGUSR2 waybar || true; notify-send "Theme Updated"'

[templates.wofi]
input_path = '${./templates/colors.css}'
output_path = '${cfgdir}/wofi/colors.css'

[templates.kvantum_kvconfig]
input_path = '${./templates/kvantum-colors.kvconfig}'
output_path = '${cfgdir}/Kvantum/matugen/matugen.kvconfig'

[templates.kvantum_svg]
input_path = '${./templates/kvantum-colors.svg}'
output_path = '${cfgdir}/Kvantum/matugen/matugen.svg'
'';
}

