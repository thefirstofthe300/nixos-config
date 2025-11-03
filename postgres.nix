{ config, pkgs, ... }: {
  config.services.postgresql = with pkgs; {
    enable = true;
    package = postgresql_17;
    extensions =
      [ postgresql17Packages.vectorchord postgresql17Packages.pgvector ];
    settings = { shared_preload_libraries = [ "vchord.so" ]; };
    ensureDatabases = [
      "synapse"
      "immich"
      "nextcloud"
      "authentik"
      "mas"
      "mautrix-discord"
      "mautrix-signal"
      "mautrix-gmessages"
      "mautrix-telegram"
    ];
    ensureUsers = [
      {
        name = "synapse";
        ensureDBOwnership = true;
      }
      {
        name = "immich";
        ensureDBOwnership = true;
      }
      {
        name = "nextcloud";
        ensureDBOwnership = true;
      }
      {
        name = "authentik";
        ensureDBOwnership = true;
      }
      {
        name = "mas";
        ensureDBOwnership = true;
      }
      {
        name = "mautrix-discord";
        ensureDBOwnership = true;
      }
      {
        name = "mautrix-signal";
        ensureDBOwnership = true;
      }
      {
        name = "mautrix-gmessages";
        ensureDBOwnership = true;
      }
      {
        name = "mautrix-telegram";
        ensureDBOwnership = true;
      }
    ];

    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      #...
      #type database DBuser origin-address auth-method
      local all       all     trust
      # ipv4
      host  all      all     192.168.1.0/24   trust
      host  all      all     10.0.0.0/8   trust
      # ipv6
      host all       all     ::1/128        trust
      local sameuser  all     peer        map=superuser_map
    '';
    identMap = ''
      # ArbitraryMapName systemUser DBUser
      superuser_map      root      postgres
      superuser_map      postgres  postgres
      # Let other names login as themselves
      superuser_map      /^(.*)$   \1
    '';
  };
}
