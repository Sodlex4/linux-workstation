-- JAVA DEVELOPMENT Keybindings
-- SUPER + J was "Toggle window split" in Omarchy defaults
hl.unbind("SUPER + J")

o.bind("SUPER + J", "Java Editor", "alacritty -e nvim .")
o.bind("SUPER + B", "Java Build", "alacritty -e ~/.local/bin/java-build.sh")
o.bind("SUPER + R", "Java Run", "alacritty -e ~/.local/bin/java-run.sh")

-- Workspace Quick Jump
o.bind("SUPER + 1", "Workspace 1 - Neovim", "workspace 1")
o.bind("SUPER + 2", "Workspace 2 - Terminal", "workspace 2")
o.bind("SUPER + 3", "Workspace 3 - Browser", "workspace 3")
o.bind("SUPER + 4", "Workspace 4 - Communication", "workspace 4")
o.bind("SUPER + 5", "Workspace 5 - Reference", "workspace 5")
