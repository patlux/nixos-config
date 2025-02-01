{ ... }: 

{
  home.file.".gemrc".text = ''
    gem: --user-install --env-shebang --no-document
  '';
}
