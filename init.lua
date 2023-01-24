require("seungju.base")
require("seungju.plugins")
require("seungju.keymap")

local has = function(x)
  return vim.fn.has(x) == 1
end
local is_mac = has "macunix"
local is_win = has "win32"

if is_mac then
  require('seungju.macos')
elseif is_win then
  require('seungju.windows')
else
  require('seungju.other_os')
end
