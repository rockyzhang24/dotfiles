local wezterm = require('wezterm')
local act = wezterm.action
local config = wezterm.config_builder()

-- Support for undercurl, etc.
config.term = 'wezterm'

-- Only keep the resizable border
config.window_decorations = "RESIZE"

-- Font
config.font = wezterm.font('MonoLisa Nerd Font', { weight = 'Regular' })
config.font_size = 14
-- Disable ligatures
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

-- Adjust underline style
config.underline_position = -6
config.underline_thickness = '150%'

-- Remove extra space
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

-- Color scheme
config.color_scheme = 'monokai'

-- Tab bar
config.window_frame = {
  font = wezterm.font('MonoLisa Nerd Font', { weight = 'Bold' }),
  font_size = 11,
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

-- Status bar
-- Name of the current workspace | Hostname
wezterm.on('update-status', function(window)
  -- utf8 character for the powerline left solid arrow
  local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
  --Add what will be displayed on the status bar here
  local sections = {
    window:active_workspace(),
    wezterm.hostname(),
  }
  -- Get the palette of the current color theme
  local color_scheme = window:effective_config().resolved_palette
  -- parse returns a Color object that has functions for lightening and darkening
  local bg = wezterm.color.parse(color_scheme.background)
  local fg = color_scheme.foreground
  -- Create gradients for the background color of each section
  local gradient_to = bg
  local gradient_from = gradient_to:lighten(0.2)
  local gradients = wezterm.color.gradient({
    orientation = 'Horizontal',
    colors = { gradient_from, gradient_to },
  }, #sections)
  -- Render
  local elements = {}
  for i, sec in ipairs(sections) do
    if i == 1 then
      table.insert(elements, { Background = { Color = 'none' } })
    end
    table.insert(elements, { Foreground = { Color = gradients[i] } })
    table.insert(elements, { Text = SOLID_LEFT_ARROW })
    table.insert(elements, { Foreground = { Color = fg } })
    table.insert(elements, { Background = { Color = gradients[i] } })
    table.insert(elements, { Text = ' ' .. sec .. ' ' })
  end
  window:set_right_status(wezterm.format(elements))
end)

-- Session
-- Wezterm uses workspace as the session-wise functionality in tmux.
-- To delete the current workspace: run `exit` in shell.
-- List the projects (there paths) to choose from. Create a workspace (session) with the last path
-- segment as its name if it doesn't exist, otherwise switch to the workspace.
-- Ref: https://alexplescan.com/posts/2024/08/10/wezterm/
local function sessionizer()
  local choices = {}
  for _, dir in ipairs(wezterm.glob(wezterm.home_dir .. '/projects/*/*')) do
    table.insert(choices, { label = dir })
  end
  return act.InputSelector({
    title = 'Projects',
    choices = choices,
    fuzzy = true,
    action = wezterm.action_callback(function(window, pane, id, label)
      if not label then
        return
      end
      window:perform_action(act.SwitchToWorkspace({
        name = label:match("([^/]+)$"),
        spawn = { cwd = label },
      }), pane)
    end),
  })
end

-- Key bindings
-- See all available actions: https://wezfurlong.org/wezterm/config/lua/keyassignment/index.html
config.disable_default_key_bindings = true
-- CTRL-, as the leader key
config.leader = { key = ',', mods = 'CTRL' }
config.keys = {
  { key = 'c', mods = 'CMD', action = act.CopyTo('Clipboard') },
  { key = 'v', mods = 'CMD', action = act.PasteFrom('Clipboard') },
  { key = 'v', mods = 'CTRL|SHIFT', action = act.ActivateCopyMode },
  { key = 'f', mods = 'CMD', action = act.Search('CurrentSelectionOrEmptyString') },
  { key = 's', mods = 'CTRL|SHIFT', action = act.QuickSelect },
  { key = 'e', mods = 'CTRL|SHIFT', action = act.CharSelect },
  { key = 'i', mods = 'CMD|OPT', action = act.ShowDebugOverlay },
  { key = 'p', mods = 'CMD|SHIFT', action = act.ActivateCommandPalette },
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
  { key = '\\', mods = 'CTRL|SHIFT', action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },
  { key = 'w', mods = 'CTRL|SHIFT', action = act.CloseCurrentPane({ confirm = true }) },
  { key = 'h', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection('Left') },
  { key = 'l', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection('Right') },
  { key = 'j', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection('Down') },
  { key = 'k', mods = 'CTRL|SHIFT', action = act.ActivatePaneDirection('Up') },
  { key = '9', mods = 'CTRL', action = act.PaneSelect },
  { key = '0', mods = 'CTRL', action = act.PaneSelect({ mode = 'SwapWithActiveKeepFocus' }) },
  { key = 'z', mods = 'CTRL|SHIFT', action = act.TogglePaneZoomState },
  { key = 'r', mods = 'CTRL|SHIFT', action = act.ActivateKeyTable({
    name = 'resize_panes',
    one_shot = false,
  }) },
  -- Scroll
  { key = 'u', mods = 'CTRL|SHIFT', action = act.ScrollByPage(-0.5) },
  { key = 'd', mods = 'CTRL|SHIFT', action = act.ScrollByPage(0.5) },
  { key = 'n', mods = 'CTRL|SHIFT', action = act.ScrollToPrompt(-1) },
  { key = 'p', mods = 'CTRL|SHIFT', action = act.ScrollToPrompt(1) },
  -- Session
  { key = 's', mods = 'LEADER', action = sessionizer() }, -- create or switch
  { key = 'l', mods = 'LEADER', action = act.ShowLauncherArgs({ flags = 'FUZZY|WORKSPACES' }) }, -- list existing ones and switch
}

-- Key tables
config.key_tables = {
  resize_panes = {
    { key = 'h', action = act.AdjustPaneSize({ 'Left', 3 }) },
    { key = 'l', action = act.AdjustPaneSize({ 'Right', 3 }) },
    { key = 'j', action = act.AdjustPaneSize({ 'Down', 3 }) },
    { key = 'k', action = act.AdjustPaneSize({ 'Up', 3 }) },
    -- Cancel the mode by pressing escape
    { key = 'Escape', action = 'PopKeyTable' },
  },
}

return config
