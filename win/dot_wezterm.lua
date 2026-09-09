local wezterm = require 'wezterm'

local config = {}

config.default_domain = 'WSL:Debian'
config.font = wezterm.font('JetBrainsMono NF')
config.font_size = 11.0
config.color_scheme = 'Dracula (Official)'
config.window_background_opacity = 0.9
config.text_background_opacity = 0.8
config.window_decorations = 'RESIZE'
config.hide_tab_bar_if_only_one_tab = true

wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():toggle_fullscreen()
end)

return config
