local wezterm = require 'wezterm'

return {
  font = wezterm.font_with_fallback {
    'JetBrains Mono',
    {family = 'Monoplex KR', weight = 'Medium'},
    'Apple SD Gothic Neo',
    -- 'Hack Nerd Font',
    'Fira Code',
    'DengXian',
  },
  font_size = 13,
  use_ime = true,
  keys = {
    {
      key = 'Enter',
      mods = 'ALT',
      action = wezterm.action.DisableDefaultAssignment,
    },
    {
      key = 'LeftArrow',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.DisableDefaultAssignment,
    },
    {
      key = 'RightArrow',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.DisableDefaultAssignment,
    },
    {
      key = 'DownArrow',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.DisableDefaultAssignment,
    },
    {
      key = 'UpArrow',
      mods = 'CTRL|SHIFT',
      action = wezterm.action.DisableDefaultAssignment,
    },
    {
      key = 'Backspace',
      mods = 'CMD',
      action = wezterm.action.SendKey { key = 'u', mods = 'CTRL' }
    },
    { key = '/',
      mods = 'SHIFT|CTRL',
      action = wezterm.action.QuickSelect
    },
  },
  color_scheme = "ayu",
  -- hyperlink_rules = {
  --   {
  --     regex = '\\b[\\w.-]+\\.[a-z]{2,15}\\S*\\b',
  --     format = '$0',
  --   }
  -- }
}


