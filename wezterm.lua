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
      key = 'Enter',
      mods = 'SHIFT',
      action = wezterm.action{SendString="\x1b\r"},
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
    { key = '[',
      mods = 'SHIFT|CTRL',
      action = wezterm.action.MoveTabRelative(-1),
    },
    { key = ']',
      mods = 'SHIFT|CTRL',
      action = wezterm.action.MoveTabRelative(1),
    },
    { key = 'c',
      mods = 'ALT',
      action = wezterm.action.CopyTo 'Clipboard'
    },
    { key = 'v',
      mods = 'ALT',
      action = wezterm.action.PasteFrom 'Clipboard'
    },
  },
  quick_select_patterns = {
    "\\bcroc\\s+\\S*",
    "^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
  },
  color_scheme = "tokyonight",
}

