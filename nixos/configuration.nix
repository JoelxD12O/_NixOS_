# Configuración de NixOS
# https://search.nixos.org/options

{ config, lib, pkgs, ... }:

let
  zen-browser = import (builtins.fetchTarball "https://github.com/youwen5/zen-browser-flake/archive/master.tar.gz") { inherit pkgs; };
in
{
  # ============================================
  # IMPORTS
  # ============================================
  imports = [ ./hardware-configuration.nix ];

  # ============================================
  # BOOTLOADER
  # ============================================
  boot.loader = {
    timeout = 5;

    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };

    systemd-boot.enable = false;

    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
      gfxmodeEfi = "1280x720";
      timeoutStyle = "menu";
      configurationLimit = 3;

      theme = pkgs.fetchFromGitHub {
        owner = "callmenoodles";
        repo = "space-isolation";
        rev = "2f172f7cb6769bbef8dec62738ac168698c48985";
        sha256 = "sha256-YAzrqaTi9TvoSPsefYAW1ksMBu0yg92jAzFmk7l7shI=";
      } + "/1920x1080";
    };
  };

  # ============================================
  # NETWORKING & LOCALIZATION
  # ============================================
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "America/Lima";
  i18n.defaultLocale = "es_PE.UTF-8";
  services.xserver.xkb.layout = "latam";

  # ============================================
  # LOGIN & SESSION
  # ============================================
  # Login automático para el usuario joel
  services.getty.autologinUser = "joel";

  # Ejecutar Hyprland automáticamente en tty1
  environment.loginShellInit = ''
    if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
      exec hyprland
    fi
  '';

  # Variables de entorno para Wayland/Hyprland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
    GTK_THEME = "Adwaita:dark";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_QPA_PLATFORM = "wayland";
  };

  # ============================================
  # USUARIOS
  # ============================================
  users.mutableUsers = true;
  users.users.joel = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "input"
      "docker"
    ];
  };

  # ============================================
  # HARDWARE & SERVICIOS BASE
  # ============================================
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  # Programas del sistema
  programs.firefox.enable = true;
  programs.hyprland.enable = true;
  programs.hyprlock.enable = true;
  programs.git.enable = true;
  programs.nix-ld.enable = true;



  # ============================================
  # PAQUETES
  # ============================================
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    # Sistema base
    vim
    wget
    curl
    unzip

    # Git y desarrollo
    git
    github-cli

    # Terminal y CLI
    neovim
    kitty
    starship
    atuin
    blesh
    fastfetch
    btop
    ranger

    # Entorno Hyprland
    hyprlock
    hyprpaper
    hypridle
    waybar
    rofi
    dunst
    wev

    # Audio y multimedia
    pavucontrol
    playerctl
    pamixer
    easyeffects
    cava

    # Bluetooth
    blueman
    bluez

    # Brillo
    brightnessctl

    # Capturas de pantalla
    grim
    slurp
    wl-clipboard

    # Visualización de imágenes
    imv
    gimp

    # File managers
    kdePackages.dolphin
    kdePackages.qtwayland
    kdePackages.qtsvg
    kdePackages.kio-extras

    # Temas Qt
    adwaita-qt
    adwaita-qt6
    libsForQt5.qt5ct
    kdePackages.qt6ct
    libsForQt5.qtstyleplugin-kvantum

    # Cursores
    bibata-cursors

    # Fuentes
    terminus_font
    glib

    # Lenguajes de programación
    gcc
    gnumake
    python3
    pyright
    nodejs

    # Language servers
    nodePackages.intelephense
    typescript-language-server
    vscode-langservers-extracted

    # Herramientas para Neovim
    ripgrep
    fd

    # Navegadores
    zen-browser.default
    google-chrome

    # Aplicaciones
    zapzap
    discord
    spotify
    spicetify-cli
    obsidian
    vscode
    zoom-us
    postman
    

    # Juegos
    steam

    # Diversión
    cmatrix
    tty-clock

    # Seguridad
    wireshark

    # Utilidades NixOS
    nix-prefetch-github
    os-prober
    efibootmgr
    distrobox
    podman
  ];

  # ============================================
  # AUDIO (PipeWire)
  # ============================================
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # ============================================
  # BLUETOOTH
  # ============================================
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # ============================================
  # GAMING (Steam)
  # ============================================
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # ============================================
  # VIRTUALIZACIÓN (Docker)
  # ============================================
  virtualisation.docker = {
    enable = true;
  };


virtualisation.podman.enable = true;



  # ============================================
  # FUENTES
  # ============================================
  fonts.fontconfig.enable = true;
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.ubuntu-mono
    font-awesome
    # Nota: Icomoon-Feather debe instalarse manualmente en ~/.local/share/fonts/
    # Descargar de: https://github.com/adi1090x/rofi/blob/master/fonts/Icomoon-Feather.ttf
  ];

  # ============================================
  # OPTIMIZACIONES
  # ============================================
  nix.settings.auto-optimise-store = true;

  # ============================================
  # VERSION DEL SISTEMA
  # ============================================
  system.stateVersion = "25.11";
}
