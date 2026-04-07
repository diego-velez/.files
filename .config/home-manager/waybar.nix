{ hostname, ... }:

builtins.toJSON (
  {
    position = "top";
    height = 20;
    width = if hostname == "desktop" then 2034 else 1896;

    reload_style_on_change = true;
    spacing = 0;

    modules-left = [
      "niri/workspaces"
      "niri/window"
    ];
    modules-center = [
      "clock#time"
      "clock#date"
    ];
    modules-right = [
      "mpris"
    ]
    ++ (if hostname == "laptop" then [ "battery" ] else [ ])
    ++ [
      "network"
      "custom/wireguard"
      "pulseaudio"
      "bluetooth"
      "custom/notification"
      "tray"
    ];

    "niri/workspaces" = {
      all-outputs = true;
      format = "{icon}";
      format-icons = {
        focused = "";
        default = "";
      };
    };

    "niri/window" = {
      format = "{title}";
      rewrite = {
        "(.*) — Zen Browser.*" = "<span foreground='#8BE9FD'></span> $1";
        "Zen Browser.*" = "<span foreground='#8BE9FD'></span> Zen Browser";
        "(.*)@(.*):(.*) - (.*)" = "<span foreground='#BD93F9'></span> $4";
        "(.*)@(.*):(?!.*-.*)(.*)" = "<span foreground='#BD93F9'></span> $1@$2";
        ".*nvim (.*)" = "<span foreground='#6ebf60'></span> $1";
        ".*nvim" = "<span foreground='#6ebf60'></span> Neovim";
        ".*Discord.*" = "<span foreground='#89b4fa'></span> Discord";
        ".*Webcord.*" = "<span foreground='#89b4fa'></span> Webcord";
        "GNU Image Manipulation Program" =
          "<span foreground='#a6adc8'></span> GNU Image Manipulation Program";
        "(.*).jpg" = "  $1.jpg";
        "(.*).png" = "  $1.png";
        "(.*).svg" = "  $1.svg";
        "/" = "  File Manager";
        "Yazi: (.*)" = "  $1";
        "" = "<span foreground='#cba6f7'></span> DVT on Master 󰅂 Niri";
      };
    };

    "clock#time" = {
      format = "<span color='#8BE9FD'>󱑂</span> {:%H:%M}";
      tooltip = true;
      tooltip-format = "{:%I:%M %p}";
      min-length = 8;
      max-length = 8;
    };

    "clock#date" = {
      format = "<span color='#8BE9FD'>󱨴</span> {:%d %b}";
      tooltip-format = "<tt>{calendar}</tt>";
      calendar = {
        mode = "month";
        mode-mon-col = 3;
        on-click-right = "mode";
        format = {
          months = "<span color='#f5e0dc'><b>{}</b></span>";
          weekdays = "<span color='#f9e2af'><b>{}</b></span>";
          today = "<span color='#f38ba8'><b>{}</b></span>";
        };
      };
      actions = {
        on-click-right = "mode";
      };
      min-length = 8;
      max-length = 8;
    };

    network = {
      format-wifi = "{icon} Wifi";
      format-ethernet = "<span color='#50FA7B'>󰈁</span> Cable";
      format-disconnected = "<span color='#FF5555'>󰤮</span> Error";
      format-icons = [
        "<span color='#F1FA8C'>󰤟</span>"
        "<span color='#F1FA8C'>󰤢</span>"
        "<span color='#50FA7B'>󰤥</span>"
        "<span color='#50FA7B'>󰤨</span>"
      ];
      tooltip-format = "{ifname} via {gwaddr} 󰊗";
      tooltip-format-wifi = "{essid} ({signalStrength}%) {icon}";
      tooltip-format-ethernet = "{ifname} 󰈁";
      tooltip-format-disconnected = "Disconnected";
      on-click = "wezterm start -e fish -c nmtui";
      min-length = 7;
      max-length = 7;
    };

    mpris = {
      format = "{status_icon} {artist} - {title}";
      artist-len = 30;
      title-len = 50;
      status-icons = {
        playing = "<span color='#50FA7B'>󰎇</span>";
        paused = "<span color='#FF5555'>󰎊</span>";
      };
      tooltip-format = "{player} ({status}): {artist} - {album} - {title}";
    };
  }
  // (
    if hostname == "laptop" then
      {
        battery = {
          interval = 5;
          states = {
            empty = 5;
            critical = 20;
            twenties = 29;
            thirties = 39;
            fourties = 49;
            fifties = 59;
            sixeties = 69;
            seventies = 79;
            eighties = 89;
            nineties = 95;
            full = 100;
          };
          format-icons = {
            empty = "<span color='#FF5555'>󱟩</span>";
            critical = "<span color='#FF5555'>󰂃</span>";
            twenties = "<span color='#FF5555'>󰁻</span>";
            thirties = "<span color='#F1FA8C'>󰁼</span>";
            fourties = "<span color='#F1FA8C'>󰁽</span>";
            fifties = "<span color='#F1FA8C'>󰁾</span>";
            sixeties = "<span color='#F1FA8C'>󰁿</span>";
            seventies = "<span color='#50FA7B'>󰂀</span>";
            eighties = "<span color='#50FA7B'>󰂁</span>";
            nineties = "<span color='#50FA7B'>󰂂</span>";
            full = "<span color='#50FA7B'>󰁹</span>";
          };
          format-discharging = "{icon} {capacity}% ";
          format-charging = "<span color='#50FA7B'>{icon}󱐋</span> {capacity}% ";
        };
      }
    else
      { }
  )
  // {

    pulseaudio = {
      format = "<span color='#8BE9FD'>{icon}</span> {volume}%";
      tooltip-format = "{desc} at {format_source}\nPC at {volume}%";
      format-icons = {
        headphone = "󰋋";
        headset = "󰋋";
        phone = "";
        portable = "";
        car = "";
        default = [
          "<span color='#F1FA8C'></span>"
          "<span color='#50FA7B'></span>"
          "<span color='#50FA7B'></span>"
        ];
        default-muted = "<span color='#FF5555'>󰝟</span>";
      };
      on-click = "pavucontrol";
    };

    bluetooth = {
      format-on = "<span color='#8BE9FD'>󰂯</span>";
      format-connected = "<span color='#50FA7B'>󰂱</span>";
      format-off = "<span color='#FF5555'>󰂲</span>";
      format-disabled = "<span color='#FF5555'>󰂲</span>";
      format-no-controller = "<span color='#FF5555'>󰂯!</span>";
      tooltip-format-off = "The controller ({controller_alias}) is off";
      tooltip-format-disabled = "The controller ({controller_alias}) is disabled";
      tooltip-format-no-controller = "No controller was found!!";
      tooltip-format-connected = "Connected to {device_alias}";
      tooltip-format-connected-battery = "Connected to {device_alias} (󰥈 {device_battery_percentage}%)";
      on-click = "~/.local/bin/bzmenu --launcher fuzzel";
    };

    "custom/notification" = {
      format = "<span color='#FFB86C'></span> {text}";
      interval = 1;
      return-type = "json";
      on-click = "source ~/.config/ignis/.venv/bin/activate && ignis toggle DVT_Window";
    };

    tray = {
      spacing = 10;
      show-passive-items = true;
    };

    "custom/wireguard" = {
      format = "{}";
      exec = "~/.config/waybar/toggle_wireguard_vpn status";
      return-type = "json";
      interval = 5;
      on-click = "~/.config/waybar/toggle_wireguard_vpn toggle";
      tooltip = true;
    };
  }
)
