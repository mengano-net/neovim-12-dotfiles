-- Leader keys must be set before ANY keymaps (including plugin keymaps).
-- Changing mapleader after keymaps are registered silently invalidates them.
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

require("plugins")
require("config")
require("lsp")
