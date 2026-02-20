{
  config,
  lib,
  pkgs,
  ...
}:

{
  home.file.".config/ghostty/config".source = ./files/ghostty.config;

  home.file."Library/Application Support/com.mitchellh.ghostty/config" =
    lib.mkIf pkgs.stdenv.isDarwin
      {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/ghostty/config";
        force = true;
      };
}
