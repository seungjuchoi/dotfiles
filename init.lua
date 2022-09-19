require("seungju.base")
require("seungju.plugins")
require("seungju.keymap")

-- if vim.fn.has("macunix") == 1 then
--     require("seungju.macos")
-- else
--     require("seungju.windows")
-- end
local has = function(x)
  return vim.fn.has(x) == 1
end
local is_mac = has "macunix"
local is_win = has "win32"

if is_mac then
  require('seungju.macos')
end
if is_win then
  require('seungju.windows')
end
