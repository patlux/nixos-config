{ ... }:

{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };


  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ll = "ls -lah";
      gs = "git status";
      update = "sudo nixos-rebuild switch --flake ~/.config/nixos#nixos";
    };
  };
}


