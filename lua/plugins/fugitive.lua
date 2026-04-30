-- lua/plugins/fugitive.lua
-- macOS:  no binary dependency — pure Vim plugin
-- CentOS: no binary dependency — pure Vim plugin

local gh = function(x) return 'https://github.com/' .. x end

vim.pack.add({ gh('tpope/vim-fugitive') })

-- Keymaps
local map = function(lhs, cmd, desc)
    vim.keymap.set("n", lhs, cmd, { silent = true, desc = desc })
end

map("<leader>Gs", ":Ge:<CR>",          "(s)taging area")
map("<leader>Gc", ":Git commit -s<CR>", "(c)ommit signed")
map("<leader>Gp", ":Git pull<CR>",      "(p)ull")
map("<leader>GP", ":Git push<CR>",      "(P)ush")
