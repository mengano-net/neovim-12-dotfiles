local map = vim.keymap.set

-- Insert mode ----------------------------------------------------------------
map("i", "jk", "<Esc>", { silent = true, desc = "Exit insert mode" })

-- Undo breakpoints (insert mode) ---------------------------------------------
-- Creates undo checkpoints at punctuation so u undoes in smaller chunks
map("i", ",", ",<C-g>u")
map("i", ".", ".<C-g>u")
map("i", "!", "!<C-g>u")
map("i", "?", "?<C-g>u")

-- Registers ------------------------------------------------------------------
-- x should not yank into the default register
map("n", "x", '"_x', { desc = "Delete char without yanking" })
-- Paste from yank register, not delete register
map("n", "<leader>p", '"0p', { desc = "Paste from yank register" })

-- File explorer --------------------------------------------------------------
map("n", "<leader>ee", ":Lexplore<CR>", { silent = true, desc = "Toggle file explorer" })

-- Buffers --------------------------------------------------------------------
map("n", "<Tab>",   ":bnext<CR>",     { silent = true, desc = "Next buffer" })
map("n", "<S-Tab>", ":bprevious<CR>", { silent = true, desc = "Previous buffer" })

-- Window navigation ----------------------------------------------------------
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Splits ---------------------------------------------------------------------
map("n", "<leader>sv", "<cmd>vnew<CR><C-w>l", { desc = "(s)plit (v)ertical" })
map("n", "<leader>sh", "<cmd>new<CR><C-w>j",  { desc = "(s)plit (h)orizontal" })

-- Search ---------------------------------------------------------------------
map("n", "n", "nzzzv", { desc = "Next result (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev result (centered)" })
map("n", "<leader>nh", ":nohlsearch<CR>", { silent = true, desc = "Clear search highlights" })

-- Editing --------------------------------------------------------------------
-- Keep cursor position when joining lines
map("n", "J", "mzJ`z", { desc = "Join lines (keep cursor)" })

-- Visual mode ----------------------------------------------------------------
-- Replace all instances of visual selection globally
map("v", "<leader>Er", '"hy:%s/<C-r>h//g<left><left>', { desc = "Replace all instances of selection" })
-- Retain selection after indent
map("v", "<", "<gv", { desc = "Indent left (keep selection)" })
map("v", ">", ">gv", { desc = "Indent right (keep selection)" })
-- Move selected block up/down
map("v", "J", ":m '>+1<CR>gv=gv", { silent = true, desc = "Move block down" })
map("v", "K", ":m '<-2<CR>gv=gv", { silent = true, desc = "Move block up" })

-- Terminal mode ---------------------------------------------------------------
map("t", "jk",    [[<C-\><C-n>]], { silent = true, desc = "Exit terminal mode" })
map("t", "<Esc>", [[<C-\><C-n>]], { silent = true, desc = "Exit terminal mode" })
