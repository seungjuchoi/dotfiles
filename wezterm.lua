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
    }
  },
  color_scheme = "OceanicMaterial",
  -- hyperlink_rules = {
  --   {
  --     regex = '\\b[\\w.-]+\\.[a-z]{2,15}\\S*\\b',
  --     format = '$0',
  --   }
  -- }
}


