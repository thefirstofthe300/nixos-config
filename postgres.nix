{ config, pkgs, ... }:
{
  config.services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
    ensureDatabases = [ "synapse" "immich" ];
    enableTCPIP = true;
    authentication = pkgs.lib.mkOverride 10 ''
      #...
      #type database DBuser origin-address auth-method
      local all       all     trust
      # ipv4
      host  all      all     192.168.1.0/24   trust
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
