{ ... }:


{
  imports = [
    ../../home/core.nix
    ../../home/git.nix
    ../../home/gnupg.nix
    ../../home/mise.nix
    ../../home/packages.nix
    ../../home/ruby.nix
    ../../home/shell.nix
  ];

  programs.zsh.shellAliases.update = "darwin-rebuild switch --flake ~/.config/nixos\\#mbpromax";
}
