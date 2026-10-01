-- Close windows
o.bind("SUPER + W", "Close window", "killactive")
o.bind("CTRL + ALT + DELETE", "Close all windows", { omarchy = "hyprland-window-close-all" })

-- Control tiling
o.bind("SUPER + J", "Toggle window split", "layoutmsg togglesplit")
o.bind("SUPER + P", "Pseudo window", "pseudo")
o.bind("SUPER + T", "Toggle window floating/tiling", "togglefloating")
o.bind("SUPER + F", "Full screen", "fullscreen 0")
o.bind("SUPER + CTRL + F", "Tiled full screen", "fullscreenstate 0 2")
o.bind("SUPER + ALT + F", "Full width", "fullscreen 1")
o.bind("SUPER + O", "Pop window out (float & pin)", { omarchy = "hyprland-window-pop" })
o.bind("SUPER + L", "Toggle workspace layout", { omarchy = "hyprland-workspace-layout-toggle" })

-- Move focus with SUPER + arrow keys
o.bind("SUPER + LEFT", "Move window focus left", "movefocus l")
o.bind("SUPER + RIGHT", "Move window focus right", "movefocus r")
o.bind("SUPER + UP", "Move window focus up", "movefocus u")
o.bind("SUPER + DOWN", "Move window focus down", "movefocus d")

-- Switch workspaces with SUPER + [1-9; 0]
o.bind("SUPER + 1", "Switch to workspace 1", "workspace 1")
o.bind("SUPER + 2", "Switch to workspace 2", "workspace 2")
o.bind("SUPER + 3", "Switch to workspace 3", "workspace 3")
o.bind("SUPER + 4", "Switch to workspace 4", "workspace 4")
o.bind("SUPER + 5", "Switch to workspace 5", "workspace 5")
o.bind("SUPER + 6", "Switch to workspace 6", "workspace 6")
o.bind("SUPER + 7", "Switch to workspace 7", "workspace 7")
o.bind("SUPER + 8", "Switch to workspace 8", "workspace 8")
o.bind("SUPER + 9", "Switch to workspace 9", "workspace 9")
o.bind("SUPER + 0", "Switch to workspace 10", "workspace 10")

-- Move active window to a workspace with SUPER + SHIFT + [1-9; 0]
o.bind("SUPER + SHIFT + 1", "Move window to workspace 1", "movetoworkspace 1")
o.bind("SUPER + SHIFT + 2", "Move window to workspace 2", "movetoworkspace 2")
o.bind("SUPER + SHIFT + 3", "Move window to workspace 3", "movetoworkspace 3")
o.bind("SUPER + SHIFT + 4", "Move window to workspace 4", "movetoworkspace 4")
o.bind("SUPER + SHIFT + 5", "Move window to workspace 5", "movetoworkspace 5")
o.bind("SUPER + SHIFT + 6", "Move window to workspace 6", "movetoworkspace 6")
o.bind("SUPER + SHIFT + 7", "Move window to workspace 7", "movetoworkspace 7")
o.bind("SUPER + SHIFT + 8", "Move window to workspace 8", "movetoworkspace 8")
o.bind("SUPER + SHIFT + 9", "Move window to workspace 9", "movetoworkspace 9")
o.bind("SUPER + SHIFT + 0", "Move window to workspace 10", "movetoworkspace 10")

-- Move active window silently to a workspace with SUPER + SHIFT + ALT + [1-9; 0]
o.bind("SUPER + SHIFT + ALT + 1", "Move window silently to workspace 1", "movetoworkspacesilent 1")
o.bind("SUPER + SHIFT + ALT + 2", "Move window silently to workspace 2", "movetoworkspacesilent 2")
o.bind("SUPER + SHIFT + ALT + 3", "Move window silently to workspace 3", "movetoworkspacesilent 3")
o.bind("SUPER + SHIFT + ALT + 4", "Move window silently to workspace 4", "movetoworkspacesilent 4")
o.bind("SUPER + SHIFT + ALT + 5", "Move window silently to workspace 5", "movetoworkspacesilent 5")
o.bind("SUPER + SHIFT + ALT + 6", "Move window silently to workspace 6", "movetoworkspacesilent 6")
o.bind("SUPER + SHIFT + ALT + 7", "Move window silently to workspace 7", "movetoworkspacesilent 7")
o.bind("SUPER + SHIFT + ALT + 8", "Move window silently to workspace 8", "movetoworkspacesilent 8")
o.bind("SUPER + SHIFT + ALT + 9", "Move window silently to workspace 9", "movetoworkspacesilent 9")
o.bind("SUPER + SHIFT + ALT + 0", "Move window silently to workspace 10", "movetoworkspacesilent 10")

-- Control scratchpad
o.bind("SUPER + S", "Toggle scratchpad", "togglespecialworkspace scratchpad")
o.bind("SUPER + ALT + S", "Move window to scratchpad", "movetoworkspacesilent special:scratchpad")

-- TAB between workspaces
o.bind("SUPER + TAB", "Next workspace", "workspace e+1")
o.bind("SUPER + SHIFT + TAB", "Previous workspace", "workspace e-1")
o.bind("SUPER + CTRL + TAB", "Former workspace", "workspace previous")

-- Move workspaces to other monitors
o.bind("SUPER + SHIFT + ALT + LEFT", "Move workspace to left monitor", "movecurrentworkspacetomonitor l")
o.bind("SUPER + SHIFT + ALT + RIGHT", "Move workspace to right monitor", "movecurrentworkspacetomonitor r")
o.bind("SUPER + SHIFT + ALT + UP", "Move workspace to up monitor", "movecurrentworkspacetomonitor u")
o.bind("SUPER + SHIFT + ALT + DOWN", "Move workspace to down monitor", "movecurrentworkspacetomonitor d")

-- Swap active window with the one next to it with SUPER + SHIFT + arrow keys
o.bind("SUPER + SHIFT + LEFT", "Swap window to the left", "swapwindow l")
o.bind("SUPER + SHIFT + RIGHT", "Swap window to the right", "swapwindow r")
o.bind("SUPER + SHIFT + UP", "Swap window up", "swapwindow u")
o.bind("SUPER + SHIFT + DOWN", "Swap window down", "swapwindow d")

-- Cycle through applications on active workspace
o.bind("ALT + TAB", "Cycle to next window", "cyclenext")
o.bind("ALT + SHIFT + TAB", "Cycle to prev window", "cyclenext prev")
o.bind("ALT + TAB", "Reveal active window on top", "bringactivetotop")
o.bind("ALT + SHIFT + TAB", "Reveal active window on top", "bringactivetotop")

-- Resize active window
o.bind("SUPER + MINUS", "Expand window left", "resizeactive -100 0")
o.bind("SUPER + EQUAL", "Shrink window left", "resizeactive 100 0")
o.bind("SUPER + SHIFT + MINUS", "Shrink window up", "resizeactive 0 -100")
o.bind("SUPER + SHIFT + EQUAL", "Expand window down", "resizeactive 0 100")

-- Scroll through existing workspaces with SUPER + scroll
o.bind("SUPER + mouse_down", "Scroll active workspace forward", "workspace e+1")
o.bind("SUPER + mouse_up", "Scroll active workspace backward", "workspace e-1")

-- Move/resize windows with mainMod + LMB/RMB and dragging
o.bind("SUPER + mouse:272", "Move window", "movewindow", { mouse = true })
o.bind("SUPER + mouse:273", "Resize window", "resizewindow", { mouse = true })

-- Toggle groups
o.bind("SUPER + G", "Toggle window grouping", "togglegroup")
o.bind("SUPER + ALT + G", "Move active window out of group", "moveoutofgroup")

-- Join groups
o.bind("SUPER + ALT + LEFT", "Move window to group on left", "moveintogroup l")
o.bind("SUPER + ALT + RIGHT", "Move window to group on right", "moveintogroup r")
o.bind("SUPER + ALT + UP", "Move window to group on top", "moveintogroup u")
o.bind("SUPER + ALT + DOWN", "Move window to group on bottom", "moveintogroup d")

-- Navigate a single set of grouped windows
o.bind("SUPER + ALT + TAB", "Next window in group", "changegroupactive f")
o.bind("SUPER + ALT + SHIFT + TAB", "Previous window in group", "changegroupactive b")

-- Window navigation for grouped windows
o.bind("SUPER + CTRL + LEFT", "Move grouped window focus left", "changegroupactive b")
o.bind("SUPER + CTRL + RIGHT", "Move grouped window focus right", "changegroupactive f")

-- Scroll through a set of grouped windows with SUPER + ALT + scroll
o.bind("SUPER + ALT + mouse_down", "Next window in group", "changegroupactive f")
o.bind("SUPER + ALT + mouse_up", "Previous window in group", "changegroupactive b")

-- Activate window in a group by number
o.bind("SUPER + ALT + 1", "Switch to group window 1", "changegroupactive 1")
o.bind("SUPER + ALT + 2", "Switch to group window 2", "changegroupactive 2")
o.bind("SUPER + ALT + 3", "Switch to group window 3", "changegroupactive 3")
o.bind("SUPER + ALT + 4", "Switch to group window 4", "changegroupactive 4")
o.bind("SUPER + ALT + 5", "Switch to group window 5", "changegroupactive 5")

-- Cycle monitor scaling
o.bind("SUPER + Slash", "Cycle monitor scaling", { omarchy = "hyprland-monitor-scaling-cycle" })
