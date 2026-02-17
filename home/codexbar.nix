{ pkgs, ... }:

let
  codexbar = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "codexbar";
    version = "0.17.0";

    src = pkgs.fetchurl {
      url = "https://github.com/steipete/CodexBar/releases/download/v${version}/CodexBar-${version}.zip";
      hash = "sha256-LD86SQCPLi/yZOSjatAntcFA1hwzGsLnrOLB/5sMadw=";
    };

    nativeBuildInputs = [ pkgs.unzip ];

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/Applications" "$out/bin"
      cp -R "CodexBar.app" "$out/Applications/"
      ln -s "$out/Applications/CodexBar.app/Contents/MacOS/CodexBar" "$out/bin/codexbar"

      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Tiny macOS menu bar app to track AI usage limits";
      homepage = "https://github.com/steipete/CodexBar";
      license = licenses.mit;
      platforms = platforms.darwin;
      sourceProvenance = [ sourceTypes.binaryNativeCode ];
    };
  };
in
{
  home.packages = [ codexbar ];

  home.file."Applications/CodexBar.app".source = "${codexbar}/Applications/CodexBar.app";
}
