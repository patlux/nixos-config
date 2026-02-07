{ ... }:

{
  # Backup scripts
  home.file.".bin/backup-home.sh".source = ./backup-home.sh;
  home.file.".bin/backup-dev.sh".source = ./backup-dev.sh;

  # LaunchAgents - these are automatically loaded/unloaded by home-manager
  launchd.agents.backuphome = {
    enable = true;
    config = {
      Label = "de.patwoz.crontab.backuphome";
      ProgramArguments = [ "/Users/patwoz/.bin/backup-home.sh" ];
      StartCalendarInterval = [
        {
          Hour = 10;
          Minute = 20;
        }
      ];
      RunAtLoad = true;
      StandardErrorPath = "/tmp/de.patwoz.crontab.backuphome.err";
      StandardOutPath = "/tmp/de.patwoz.crontab.backuphome.out";
    };
  };

  launchd.agents.backupdev = {
    enable = true;
    config = {
      Label = "de.patwoz.crontab.backupdev";
      ProgramArguments = [ "/Users/patwoz/.bin/backup-dev.sh" ];
      StartCalendarInterval = [
        {
          Hour = 10;
          Minute = 10;
        }
      ];
      RunAtLoad = true;
      StandardErrorPath = "/tmp/de.patwoz.crontab.backupdev.err";
      StandardOutPath = "/tmp/de.patwoz.crontab.backupdev.out";
    };
  };
}
