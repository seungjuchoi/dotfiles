require("seungju.base")
require("seungju.plugins")
require("seungju.keymap")

if vim.fn.has("macunix") == 1 then
    require("seungju.macos")
else
    require("seungju.windows")
end
