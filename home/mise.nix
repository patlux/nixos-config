{ pkgs, ... }:

{
  home.packages = with pkgs; [
    mise
  ];

  programs.mise = {
    enable = true;

    globalConfig.tools = {
      ruby = "2.7.6";
      java = "adoptopenjdk-17.0.9+9";
      node = "20.11.0";
      python = "3.12.2";
      zig = "0.13.0";
      go = "1.23.1";
      yarn = "1.22.22";
      bun = "1.2.10";
    };
  };

  home.file.".default-npm-packages".source = ./files/.default-npm-packages;
}

