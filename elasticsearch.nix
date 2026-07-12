{ config, ... }: {
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.defaultSopsFile = ./secrets/tubearchivist.yaml;

  sops.secrets."elastic_password" = {};

  sops.templates."tubearchivist-es.env" = {
    content = ''
      ELASTIC_PASSWORD=${config.sops.placeholder."elastic_password"}
    '';
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/tubearchivist/elasticsearch 0755 1000 1000 -"
  ];

  virtualisation.podman.enable = true;
  virtualisation.oci-containers.backend = "podman";

  virtualisation.oci-containers.containers.tubearchivist-es = {
    image = "bbilly1/tubearchivist-es:8.19.0";
    environment = {
      ES_JAVA_OPTS = "-Xms1g -Xmx1g";
      "xpack.security.enabled" = "true";
      "xpack.security.http.ssl.enabled" = "false";
      "discovery.type" = "single-node";
      "network.host" = "0.0.0.0";
      "path.repo" = "/usr/share/elasticsearch/data/snapshot";
    };
    environmentFiles = [ config.sops.templates."tubearchivist-es.env".path ];
    ports = [ "9200:9200" ];
    volumes = [ "/var/lib/tubearchivist/elasticsearch:/usr/share/elasticsearch/data" ];
    extraOptions = [
      "--ulimit=memlock=-1:-1"
    ];
  };
}
