local wezterm = require 'wezterm';
local act = wezterm.action

local function basename(s)
  return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local index = tab.tab_index + 1
  local title = tab.active_pane.title
  local pane = tab.active_pane
  local progress = basename(pane.foreground_process_name)
  local text = index .. ": " .. title .. " [" .. progress .. "]"
  return {
    { Text = text },
  }
end)

local config = {
  term = "xterm-wezterm",
  font = wezterm.font("JetBrainsMono Nerd Font"),
  font_size = 14,
  adjust_window_size_when_changing_font_size = false,
  custom_block_glyphs = false,
  harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
  color_scheme = "arctic",
  hide_tab_bar_if_only_one_tab = true,
  initial_cols = 120,
  initial_rows = 40,
  window_padding = {
    left = 2,
    right = 5,
    top = 0,
    bottom = 0,
  },
  native_macos_fullscreen_mode = false,
  -- window_background_opacity = 0.92,
  window_decorations = "RESIZE",
  enable_scroll_bar = true,
  hyperlink_rules = {
    {
      regex = "\\b\\w+://[\\w.-]+\\.[a-z]{2,15}\\S*\\b",
      format = "$0",
    },
    {
      regex = [[\b\w+@[\w-]+(\.[\w-]+)+\b]],
      format = "mailto:$0",
    },
    {
      regex = [[\bfile://\S*\b]],
      format = "$0",
    },
    {
      regex = [[\b\w+://(?:[\d]{1,3}\.){3}[\d]{1,3}\S*\b]],
      format = "$0",
    },
    {
      regex = [[["]?([\w\d]{1}[-\w\d]+)(/){1}([-\w\d\.]+)["]?]],
      format = "https://www.github.com/$1/$3",
    }
  },

  -- Keybindings
  send_composed_key_when_left_alt_is_pressed = true,
  send_composed_key_when_right_alt_is_pressed = false,
  disable_default_key_bindings = true,
  leader = { key = "m", mods = "CTRL", timeout_milliseconds = 1000 },
  keys = {

    -- Basic
    { key = "n", mods = "CMD", action = act.SpawnWindow },
    { key = "m", mods = "CMD", action = act.Hide },
    { key = "h", mods = "CMD", action = act.HideApplication },
    { key = "q", mods = "CMD", action = wezterm.action.QuitApplication },
    { key = "M", mods = "CTRL|SHIFT", action = wezterm.action.ToggleFullScreen },
    { key = "c", mods = "CMD", action = act.CopyTo 'Clipboard' },
    { key = "v", mods = "CMD", action = act.PasteFrom 'Clipboard' },

    -- Scroll
    { key = "B", mods = "CTRL|SHIFT", action = act.ScrollByPage(-1) },
    { key = "F", mods = "CTRL|SHIFT", action = act.ScrollByPage(1) },
    { key = "g", mods = "LEADER", action = act.ScrollToTop },
    { key = "G", mods = "LEADER|SHIFT", action = act.ScrollToBottom },
    { key = "Z", mods = "CTRL|SHIFT", action = act.ScrollToPrompt(-1) },
    { key = "X", mods = "CTRL|SHIFT", action = act.ScrollToPrompt(1) },

    -- Tab
    { key = "t", mods = "CMD", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "w", mods = "CMD", action = act.CloseCurrentTab { confirm = true } },
    { key = "{", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
    { key = "}", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(1) },
    { key = "<", mods = "CTRL|SHIFT", action = act.MoveTabRelative(-1) },
    { key = ">", mods = "CTRL|SHIFT", action = act.MoveTabRelative(1) },
    { key = "1", mods = "CMD", action = act.ActivateTab(0) },
    { key = "2", mods = "CMD", action = act.ActivateTab(1) },
    { key = "3", mods = "CMD", action = act.ActivateTab(2) },
    { key = "4", mods = "CMD", action = act.ActivateTab(3) },
    { key = "5", mods = "CMD", action = act.ActivateTab(4) },
    { key = "6", mods = "CMD", action = act.ActivateTab(5) },
    { key = "7", mods = "CMD", action = act.ActivateTab(6) },
    { key = "8", mods = "CMD", action = act.ActivateTab(7) },
    { key = "9", mods = "CMD", action = act.ActivateTab(8) },

    -- Font size
    { key = "=", mods = "CMD", action = act.IncreaseFontSize },
    { key = "-", mods = "CMD", action = act.DecreaseFontSize },
    { key = "0", mods = "CMD", action = act.ResetFontSize },

    -- Window
    { key = "_", mods = "CTRL|SHIFT", action = act.SplitVertical { domain = "CurrentPaneDomain" } },
    { key = "|", mods = "CTRL|SHIFT", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
    { key = "W", mods = "CTRL|SHIFT", action = act.CloseCurrentPane { confirm = true } },
    { key = "H", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Left") },
    { key = "L", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Right") },
    { key = "J", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Down") },
    { key = "K", mods = "CTRL|SHIFT", action = act.ActivatePaneDirection("Up") },
    { key = "LeftArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize { "Left", 5 } },
    { key = "RightArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize { "Right", 5 } },
    { key = "DownArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize { "Down", 5 } },
    { key = "UpArrow", mods = "CTRL|SHIFT", action = act.AdjustPaneSize { "Up", 5 } },
    { key = "9", mods = "CTRL", action = act.PaneSelect },
    { key = "0", mods = "CTRL", action = act.PaneSelect { mode = "SwapWithActive" } },

    -- Misc
    { key = "f", mods = "CMD", action = act.Search { CaseSensitiveString = "" } },
    { key = " ", mods = "CTRL|SHIFT", action = act.QuickSelect },
    { key = "V", mods = "CTRL|SHIFT", action = act.ActivateCopyMode },
    { key = " ", mods = "CMD|CTRL", action = act.CharSelect },

    -- Fix Ctrl-q on macOS
    { key = "q", mods = "CTRL", action = wezterm.action.SendString '\x11' },
    { key = "Enter", mods = "SHIFT", action = wezterm.action.SendString '\x1b[13;2u' },
  },
}

return config
