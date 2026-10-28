{ config, pkgs, ... }:
let
  backupDir = "/var/backup/postgresql";
  retentionDays = 2;
  pg = config.services.postgresql.package;
in {
  sops.secrets = {
    b2_account_id.sopsFile = ./secrets/postgres-backup.yaml;
    b2_account_key.sopsFile = ./secrets/postgres-backup.yaml;
    restic_password.sopsFile = ./secrets/postgres-backup.yaml;
  };

  sops.templates."postgres-backup-b2.env".content = ''
    B2_ACCOUNT_ID=''${config.sops.placeholder."b2_account_id"}
    B2_ACCOUNT_KEY=''${config.sops.placeholder."b2_account_key"}
  '';

  services.restic.backups.postgres-b2 = {
    repository = "b2:seymour-family-postgres:postgres";
    passwordFile = config.sops.secrets.restic_password.path;
    environmentFile = config.sops.templates."postgres-backup-b2.env".path;
    paths = [ backupDir ];
    pruneOpts = [ "--keep-daily 14" "--keep-weekly 8" "--keep-monthly 6" ];
    initialize = true;
    timerConfig = null;
  };

  systemd.services.postgresql-dump.onSuccess = [ "restic-backups-postgres-b2.service" ];

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
