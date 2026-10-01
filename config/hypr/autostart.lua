-- ============================================
-- HP EliteBook 840 G3 — custom autostart
-- ============================================

o.launch_on_start("awww-daemon")
o.launch_on_start("$HOME/.local/bin/omarchy-bg-slideshow")

-- ============================================
-- JAVA DEVELOPMENT Autostart
-- ============================================

o.launch_on_start("alacritty -e tmux new-session -s dev")
o.launch_on_start("alacritty -e nvim .")
