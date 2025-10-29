{ pkgs, ... }:

{
  # home.packages = with pkgs; [
  #   mise
  # ];

  programs.mise = {
    enable = true;

    globalConfig.tools = {
      ruby = "2.7.6";
      java = "adoptopenjdk-17.0.9+9";
      node = "22.21.0";
      python = "3.12.2";
      zig = "0.15.1";
      go = "1.25.1";
      yarn = "1.22.22";
      bun = "1.2.21";
      # bazel = "8.2.1";
      bazelisk = "1.26.0";
    };

    globalConfig.settings = {
      idiomatic_version_file_enable_tools = ["node" "ruby"];
    };
  };

  home.file.".default-npm-packages".source = ./files/.default-npm-packages;
}

