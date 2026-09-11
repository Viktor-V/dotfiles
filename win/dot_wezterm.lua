local wezterm = require 'wezterm'

local config = {}

config.default_domain = 'WSL:Debian'
config.font = wezterm.font('JetBrainsMono NF')
config.font_size = 11.0
config.color_scheme = 'Dracula (Official)'
config.window_background_opacity = 0.9
config.text_background_opacity = 0.8
config.window_decorations = 'RESIZE'
config.enable_tab_bar = false
config.window_close_confirmation = 'NeverPrompt'

wezterm.on('gui-startup', function(cmd)
  local tab, pane, work = wezterm.mux.spawn_window({
    workspace = 'work',
    args = { 'opencode' },
  })
  tab:set_title('opencode')

  local nvim_tab = work:spawn_tab({ args = { 'nvim' } })
  nvim_tab:set_title('neovim')

  local shell_tab = work:spawn_tab({ args = { 'fish', '-c', 'fastfetch; exec fish' } })
  shell_tab:set_title('shell')

  local docker_tab = wezterm.mux.spawn_window({ workspace = 'docker' })
  docker_tab:set_title('shell')

  wezterm.mux.set_active_workspace('work')
  work:gui_window():toggle_fullscreen()
end)

return config
