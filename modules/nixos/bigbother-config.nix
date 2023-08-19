{ username, fullname, nixversion,  pkgs,  ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-${nixversion}.tar.gz";
  plasma-manager = builtins.fetchGit {
    url = "github:pjones/plasma-manager";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.home-manager.follows = "home-manager";
  };
in
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  imports = [
    (import "${home-manager}/nixos")
  ];

  environment.systemPackages = with pkgs; [
    microsoft-edge
  ];

  home-manager.users.${username} = {
    home = {
      packages = with pkgs; [
        vim
        neofetch
      ];
      shellAliases = { 
        nano = "vim";
      };
    };
    home.stateVersion = "${nixversion}";
    
  };

  users.users.${username} = {
    isNormalUser = true;
    home = "/home/${username}";
    description = "${fullname}'s user";
    extraGroups = [ "wheel" "networkmanager" ];
  };
  boot.plymouth = { 
    enable = true;
    logo = ./logo.png; 
  };
  boot.loader.grub = { 
    extraEntries = ''
    menuentry "Accidental boot protection" {
    
      echo "Accidental boot avoided, shutting down."
      sleep 3
      clear
      echo "Accidental boot avoided, shutting down.."
      sleep 1
      clear
      echo "Accidental boot avoided, shutting down..."
      sleep 3
      halt
    } 
    '';
    extraConfig = "set theme=($drive2)${pkgs.breeze-grub}/grub/themes/breeze/theme.txt";
    splashImage = null;
    extraEntriesBeforeNixOS = true;
  };

  services.xserver.displayManager.sddm.settings.Users = {
    RememberLastUser = false;
    RememberLastSession = false;
    MinimumUid = "10000";
  };

  xdg.mime.defaultApplications = {
    "text/html" = [ "microsoft-edge-dev.desktop" ]; # The .desktop name might differ
    "x-scheme-handler/http" = [ "microsoft-edge-dev.desktop" ];
    "x-scheme-handler/https" = [ "microsoft-edge-dev.desktop" ];
    "application/xhtml+xml" = [ "microsoft-edge-dev.desktop" ];
    "image/webp" = [ "microsoft-edge-dev.desktop" ];
  };

  environment.etc = {
    "/bb-sudoers.lecture".text = ''
      You are trying to run a command with root privileges, hopefully you know what you're about to do.
    '';
    "/neofetch/config.conf".text = ''
    print_info() {
      info title
      info underline
      prin "They call me Stacy"
      #info "Kernel" kernel
      info "Uptime" uptime
      info "Shell" shell
      info "Resolution" resolution
      info "WM" wm
      info "WM Theme" wm_theme
      info "Theme" theme
    }
    '';
  };

  security.sudo.extraConfig = ''
  Defaults  badpass_message = "Wrong password, maybe try to type it correctly next time?"
  Defaults  lecture = always
  Defaults  lecture_file = /etc/bb-sudoers.lecture
  '';

}