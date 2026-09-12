local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.max_fps = 240
config.animation_fps = 240

local tab_style = 'square'
local leader_prefix = utf8.char(0x1f30a)

-- Keep (user)
config.default_domain = 'WSL:Debian'
config.font = wezterm.font('JetBrainsMono NF')
config.font_size = 14.0
config.window_close_confirmation = 'NeverPrompt'
config.window_decorations = 'RESIZE'

-- Colors
config.color_scheme = 'Catppuccin Macchiato'

local scheme_colors = {
  catppuccin = {
    macchiato = {
      rosewater = 'f4dbd6',
      flamingo = 'f0c6c6',
      pink = 'f5bde6',
      mauve = 'c6a0f6',
      red = 'ed8796',
      maroon = 'ee99a0',
      peach = '#f5a97f',
      yellow = '#eed49f',
      green = '#a6da95',
      teal = '#8bd5ca',
      sky = '#91d7e3',
      sapphire = '#7dc4e4',
      blue = '#8aadf4',
      lavender = '#b7bdf8',
      text = '#cad3f5',
      crust = '#181926',
    },
  },
}

local colors = {
  border = scheme_colors.catppuccin.macchiato.lavender,
  tab_bar_active_tab_fg = scheme_colors.catppuccin.macchiato.mauve,
  tab_bar_active_tab_bg = scheme_colors.catppuccin.macchiato.crust,
  tab_bar_text = scheme_colors.catppuccin.macchiato.crust,
  arrow_foreground_leader = scheme_colors.catppuccin.macchiato.lavender,
  arrow_background_leader = scheme_colors.catppuccin.macchiato.crust,
}

-- Border
config.window_frame = {
  border_left_width = '0.4cell',
  border_right_width = '0.4cell',
  border_bottom_height = '0.15cell',
  border_top_height = '0.15cell',
  border_left_color = colors.border,
  border_right_color = colors.border,
  border_bottom_color = colors.border,
  border_top_color = colors.border,
}

-- Leader + keybindings
config.leader = { key = 'Space', mods = 'CTRL', timeout_milliseconds = 2000 }

config.keys = {
  { mods = 'LEADER', key = 'c', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
  { mods = 'LEADER', key = 'x', action = wezterm.action.CloseCurrentTab { confirm = false } },
  { mods = 'LEADER', key = 'b', action = wezterm.action.ActivateTabRelative(-1) },
  { mods = 'LEADER', key = 'n', action = wezterm.action.ActivateTabRelative(1) },
  { mods = 'LEADER', key = 'w', action = wezterm.action.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
  { mods = 'LEADER', key = '\\', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { mods = 'LEADER', key = '-', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' } },
  { mods = 'LEADER', key = 'h', action = wezterm.action.ActivatePaneDirection 'Left' },
  { mods = 'LEADER', key = 'j', action = wezterm.action.ActivatePaneDirection 'Down' },
  { mods = 'LEADER', key = 'k', action = wezterm.action.ActivatePaneDirection 'Up' },
  { mods = 'LEADER', key = 'l', action = wezterm.action.ActivatePaneDirection 'Right' },
  { mods = 'LEADER', key = 'LeftArrow', action = wezterm.action.AdjustPaneSize { 'Left', 5 } },
  { mods = 'LEADER', key = 'RightArrow', action = wezterm.action.AdjustPaneSize { 'Right', 5 } },
  { mods = 'LEADER', key = 'DownArrow', action = wezterm.action.AdjustPaneSize { 'Down', 5 } },
  { mods = 'LEADER', key = 'UpArrow', action = wezterm.action.AdjustPaneSize { 'Up', 5 } },
}

for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'LEADER',
    action = wezterm.action.ActivateTab(i - 1),
  })
end

table.insert(config.keys, {
  key = '0',
  mods = 'LEADER',
  action = wezterm.action.ActivateTab(9),
})

-- Tab bar
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_and_split_indices_are_zero_based = true

local function tab_title(tab_info)
  local title = tab_info.tab_title
  if title and #title > 0 then
    return title
  end
  return tab_info.active_pane.title
end

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local num = (tab.tab_index + 1) % 10
  local title = ' ' .. num .. ': ' .. tab_title(tab) .. ' '
  local left_edge_text = ''
  local right_edge_text = ''

  if tab_style == 'rounded' then
    title = num .. ': ' .. tab_title(tab)
    title = wezterm.truncate_right(title, max_width - 2)
    left_edge_text = wezterm.nerdfonts.ple_left_half_circle_thick
    right_edge_text = wezterm.nerdfonts.ple_right_half_circle_thick
  end

  if tab.is_active then
    return {
      { Background = { Color = colors.tab_bar_active_tab_bg } },
      { Foreground = { Color = colors.tab_bar_active_tab_fg } },
      { Text = left_edge_text },
      { Background = { Color = colors.tab_bar_active_tab_fg } },
      { Foreground = { Color = colors.tab_bar_text } },
      { Text = title },
      { Background = { Color = colors.tab_bar_active_tab_bg } },
      { Foreground = { Color = colors.tab_bar_active_tab_fg } },
      { Text = right_edge_text },
    }
  end
end)

-- Leader active indicator
wezterm.on('update-status', function(window, _)
  local solid_left_arrow = ''
  local arrow_foreground = { Foreground = { Color = colors.arrow_foreground_leader } }
  local arrow_background = { Background = { Color = colors.arrow_background_leader } }
  local prefix = ''

  if window:leader_is_active() then
    prefix = ' ' .. leader_prefix

    if tab_style == 'rounded' then
      solid_left_arrow = wezterm.nerdfonts.ple_right_half_circle_thick
    else
      solid_left_arrow = wezterm.nerdfonts.pl_left_hard_divider
    end

    local tabs = window:mux_window():tabs_with_info()

    if tab_style ~= 'rounded' then
      for _, tab_info in ipairs(tabs) do
        if tab_info.is_active and tab_info.tab_index == 0 then
          arrow_background = { Foreground = { Color = colors.tab_bar_active_tab_fg } }
          solid_left_arrow = wezterm.nerdfonts.pl_right_hard_divider
          break
        end
      end
    end
  end

  window:set_left_status(wezterm.format {
    { Background = { Color = colors.arrow_foreground_leader } },
    { Text = prefix },
    arrow_foreground,
    arrow_background,
    { Text = solid_left_arrow },
  })
end)

-- gui-startup (keep)
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
