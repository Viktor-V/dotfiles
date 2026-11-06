local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.max_fps = 240
config.animation_fps = 240

local leader_prefix = utf8.char(0x1f30a)

-- Keep (user)
-- On Windows, default to the actual default WSL distribution (the one marked
-- with '*' in `wsl -l -v`), then Debian, then any other installed distro.
-- Never point at a missing domain. On Linux/macOS (or with no WSL distros
-- at all) WezTerm falls back to the local domain.
if wezterm.target_triple:find('windows') then
  local wsl_names = {}
  for _, dom in ipairs(wezterm.default_wsl_domains()) do
    wsl_names[dom.distribution] = dom.name
  end

  local want = { 'Debian' }
  local ok, out = wezterm.run_child_process({ 'wsl.exe', '-l', '-v' })
  if ok and out and #out > 0 then
    local default_distro = wezterm.utf16_to_utf8(out):match('%*%s*(%S+)')
    if default_distro then
      table.insert(want, 1, default_distro)
    end
  end

  for _, distro in ipairs(want) do
    if wsl_names[distro] then
      config.default_domain = wsl_names[distro]
      break
    end
  end
  if config.default_domain == nil then
    for _, name in pairs(wsl_names) do
      config.default_domain = name
      break
    end
  end
end
config.font = wezterm.font('JetBrainsMono NF')
config.font_size = 14.0
config.window_close_confirmation = 'NeverPrompt'
config.window_decorations = 'RESIZE'
config.default_workspace = 'консоль'

-- Colors (Windows Terminal "Campbell" palette)
config.color_scheme = 'Campbell (Gogh)'

local colors = {
  arrow_foreground_leader = '#0078D4',
  arrow_background_leader = '#0C0C0C',
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
config.tab_max_width = 32

local tab_colors = {
  bar = '#0C0C0C',
  active_bg = '#0078D4',
  active_fg = '#FFFFFF',
  inactive_bg = '#1E1E1E',
  inactive_fg = '#CCCCCC',
  hover_bg = '#2D2D2D',
  hover_fg = '#FFFFFF',
}

config.colors = {
  tab_bar = {
    background = tab_colors.bar,
    active_tab = { bg_color = tab_colors.active_bg, fg_color = tab_colors.active_fg },
    inactive_tab = { bg_color = tab_colors.inactive_bg, fg_color = tab_colors.inactive_fg },
    inactive_tab_hover = { bg_color = tab_colors.hover_bg, fg_color = tab_colors.hover_fg },
    new_tab = { bg_color = tab_colors.inactive_bg, fg_color = tab_colors.inactive_fg },
    new_tab_hover = { bg_color = tab_colors.hover_bg, fg_color = tab_colors.hover_fg },
  },
}

-- Flat (non-rounded) tabs; padding is applied inside format-tab-title.
local function tab_title(tab_info)
  local title = tab_info.tab_title
  if title and #title > 0 then
    return title
  end
  return tab_info.active_pane.title
end

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local label = string.format('%d: %s', (tab.tab_index + 1) % 10, tab_title(tab))
  label = wezterm.truncate_right(label, math.max(1, max_width - 2))

  local bg = tab_colors.inactive_bg
  local fg = tab_colors.inactive_fg
  if tab.is_active then
    bg = tab_colors.active_bg
    fg = tab_colors.active_fg
  elseif hover then
    bg = tab_colors.hover_bg
    fg = tab_colors.hover_fg
  end

  return {
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Text = ' ' .. label .. ' ' },
  }
end)

-- Leader active indicator
wezterm.on('update-status', function(window, _)
  local prefix = ''
  local arrow = ''
  local arrow_foreground = { Foreground = { Color = colors.arrow_foreground_leader } }
  local arrow_background = { Background = { Color = colors.arrow_background_leader } }

  if window:leader_is_active() then
    prefix = ' ' .. leader_prefix
    arrow = wezterm.nerdfonts.pl_left_hard_divider

    for _, tab_info in ipairs(window:mux_window():tabs_with_info()) do
      if tab_info.is_active and tab_info.tab_index == 0 then
        arrow_background = { Foreground = { Color = colors.arrow_foreground_leader } }
        arrow = wezterm.nerdfonts.pl_right_hard_divider
        break
      end
    end
  end

  window:set_left_status(wezterm.format {
    { Background = { Color = colors.arrow_foreground_leader } },
    { Text = prefix },
    arrow_foreground,
    arrow_background,
    { Text = arrow },
  })
end)

-- Open the initial window maximized in the "консоль" workspace.
wezterm.on('gui-startup', function(cmd)
  local _, _, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

return config
