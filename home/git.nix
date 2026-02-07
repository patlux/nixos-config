{ ... }:

{
  programs.git = {
    enable = true;
    userName = "Patrick Wozniak";
    userEmail = "email@patwoz.de";

    lfs.enable = true;
    delta = {
      enable = true;
      options = {
        navigate = true;
        line-numbers = true;
        syntax-theme = "TwoDark";
      };
    };

    signing.key = "0D4DE3BE5B9D660B";
    signing.signByDefault = true;

    aliases = {
      co = "checkout";
      ci = "commit";
      br = "branch";
      st = "status -sb";
      lg = "log --oneline --graph --decorate";
      last = "log -1 HEAD";
      unstage = "reset HEAD --";
      amend = "commit --amend --no-edit";
      pushf = "push --force-with-lease";
      cleanup = "!git branch --merged | grep -v '\\*\\|master\\|main\\|develop' | xargs -n 1 git branch -d";
    };

    extraConfig = {
      github = {
        username = "patlux";
      };
      core = {
        editor = "nvim";
      };
      color.ui = true;
      pull.rebase = true;
      push = {
        followTags = true;
        autoSetupRemote = true;
      };
      init.defaultBranch = "main";
    };

    ignores = [
      "opencode.json"
      ".opencode/"
    ];

    includes = [
      {
        condition = "gitdir:~/dev/enerparc/";
        contents.user.email = "p.wozniak@enerparc.com";
        contents.commit.gpgSign = false;
      }
      {
        condition = "gitdir:~/dev/mueller/";
        contents.user.email = "wozniak.ext@mueller.de";
        contents.commit.gpgSign = true;
      }
      {
        condition = "gitdir:~/dev/ibm/";
        contents.user.email = "patrick.wozniak1@ext.ibmix.de";
        contents.commit.gpgSign = true;
      }
    ];
  };
}
