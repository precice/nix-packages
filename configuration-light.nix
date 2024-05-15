{
  pkgs,
  lib,
  config,
  ...
}:
{
  nixpkgs.overlays = lib.mkBefore (import ./precice-packages);
  nixpkgs.config = {
    allowUnfree = true;
  };
  home-manager.users.precice =
    { pkgs, ... }:
    {
      home.stateVersion = "22.11";
      home.file = {
        "keyboard-settings" = {
          source = "${pkgs.xfce.xfce4-settings.out}/share/applications/xfce-keyboard-settings.desktop";
          target = "Desktop/xfce-keyboard-settings.desktop";
        };
        "precice-desktop-item" = {
          source = "${
            pkgs.makeDesktopItem {
              name = "get-started";
              desktopName = "Get started";
              type = "Link";
              url = "https://precice.org/installation-vm.html";
              icon = "text-html";
            }
          }/share/applications/get-started.desktop";
          target = "Desktop/get-started.desktop";
          executable = true;
        };
        # TODO: precice examples verlinken auf dem desktop
        "terminator" = {
          source = "${pkgs.terminator}/share/applications/terminator.desktop";
          target = "Desktop/terminator.desktop";
        };
        "terminator-config" = {
          text = ''
            [profiles]
            [[default]]
            use_system_font = False
          '';
          target = ".config/terminator/config";
        };
        # TODO: fix this
        # "vagrant-shared" = {
        #   source = "/vagrant/";
        #   target = "Desktop/shared";
        # };
        # XXX: Untested as the default VM ist too small
        "run-vs-code" = {
          source = "${
            pkgs.makeDesktopItem {
              name = "run-vs-code";
              desktopName = "VS Code";
              type = "Application";
              exec = pkgs.writeScript "run-vs-code" ''
                echo "Downloading and starting vscode, please leave this terminal open..."
                nix-shell ${./vscode.nix} --run code 2> /dev/null
              '';
              terminal = true;
              icon = "text-html";
            }
          }/share/applications/run-vs-code.desktop";
          target = "Desktop/run-vs-code.desktop";
          executable = true;
        };
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
    desktopManager.xfce = {
      enable = true;
      enableScreensaver = false;
    };
    displayManager.autoLogin = {
      enable = true;
      user = "precice";
    };
  };

  # This is all needed to make resizing work inside the VirtualBox VM
  virtualisation.virtualbox.guest.enable = true;
  systemd.user.services =
    let
      vbox-client = desc: flags: {
        description = "VirtualBox Guest: ${desc}";

        wantedBy = [ "graphical-session.target" ];
        requires = [ "dev-vboxguest.device" ];
        after = [ "dev-vboxguest.device" ];

        unitConfig.ConditionVirtualization = "oracle";

        serviceConfig.ExecStart = "${config.boot.kernelPackages.virtualboxGuestAdditions}/bin/VBoxClient -fv ${flags}";
      };
    in
    {
      virtualbox-resize = vbox-client "Resize" "--vmsvga";
      virtualbox-clipboard = vbox-client "Clipboard" "--clipboard";
    };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  boot.loader.grub.device = "/dev/sda";

  users.users.precice = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialPassword = "precice";
    openssh.authorizedKeys.keys = [ (lib.readFile ./vagrant.pub) ];
  };

  environment = {
    variables = {
      NIXPKGS_ALLOW_UNFREE = "1";
      EDITOR = "nvim";
    };
    shellAliases = {
      vim = "nvim";
    };
    extraInit = ''
      # source ''${pkgs.openfoam}/bin/set-openfoam-vars
      if [[ ! -e ~/tutorials ]]; then
        ${pkgs.git}/bin/git clone https://github.com/precice/tutorials ~/tutorials
      fi
    '';
    systemPackages =
      with pkgs;
      let
        precice-python-packages = python3.withPackages (ps: [
          ps.ipython

          # nutils
          ps.matplotlib
          nutils

          ps.virtualenv
          ps.pyprecice
          ps.pandas
        ]);
        preciceToPNG = writeShellScriptBin "preciceToPNG" "cat \"\${1:-precice-config.xml}\" | ${precice-config-visualizer}/bin/precice-config-visualizer | ${graphviz}/bin/dot -Tpng > precice-config.png";
        preciceToPDF = writeShellScriptBin "preciceToPDF" "cat \"\${1:-precice-config.xml}\" | ${precice-config-visualizer}/bin/precice-config-visualizer | ${graphviz}/bin/dot -Tpdf > precice-config.pdf";
        preciceToSVG = writeShellScriptBin "preciceToSVG" "cat \"\${1:-precice-config.xml}\" | ${precice-config-visualizer}/bin/precice-config-visualizer | ${graphviz}/bin/dot -Tsvg > precice-config.svg";
      in
      [
        # Basic applications
        # baobab
        # catfish
        # firefox
        # mate.atril
        terminator
        tree

        # Devel applications
        git
        cmakeWithGui
        gnumake
        gcc
        nano
        neovim
        gnome.gedit
        precice-python-packages
        gnuplot

        # Precice
        precice
        precice-config-visualizer

        # precice-dealii-adapter builds too slow
        precice-calculix-adapter
        # precice-fenics-adapter needs hdf5 which is insecure
        # precice-aste needs recompilation of vtk
        precice-su2 # not needed
        # precice-openfoam-adapter too slow
        # openfoam too slow
        # precice-aster too many dependencies, thus slow
        # precice-dune too slow

        # From the .alias file in the VM repo
        preciceToPNG
        preciceToPDF
        preciceToSVG

        # Additional packages
        paraview
        wget
      ];
  };

  # TODO: Somehow make sure `pip3 uninstall -y fenics-ufl` is solved https://github.com/precice/vm/issues/4

  services.openssh.enable = true;

  system.stateVersion = "22.11";
}
