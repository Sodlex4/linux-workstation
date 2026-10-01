-- Menus
o.bind("SUPER + SPACE", "Launch apps", { omarchy = "launch-walker" })
o.bind("SUPER + CTRL + E", "Emoji picker", { omarchy = "launch-walker -m symbols" })
o.bind("SUPER + CTRL + C", "Capture menu", { omarchy = "menu capture" })
o.bind("SUPER + CTRL + O", "Toggle menu", { omarchy = "menu toggle" })
o.bind("SUPER + ALT + SPACE", "Omarchy menu", { omarchy = "menu" })
o.bind("SUPER + ESCAPE", "System menu", { omarchy = "menu system" })
o.bind("XF86PowerOff", "Power menu", { omarchy = "menu system", locked = true })
o.bind("SUPER + K", "Show key bindings", { omarchy = "menu-keybindings" })
o.bind("XF86Calculator", "Calculator", "gnome-calculator")

-- Aesthetics
o.bind("SUPER + SHIFT + SPACE", "Toggle top bar", { omarchy = "toggle-waybar" })
o.bind("SUPER + CTRL + SPACE", "Theme background menu", { omarchy = "menu background" })
o.bind("SUPER + SHIFT + CTRL + SPACE", "Theme menu", { omarchy = "menu theme" })
o.bind("SUPER + BACKSPACE", "Toggle window transparency", { omarchy = "hyprland-active-window-transparency-toggle" })
o.bind("SUPER + SHIFT + BACKSPACE", "Toggle window gaps", { omarchy = "hyprland-window-gaps-toggle" })
o.bind("SUPER + CTRL + BACKSPACE", "Toggle single-window square aspect", { omarchy = "hyprland-window-single-square-aspect-toggle" })

-- Notifications
o.bind("SUPER + COMMA", "Dismiss last notification", "makoctl dismiss")
o.bind("SUPER + SHIFT + COMMA", "Dismiss all notifications", "makoctl dismiss --all")
o.bind("SUPER + CTRL + COMMA", "Toggle silencing notifications", { omarchy = "toggle-notification-silencing" })
o.bind("SUPER + ALT + COMMA", "Invoke last notification", "makoctl invoke")
o.bind("SUPER + SHIFT + ALT + COMMA", "Restore last notification", "makoctl restore")

-- Toggles
o.bind("SUPER + CTRL + I", "Toggle locking on idle", { omarchy = "toggle-idle" })
o.bind("SUPER + CTRL + N", "Toggle nightlight", { omarchy = "toggle-nightlight" })

-- Control Apple Display brightness
o.bind("CTRL + F1", "Apple Display brightness down", { omarchy = "brightness-display-apple -5000" })
o.bind("CTRL + F2", "Apple Display brightness up", { omarchy = "brightness-display-apple +5000" })
o.bind("SHIFT + CTRL + F2", "Apple Display full brightness", { omarchy = "brightness-display-apple +60000" })

-- Captures
o.bind("PRINT", "Screenshot", { omarchy = "cmd-screenshot" })
o.bind("ALT + PRINT", "Screenrecording", { omarchy = "menu screenrecord" })
o.bind("SUPER + PRINT", "Color picker", "pkill hyprpicker || hyprpicker -a")

-- File sharing
o.bind("SUPER + CTRL + S", "Share", { omarchy = "menu share" })

-- Waybar-less information
o.bind("SUPER + CTRL + ALT + T", "Show time", "notify-send -u low \"    $(date +\"%A %H:%M  ·  %d %B %Y  ·  Week %V\")\"")
o.bind("SUPER + CTRL + ALT + B", "Show battery remaining", "notify-send -u low \"$(omarchy-battery-status)\"")

-- Control panels
o.bind("SUPER + CTRL + A", "Audio controls", { omarchy = "launch-audio" })
o.bind("SUPER + CTRL + B", "Bluetooth controls", { omarchy = "launch-bluetooth" })
o.bind("SUPER + CTRL + W", "Wifi controls", { omarchy = "launch-wifi" })
o.bind("SUPER + CTRL + T", "Activity", { omarchy = "launch-tui btop" })

-- Dictation
o.bind("SUPER + CTRL + X", "Toggle dictation", "voxtype record toggle")

-- Zoom
o.bind("SUPER + CTRL + Z", "Zoom in", "hyprctl keyword cursor:zoom_factor $(hyprctl getoption cursor:zoom_factor -j | jq '.float + 1')")
o.bind("SUPER + CTRL + ALT + Z", "Reset zoom", "hyprctl keyword cursor:zoom_factor 1")

-- Lock system
o.bind("SUPER + CTRL + L", "Lock system", { omarchy = "lock-screen" })
