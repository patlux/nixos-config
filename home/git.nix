{ ... }:

{
  programs.git = {
    enable = true;
    userName = "Patrick Wozniak";
    userEmail = "email@patwoz.de";

    lfs.enable = true;
    delta = { enable = true; };

    signing.key = "0D4DE3BE5B9D660B";
    signing.signByDefault = true;

    aliases = {
      co = "checkout";
      ci = "commit";
      br = "branch";
      pushf = "push --force-with-lease";
      cleanup = "!git branch --merged | grep  -v '\\*\\|master\\|develop' | xargs -n 1 git branch -d";
    };

    extraConfig = {
      github = {
        username = "patlux";
      };
      core = {
        editor = "nvim";
      };
      color.ui = true;
      pull.rebase = false;
      push = {
        followTags = true;
        autoSetupRemote = true;
      };
      init.defaultBranch = "main";
      "branch \"master\"".rebase = false;
      "branch \"main\"".rebase = false;
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


