{pkgs, config, home-manager, dotfiles, ...}:
{
  users.users.dseymour = {
    isNormalUser = true;
    description = "Daniel Seymour";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      _1password-cli
      nixfmt-rfc-style
    ];
    openssh = {
      authorizedKeys = {
        keys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDgQDqVl7DUf5l8SR/QnurZCY4DPDQAcgSVEUsWgQxQXGr5X29+EyKrfE+6AFuevD9mRFuJzPXd9I7AbJ4AjRjYG93/JMpzYRxJm2/534+BwzsOQbDMs0iVjYFEhTSlDnQFMA4DX/YoqMNukK9CC9xu2kiaIFqPe4ZEVTcUDxTiaoVQmP8wUWvrjY6k82i/kFKAs4AjI7JAzIwqj26wIP3bQUmPi+W+ZGSJx2hSQvbEJ+bqzj0rmk8Vud2RTExhdtVpiXv0CBzEWqSO+TPTgNu35lLGqwLREuKAfglcmGX0kRGAvFbdZE5G1F4D599FDdnjOH2btN8EEZwpioHUW52gPkroXk4bzI9QsAGmYcVl4wixCFdNhNXvSdFvfg7lqb/tduHXYwEutZDU4m+Gs20/GEZ4TftffzOS6NaecTF/Er/KysISAH8y2U1kpFRT/37LwCeasV05J2oowKtyW/8jFhUKBmdr47i1mGmTM6FpG47Wq5LwOChCIad+lp+BxqE="
        ];
      };
    };
  };
}
