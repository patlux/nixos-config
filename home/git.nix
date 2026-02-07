{ ... }:

{
  programs.git = {
    enable = true;

    lfs.enable = true;

    signing.key = "0D4DE3BE5B9D660B";
    signing.signByDefault = true;

    settings = {
      user = {
        name = "Patrick Wozniak";
        email = "email@patwoz.de";
      };
      alias = {
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
      github.username = "patlux";
      core.editor = "nvim";
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

  # Delta (git pager / diff viewer) - separated from git in newer home-manager
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
      syntax-theme = "TwoDark";
    };
  };
}
