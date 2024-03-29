local wezterm = require('wezterm')
local act = wezterm.action
local config = wezterm.config_builder()

-- Support for undercurl, etc.
config.term = 'wezterm'

-- Only keep the resizable border
config.window_decorations = "RESIZE"

-- Font
config.font = wezterm.font('IosevkaTerm Nerd Font', { weight = 'Medium' })
config.font_size = 15
-- Disable ligatures
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

-- Adjust underline style
config.underline_position = -6
config.underline_thickness = 2

-- Remove extra space
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

-- Color scheme
config.color_scheme = 'arctic'

-- Tab bar
config.window_frame = {
  font = wezterm.font('IosevkaTerm Nerd Font', { weight = 'DemiBold' }),
  font_size = 13,
}
-- Tab bar title
wezterm.on('format-tab-title', function(tab)
  -- Get the process name.
  local process = string.gsub(tab.active_pane.foreground_process_name, '(.*[/\\])(.*)', '%2')
  -- Current working directory.
  local cwd = tab.active_pane.current_working_dir
  cwd = cwd and string.format('%s ', cwd.file_path:gsub(os.getenv 'HOME', '~')) or ''
  -- Format and return the title.
  return string.format('(%d %s) %s', tab.tab_index + 1, process, cwd)
end)

-- Key binding
config.disable_default_key_bindings = true
config.keys = {
  { key = 'c', mods = 'CMD', action = act.CopyTo('Clipboard') },
  { key = 'v', mods = 'CMD', action = act.PasteFrom('Clipboard') },
  { key = 'v', mods = 'CTRL|SHIFT', action = act.ActivateCopyMode },
  { key = 'f', mods = 'CMD', action = act.Search('CurrentSelectionOrEmptyString') },
  { key = 's', mods = 'CTRL|SHIFT', action = act.QuickSelect },
  { key = 'e', mods = 'CTRL|SHIFT', action = act.CharSelect },
  -- Tab
  { key = 't', mods = 'CMD', action = act.SpawnTab('CurrentPaneDomain') },
  { key = 'w', mods = 'CMD', action = act.CloseCurrentTab { confirm = true } },
  { key = '1', mods = 'CMD', action = act.ActivateTab(0) },
  { key = '2', mods = 'CMD', action = act.ActivateTab(1) },
  { key = '3', mods = 'CMD', action = act.ActivateTab(2) },
  { key = '4', mods = 'CMD', action = act.ActivateTab(3) },
  { key = '5', mods = 'CMD', action = act.ActivateTab(4) },
  { key = '6', mods = 'CMD', action = act.ActivateTab(5) },
  { key = '7', mods = 'CMD', action = act.ActivateTab(6) },
  { key = '8', mods = 'CMD', action = act.ActivateTab(7) },
  { key = '9', mods = 'CMD', action = act.ActivateTab(8) },
  { key = '[', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },
  { key = ']', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(1) },
  { key = ',', mods = 'CTRL|SHIFT', action = act.MoveTabRelative(-1) },
  { key = '.', mods = 'CTRL|SHIFT', action = act.MoveTabRelative(1) },
  -- Pane
  { key = '_', mods = 'CTRL|SHIFT', action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },
  { key = 'Delete', mods = 'CTRL|SHIFT', action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
  { key = 'w', mods = 'CTRL|SHIFT', action = act.CloseCurrentPane({ confirm = true }) },
  { key = 'h', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection('Left') },
  { key = 'l', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection('Right') },
  { key = 'j', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection('Down') },
  { key = 'k', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection('Up') },
  { key = '9', mods = 'CTRL', action = act.PaneSelect },
  { key = '0', mods = 'CTRL', action = act.PaneSelect({ mode = 'SwapWithActive' }) },
  -- Scroll
  { key = 'u', mods = 'CTRL|SHIFT', action = act.ScrollByPage(-0.5) },
  { key = 'd', mods = 'CTRL|SHIFT', action = act.ScrollByPage(0.5) },
  { key = 'n', mods = 'CTRL|SHIFT', action = act.ScrollToPrompt(-1) },
  { key = 'p', mods = 'CTRL|SHIFT', action = act.ScrollToPrompt(1) },
}

return config
