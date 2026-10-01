-- Change the default Omarchy look'n'feel (restored from backup)

local active_border_color = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 }
local inactive_border_color = "rgba(595959aa)"

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 10,
    border_size = 2,

    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },

    resize_on_border = false,
    allow_tearing = false,
    layout = "dwindle",
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
hl.config({
  decoration = {
    rounding = 6,

    shadow = {
      enabled = true,
      range = 2,
      render_power = 3,
      color = "rgba(1a1a1aee)",
    },

    blur = {
      enabled = true,
      size = 2,
      passes = 2,
      special = true,
      brightness = 0.60,
      contrast = 0.75,
    },
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#group
hl.config({
  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
      border_locked_active = active_border_color,
      border_locked_inactive = inactive_border_color,
    },
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
hl.config({
  animations = {
    enabled = true,
  },
})

-- https://wiki.hypr.land/Configuring/Dwindle-Layout/
hl.config({
  dwindle = {
    preserve_split = true,
    force_split = 2,
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#misc
hl.config({
  misc = {
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    focus_on_activate = true,
    anr_missed_pings = 3,
    on_focus_under_fullscreen = 1,
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#cursor
hl.config({
  cursor = {
    hide_on_key_press = true,
    warp_on_change_workspace = 1,
  },
})

-- Binds
hl.config({
  binds = {
    hide_special_on_workspace_change = true,
  },
})

-- GUM environment variables for styling purposes.
hl.env("GUM_CONFIRM_PROMPT_FOREGROUND", "6")
hl.env("GUM_CONFIRM_SELECTED_FOREGROUND", "0")
hl.env("GUM_CONFIRM_SELECTED_BACKGROUND", "2")
hl.env("GUM_CONFIRM_UNSELECTED_FOREGROUND", "7")
hl.env("GUM_CONFIRM_UNSELECTED_BACKGROUND", "8")
