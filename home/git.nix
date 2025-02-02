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
      dff = "difftool --no-symlinks --dir-diff";
    };

    extraConfig = {
      github = {
        username = "patlux";
      };
      core = {
        editor = "nvim";
      };
      color = {
        ui = true;
        "diff-highlight".oldNormal = "red bold";
        "diff-highlight".oldHighlight = "red bold 52";
        "diff-highlight".newNormal = "green bold";
        "diff-highlight".newHighlight = "green bold 22";
        "diff".meta = "yellow";
        "diff".frag = "magenta bold";
        "diff".commit = "yellow bold";
        "diff".old = "red bold";
        "diff".new = "green bold";
        "diff".whitespace = "red reverse";
      };
      pull.rebase = false;
      diff = {
        tool = "kitty";
        guitool = "kitty.gui";
      };
      difftool = {
        prompt = false;
        trustExitCode = true;
        "kitty".cmd = "kitty +kitten diff $LOCAL $REMOTE";
        "kitty.gui".cmd = "kitty kitty +kitten diff $LOCAL $REMOTE";
      };
      filter.lfs = {
        smudge = "git-lfs smudge -- %f";
        process = "git-lfs filter-process";
        required = true;
        clean = "git-lfs clean -- %f";
      };
      push = {
        followTags = true;
        autoSetupRemote = true;
      };
      init.defaultBranch = "main";
      "branch \"master\"".rebase = false;
      "branch \"main\"".rebase = false;
    };

    includes = [
      {
        condition = "gitdir:~/dev/enerparc/";
        contents.user.email = "p.wozniak@enerparc.com";
        contents.commit.gpgSign = false;
      }
      {
        condition = "gitdir:~/dev/ibm/";
        contents.user.email = "Patrick.Wozniak@ext.aperto.com";
      }
    ];
  };
}


