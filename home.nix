{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "sealgair";
  home.homeDirectory = "/home/sealgair";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    pkgs.bat
    pkgs.cargo
    pkgs.delta
    pkgs.gnupg
    pkgs.helix
    pkgs.just
    pkgs.nerd-fonts.recursive-mono
    pkgs.nushell
    pkgs.starship
    pkgs.tokei
    pkgs.uv
    pkgs.zellij
  ];



  programs.git = {
    enable = true;
    userName = "sealgair";
    userEmail = "dev@sealgair.dev";

    delta = {
      enable = true;
      options = {
        features = "diff-output";
        navigate = true;
        dark = true;
        hyperlinks = true;
        "true-color" = "always";
        "diff-output".line-numbers = true;
        "diff-output".side-by-side = true;
      };

    };

    signing = {
      key = "";
      signByDefault = true;
    };
    
    extraConfig = {
      merge.conflictstyle = "diff3";
      diff.colorMove = "default";
    };
  };

  programs.gpg = {
    enable = true;
  };

  programs.ssh = {
    enable = true;
  };

  programs.bash = {
    enable = true;
    initExtra = ''
      eval "$(starship init bash)"

      # Only launch Zellij if not in Zellij, SSH, nix-shell, or Nushell, and in an interactive terminal
      if [ -z "$ZELLIJ" ] && [ -z "$SSH_CLIENT" ] && [ -z "$IN_NIX_SHELL" ] && [ -z "$NU_VERSION" ] && [ -t 0 ]; then
        if [[ $- == *i* ]]; then
          if command -v zellij >/dev/null 2>&1; then
            if ! zellij list-sessions 2>/dev/null | grep -q .; then
              zellij
            else
              zellij attach -c
            fi
          fi
        fi
      fi
    '';
  };

  programs.nushell = {
    enable = true;
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    ".ssh/id_ed25519" = {
      source = ./secrets/id_ed25519;
    };
    ".ssh/id_ed25519.pub" = {
      source = ./secrets/id_ed25519.pub;
    };
    ".ssh/config".text = ''
      Host github.com
        HostName github.com
        User git
        IdentityFile ~/.ssh/id_ed25519
        IdentitiesOnly yes
      '';

    ".config/ghostty/config".source = ./config/ghostty/config;

    ".config/helix/config.toml".source = ./config/helix/config.toml;
    ".config/helix/languages.toml".source = ./config/helix/languages.toml;

    ".config/nushell/config.nu".source = ./config/nushell/config.nu;
    ".config/nushell/env.nu".source = ./config/nushell/env.nu;

    ".config/starship.toml".source = ./config/starship.toml;

    ".config/zellij/config.kdl".source = ./config/zellij/config.kdl;
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/sealgair/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
