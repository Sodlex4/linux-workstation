-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- All Omarchy default setups
require("default.hypr.omarchy")

-- Change your own setup in these files and override defaults.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- ============================================
-- JAVA DEVELOPMENT WORKSTATION - Window Rules (restored)
-- ============================================

-- Terminal-specific opacity (more transparent than default 0.97)
o.window({ tag = "terminal" }, { opacity = "0.92 0.85" })

-- Workspace 1: Neovim (Code Editor)
o.window({ class = "Alacritty", title = "nvim" }, { workspace = 1 })
o.window({ class = "nvim" }, { workspace = 1 })

-- Workspace 2: Terminal (Compile/Run)
o.window({ class = "Alacritty", title = "Terminal" }, { workspace = 2 })

-- Workspace 3: Browser (Docs, Stack Overflow)
o.window({ class = "firefox" }, { workspace = 3 })
o.window({ class = "chromium" }, { workspace = 3 })
o.window({ class = "google-chrome" }, { workspace = 3 })

-- Workspace 4: Communication
o.window({ class = "discord" }, { workspace = 4 })
o.window({ class = "slack" }, { workspace = 4 })
o.window({ class = "telegram" }, { workspace = 4 })
o.window({ class = "Signal" }, { workspace = 4 })

-- Workspace 5: Reference (PDFs, Notes)
o.window({ class = "evince" }, { workspace = 5 })
o.window({ class = "obsidian" }, { workspace = 5 })

-- Float specific apps
o.window({ class = "pavucontrol" }, { float = true })
o.window({ class = "nm-connection-editor" }, { float = true })
o.window({ title = "Picture-in-Picture" }, { float = true })
o.window({ class = "java", title = "About" }, { float = true })
