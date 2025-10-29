{ pkgs, ... }: 

{

  programs.gpg = {
    enable = true;
    settings = {
      auto-key-retrieve = true;
      no-emit-version = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 600;       # 10 min
    maxCacheTtl = 7200;          # 2 h
    pinentry = { package = pkgs.pinentry_mac; };
  };
}
