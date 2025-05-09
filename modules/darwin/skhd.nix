{ ... }: 

{

  services.skhd.enable = true;

  services.skhd.skhdConfig = "
# Restart yabai 
# shift + lctrl + alt - r : \
#     /usr/bin/env osascript <<< \
#         'display notification \"Restarting yabai\" with title \"yabai\"'; \
#     launchctl kickstart -k \"gui/\${UID}/homebrew.mxcl.yabai\"

shift + lctrl + alt - r : \
    /usr/bin/env osascript <<< \
        'display notification \"Restarting yabai\" with title \"yabai\"'; \
    launchctl kickstart -k gui/$(id -u)/org.nixos.yabai
    # killall yabai; \
    # yabai --stop-service; \
    # yabai --start-service

# Reload skhd 
shift + lctrl + alt - s : \
    /usr/bin/env osascript <<< \
        'display notification \"Reload skhd\" with title \"skhd\"'; \
    skhd -r

# Navigation
lalt - h : yabai -m window --focus west
lalt - j : yabai -m window --focus south
lalt - k : yabai -m window --focus north
lalt - l : yabai -m window --focus east

# Moving windows
lctrl + cmd - h : yabai -m window --warp west
lctrl + cmd - j : yabai -m window --warp south
lctrl + cmd - k : yabai -m window --warp north
lctrl + cmd - l : yabai -m window --warp east

# Float / Unfloat window
shift + alt - space : \
    yabai -m window --toggle float; \
    yabai -m window --toggle border

# Split windows
alt - s : yabai -m window --toggle split 

# Balance Windows
shift + alt - 0 : yabai -m space --balance

# Adjust window size
shift + alt - h : yabai -m window --resize left:-20:0
lctrl + alt - h : yabai -m window --resize left:20:0

shift + alt - l : yabai -m window --resize right:20:0
lctrl + alt - l : yabai -m window --resize right:-20:0

shift + alt - j : yabai -m window --resize bottom:0:20
lctrl + alt - j : yabai -m window --resize bottom:0:-20

shift + alt - k : yabai -m window --resize top:0:-20
lctrl + alt - k : yabai -m window --resize top:0:20
  ";



  }
