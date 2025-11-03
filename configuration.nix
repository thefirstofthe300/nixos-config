{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    ./users.nix
    ./postgres.nix
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = lib.mkDefault "x86_64-linux";
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.availableKernelModules =
      [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
    initrd.kernelModules = [ ];
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  nix = {
    settings.trusted-users = [ "root" "dseymour" ];
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  networking = {
    hostName = "the-brain";
    useDHCP = lib.mkDefault true;
    firewall = { allowedTCPPorts = [ 5432 ]; };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/12a37336-f3a6-4b69-82d4-0ffd7b5dbf24";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/09AD-BC21";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/31bac1f0-97c3-4426-8cb5-f362d65a99cd"; }];

  environment.systemPackages = with pkgs; [ ghostty.terminfo ];

  services.openssh.enable = true;
  system.stateVersion = "25.05";
}
