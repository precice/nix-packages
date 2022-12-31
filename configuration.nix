{ config, pkgs, lib, ... }:
{
  nixpkgs.overlays = lib.mkBefore (import ./precice-packages);
  nixpkgs.config.allowUnfree = true;

  home-manager.users.precice = { pkgs, ... }: {
    home.stateVersion = "22.11";
    home.file = {
      "keyboard-settings" = {
        source = "${pkgs.xfce.xfce4-settings.out}/share/applications/xfce-keyboard-settings.desktop";
        target = "Desktop/xfce-keyboard-settings.desktop";
      };
      "precice-desktop-item" = {
        source = "${pkgs.makeDesktopItem {
          name = "get-started";
          desktopName = "Get started";
          type = "Link";
          url = "https://precice.org/installation-vm.html";
          icon = "text-html";
        }}/share/applications/get-started.desktop";
        target = "Desktop/get-started.desktop";
        executable = true;
      };
    # TODO: examples verlinken auf dem desktop
    };
    programs.bash.enable = true;
  };

  networking.hostName = "precice-vm";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "us";

  documentation = {
    enable = false;
    nixos.enable = false;
  };

  services.xserver = {
    enable = true;
    layout = "us";
    desktopManager.xfce.enable = true;
    displayManager.autoLogin = {
      enable = true;
      user = "precice";
    };
  };

  virtualisation.virtualbox.guest.enable = true;

  users.users.precice = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "precice";
  };

  environment.systemPackages = with pkgs; let
    precice-python-packages = python3.withPackages (ps: with ps; [
      ipython
    ]);
    preciceToPNG = writeShellScriptBin "preciceToPNG" "cat \"\${1:-precice-config.xml}\" | ${precice-config-visualizer}/bin/precice-config-visualizer | ${graphviz}/bin/dot -Tpng > precice-config.png";
    preciceToPDF = writeShellScriptBin "preciceToPDF" "cat \"\${1:-precice-config.xml}\" | ${precice-config-visualizer}/bin/precice-config-visualizer | ${graphviz}/bin/dot -Tpdf > precice-config.pdf";
    preciceToSVG = writeShellScriptBin "preciceToSVG" "cat \"\${1:-precice-config.xml}\" | ${precice-config-visualizer}/bin/precice-config-visualizer | ${graphviz}/bin/dot -Tsvg > precice-config.svg";
  in [
    # Basic applications
    baobab
    catfish
    firefox
    mate.atril
    terminator
    tree

    # Devel applications
    stdenv
    git
    cmakeWithGui
    nano
    neovim
    gnome.gedit
    precice-python-packages
    gnuplot

    # Precice
    precice
    precice-config-visualizer

    precice-dealii-adapter
    precice-calculix-adapter
    precice-aste

    # From the .alias file in the VM repo
    preciceToPNG
    preciceToPDF
    preciceToSVG

    # Additional packages
    paraview
    wget

  ];

  # programs.home-manager.enable = true;

  services.openssh.enable = true;

  system.stateVersion = "22.11";
}
