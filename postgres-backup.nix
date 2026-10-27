{ config, pkgs, ... }:
let
  backupDir = "/var/backup/postgresql";
  retentionDays = 7;
  pg = config.services.postgresql.package;
in {
  systemd.tmpfiles.rules = [ "d ${backupDir} 0700 postgres postgres -" ];

  systemd.services.postgresql-dump = {
    description = "Nightly PostgreSQL dump of every database";
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
    path = [ pg pkgs.coreutils pkgs.findutils ];
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
    };
    script = ''
      set -euo pipefail
      stamp=$(date +%Y-%m-%d)
      dest=${backupDir}/$stamp
      tmp=$dest.partial
      rm -rf "$tmp"
      mkdir -p "$tmp"

      pg_dumpall --globals-only > "$tmp/globals.sql"
      for db in $(psql -Atc "select datname from pg_database where datallowconn and not datistemplate"); do
        pg_dump --format=custom --file="$tmp/$db.dump" "$db"
      done

      rm -rf "$dest"
      mv "$tmp" "$dest"
      find ${backupDir} -mindepth 1 -maxdepth 1 -type d -mtime +${toString retentionDays} -exec rm -rf {} +
    '';
  };

  systemd.timers.postgresql-dump = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 02:30:00";
      Persistent = true;
    };
  };
}
