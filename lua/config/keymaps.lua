local map = vim.keymap.set

-- Terminal mode ---------------------------------------------------------------
-- Exit terminal insert mode
map("t", "jk",    [[<C-\><C-n>]], { silent = true, desc = "Exit terminal mode" })
map("t", "<Esc>", [[<C-\><C-n>]], { silent = true, desc = "Exit terminal mode" })
