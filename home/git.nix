{ ... }:

{
  programs.git = {
    enable = true;
    userName = "Patrick Wozniak";
    userEmail = "email@patwoz.de";

    lfs.enable = true;

    signing.key = "0D4DE3BE5B9D660B";
    signing.signByDefault = true;
    delta = { enable = true; };
    aliases = { co = "checkout"; ci = "commit"; br = "branch"; pushf = "push --force-with-lease"; };
    includes = [
      {
        condition = "gitdir:~/dev/pdg";
        contents = {
          user = {
            email = "patrick.wozniak.extern@porsche.digital";
            name = "Patrick Wozniak";
            signingKey = "B33CA176B9EF9ECFE39CFCEC1A32081F816CE44F";
          };
          commit = {
            gpgSign = true;
          };
        };
      }
    ];
  };
}


