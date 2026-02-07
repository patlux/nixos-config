{ ... }:

{
  power.sleep.display = 5; # Display off after 5 min idle
  power.sleep.computer = 15; # Sleep after 15 min idle
  power.sleep.harddisk = 10; # Spin down disks after 10 min
  power.restartAfterFreeze = true; # Auto-restart after kernel panic

  system.activationScripts.powerManagement.text = ''
    # Disable Power Nap (wakes CPU/Wi-Fi/disk periodically during sleep)
    sudo pmset -a powernap 0

    # Disable Wake on LAN on AC power (prevents network-triggered wakes)
    sudo pmset -c womp 0
  '';
}
