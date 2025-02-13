{ ... }: 


{
  services.yabai.enable = true;

  services.yabai.config = {
    mouse_follows_focus = "off";
    focus_follows_mouse = "off";
    window_placement = "second_child";
    window_shadow = true;
    window_opacity = false;
    window_opacity_duration = 0.0;
    active_window_opacity = 1.0;
    normal_window_opacity = 0.90;
    insert_feedback_color = "0xffd75f5f";
    split_ratio = 0.50;
    auto_balance = false;
    mouse_modifier = "fn";
    mouse_action1 = "move";
    mouse_action2 = "resize";
    mouse_drop_action = "swap";
    layout = "bsp";
    top_padding = 10;
    bottom_padding = 10;
    left_padding = 10;
    right_padding = 10;
    window_gap = 6;
  };

  services.yabai.extraConfig = ''
    yabai -m rule --add label="About This Mac" app="System Information" title="About This Mac" manage=off
    yabai -m rule --add app="^System Settings$" manage=off
    yabai -m rule --add label="Software Update" title="Software Update" manage=off
    yabai -m rule --add label="Finder" app="^Finder$" title="(Co(py|nnect)|Move|Info|Pref)" manage=off
    yabai -m rule --add label="Safari" app="^Safari$" title="^(General|(Tab|Password|Website|Extension)s|AutoFill|Se(arch|curity)|Privacy|Advance)$" manage=off
    yabai -m rule --add label="The Unarchiver" app="^The Unarchiver$" manage=off
    yabai -m rule --add label="ScreenTray" app="^ScreenTray$" manage=off
    yabai -m rule --add app="^Simulator$" manage=off sticky=on
    yabai -m rule --add title="^iPhone.*" manage=off sticky=on
    yabai -m rule --add title="^Android Emulator.*" manage=off sticky=on
    yabai -m rule --add app="^CleanShot X$" sticky=on manage=off
    yabai -m rule --add app="Petit Player" sticky=on manage=off
    yabai -m rule --add app="Bezel" sticky=on manage=off
    yabai -m rule --add title=".*raylib.*" manage=off sticky=on
    
    # https://github.com/koekeishiya/yabai/issues/68#issuecomment-2395591920
    # yabai -m signal --add app='^Ghostty$' event=window_created action='yabai -m space --layout bsp'
    # yabai -m signal --add app='^Ghostty$' event=window_destroyed action='yabai -m space --layout bsp'
    
    yabai -m signal --add app='^Ghostty$' event=window_created action='yabai -m space --focus next; sleep 0.01; yabai -m space --focus prev'
    yabai -m signal --add app='^Ghostty$' event=window_destroyed action='yabai -m space --focus next; sleep 0.01; yabai -m space --focus prev'
    yabai -m signal --add app='^Finder$' event=window_created action='yabai -m space --focus next; sleep 0.01; yabai -m space --focus prev'
    yabai -m signal --add app='^Finder$' event=window_destroyed action='yabai -m space --focus next; sleep 0.01; yabai -m space --focus prev'
  '';

}
