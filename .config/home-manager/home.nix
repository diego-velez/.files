{
  pkgs,
  lib,
  ...
}:

let
  hostname = import ./host.nix;
  fuzzelFontSize = if hostname == "desktop" then "32" else "20";
  powerMenuScript = pkgs.writeShellApplication {
    name = "power-menu";
    text = builtins.replaceStrings [ "@fontSize@" ] [ fuzzelFontSize ] (
      builtins.readFile ./scripts/power-menu
    );
  };
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "dvt";
  home.homeDirectory = "/home/dvt";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  xdg.configFile."waybar/config".text = import ./waybar.nix {
    inherit hostname;
  };

  xdg.configFile."niri/config.kdl".text = import ./niri.nix {
    inherit hostname powerMenuScript;
  };

  programs.git = {
    enable = true;

    signing = {
      key = "~/.ssh/github";
      signByDefault = true;
    };

    settings = {
      user = {
        name = "Diego Vélez";
        email = "diego.velez.dev@gmail.com";
      };
      gpg.format = "ssh";
      pull.rebase = true;
    };
  };

  programs.lazygit = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      gui = {
        language = "en";
        timeFormat = "02 January 2006";
        shortTimeFormat = "15:04";
        nerdFontsVersion = "3";
        showFileIcons = true;
        spinner = {
          frames = [
            "⠋"
            "⠙"
            "⠹"
            "⠸"
            "⠼"
            "⠴"
            "⠦"
            "⠧"
            "⠇"
            "⠏"
          ];
          rate = 50;
        };
      };
      git = {
        parseEmoji = true;
        disableForcePushing = true;
      };
      disableStartupPopups = true;
    };
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      # purple, green, cyan, red, pink, yellow
      format = lib.concatStrings [
        "[](purple)"
        "$os"
        "$username"
        "[](bg:green fg:purple)"
        "$directory"
        "[](fg:green bg:cyan)"
        "$git_branch"
        "$git_status"
        "[](fg:cyan bg:red)"
        "$c"
        "$rust"
        "$golang"
        "$nodejs"
        "$php"
        "$java"
        "$kotlin"
        "$haskell"
        "$python"
        "[](fg:red bg:pink)"
        "$docker_context"
        "[](fg:pink bg:yellow)"
        "$time"
        "[ ](fg:yellow)"
        "$fill"
        "$line_break$character"
      ];

      palette = "dracula";

      palettes.dracula = {
        background = "#282A36";
        foreground = "#F8F8F2";
        selection = "#44475A";
        comment = "#6272A4";
        red = "#FF5555";
        orange = "#FFB86C";
        yellow = "#F1FA8C";
        green = "#50FA7B";
        purple = "#BD93F9";
        cyan = "#8BE9FD";
        pink = "#FF79C6";
      };

      os = {
        disabled = false;
        style = "bg:purple fg:background";
        symbols = {
          Fedora = "󰣛";
          Arch = "󰣇";
        };
      };

      username = {
        show_always = true;
        style_user = "bg:purple fg:background bold";
        style_root = "bg:purple fg:background bold";
        format = "[ $user ]($style)";
      };

      directory = {
        style = "fg:background bg:green bold";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
      };

      directory.substitutions = {
        Documents = "󰈙 ";
        Downloads = " ";
        Music = "󰝚 ";
        Pictures = " ";
        Developer = "󰲋 ";
      };
      git_branch = {
        symbol = "";
        style = "bg:cyan bold";
        format = "[[ $symbol $branch ](fg:background bg:cyan bold)]($style)";
      };

      git_status = {
        style = "bg:cyan bold";
        format = "[[($all_status$ahead_behind )](fg:background bg:cyan bold)]($style)";
      };

      # Language modules share the same style/format in your config
      nodejs = {
        symbol = "";
        style = "bg:green bold";
        format = "[[ $symbol( $version) ](fg:background bg:red bold)]($style)";
      };

      c = {
        symbol = " ";
        style = "bg:green bold";
        format = "[[ $symbol( $version) ](fg:background bg:red bold)]($style)";
      };

      rust = {
        symbol = "";
        style = "bg:green bold";
        format = "[[ $symbol( $version) ](fg:background bg:red bold)]($style)";
      };

      golang = {
        symbol = "";
        style = "bg:green bold";
        format = "[[ $symbol( $version) ](fg:background bg:red bold)]($style)";
      };

      php = {
        symbol = "";
        style = "bg:green bold";
        format = "[[ $symbol( $version) ](fg:background bg:red bold)]($style)";
      };

      java = {
        symbol = " ";
        style = "bg:green bold";
        format = "[[ $symbol( $version) ](fg:background bg:red bold)]($style)";
      };

      kotlin = {
        symbol = "";
        style = "bg:green bold";
        format = "[[ $symbol( $version) ](fg:background bg:red bold)]($style)";
      };

      haskell = {
        symbol = "";
        style = "bg:green bold";
        format = "[[ $symbol( $version) ](fg:background bg:red bold)]($style)";
      };

      python = {
        symbol = "";
        style = "bg:green bold";
        format = "[[ $symbol( $version) ](fg:background bg:red bold)]($style)";
      };

      docker_context = {
        symbol = "";
        style = "bg:pink bold";
        format = "[[ $symbol( $context) ](fg:background bg:pink bold)]($style)";
      };

      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:yellow bold";
        format = "[[  $time ](fg:background bg:yellow bold)]($style)";
      };

      line_break.disabled = false;

      character = {
        disabled = false;
        success_symbol = " [󱞩](bold fg:green)";
        error_symbol = " [󱞩](bold fg:red)";
        vimcmd_symbol = " [󱞥](bold fg:yellow)";
        vimcmd_replace_one_symbol = " [󱞥](bold fg:purple)";
        vimcmd_replace_symbol = " [󱞥](bold fg:purple)";
        vimcmd_visual_symbol = " [󱞥](bold fg:pink)";
      };

      fill.symbol = "";
    };
  };

  xdg.configFile."kanata/config.kbd" = lib.mkIf (hostname == "laptop") {
    text = ''
      (defcfg
          process-unmapped-keys yes
      )

      (defsrc
          q w e r t y u i o p
          a s d f g h j k l ; '
          z x c v b n m
          tab caps spc
      )

      (deflayer base
          q w f p b j l u y '
          @cha r s t g m n e i @cho ;
          x c d v z k h
          caps tab @nav
      )

      ;; This is mapped using Qwerty
      (deflayermap (nav-layer)
          a lmeta s lalt d lshift f lctrl
          j left k down l up ; right
          m home , end
      )

      (defalias
          nav (tap-hold 200 200 spc (layer-while-held nav-layer))
          cha (chord escape-combo a)
          cho (chord escape-combo o)
      )

      (defchords escape-combo 35
          (a  ) a
          (  o) o
          (a o) esc
      )
    '';
  };

  systemd.user.services.kanata = lib.mkIf (hostname == "laptop") {
    Unit = {
      Description = "Kanata Keyboard remapper";
      Documentation = "https://github.com/jtroo/kanata";
    };

    Service = {
      Type = "simple";
      ExecStart = "${pkgs.kanata}/bin/kanata --cfg %E/kanata/config.kbd";
      Restart = "no";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

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
    pkgs.nixd
    powerMenuScript
  ]
  ++ (if hostname == "laptop" then [ pkgs.kanata ] else [ ]);

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
  #  /etc/profiles/per-user/dvt/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
