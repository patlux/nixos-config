{ ... }: 

{
  programs.zsh.initExtra = ''
    export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk
    export ANDROID_HOME=$HOME/Library/Android/sdk
    # export ANDROID_AVD_HOME=/Volumes/home/VMS/Android-Emulator
    export PATH=$ANDROID_SDK_ROOT/tools:$PATH
    export PATH=$ANDROID_SDK_ROOT/tools/bin:$PATH
    export PATH=$ANDROID_SDK_ROOT/platform-tools:$PATH
    # \"Android SDK Command-line Tools (latest)\" needs to be installed (See SETUP_MACOS.md)
    export PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH
  '';
}
