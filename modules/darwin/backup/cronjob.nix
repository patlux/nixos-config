{ ... }:

{
  # Setup backup scripts and cronjob
  home.file."Library/LaunchAgents/de.patwoz.crontab.backuphome.plist".source = ./de.patwoz.crontab.backuphome.plist;
  home.file."Library/LaunchAgents/de.patwoz.crontab.backupdev.plist".source = ./de.patwoz.crontab.backupdev.plist;

  home.file.".bin/backup-home.sh".source = ./backup-home.sh;
  home.file.".bin/backup-dev.sh".source = ./backup-dev.sh;
}
