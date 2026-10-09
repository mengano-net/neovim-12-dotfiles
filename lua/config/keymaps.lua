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
-- :Lexplore hardcodes bufhidden=wipe and builds a new tree every time, which loses
-- expanded dirs + cursor. Keep one netrw buffer alive and re-show it instead.
local explorer_buf
local explorer_wvars = {}

-- netrw keeps tree state (w:netrw_treetop, w:netrw_treedict, ...) in window-local
-- variables, so they must be carried over to the new window on reopen. netrw clears
-- them while opening a file, so snapshot while the explorer is live and only accept
-- snapshots that still have a treetop.
local function snapshot_explorer(win)
    if not (explorer_buf and win and vim.api.nvim_win_is_valid(win)) then return end
    if vim.api.nvim_win_get_buf(win) ~= explorer_buf then return end
    local vars = {}
    for k, v in pairs(vim.fn.getwinvar(win, "")) do
        if k:match("^netrw_") then vars[k] = v end
    end
    if vars.netrw_treetop then explorer_wvars = vars end
end

vim.api.nvim_create_autocmd({ "CursorMoved", "WinLeave", "BufLeave", "WinClosed" }, {
    group = vim.api.nvim_create_augroup("netrw_explorer_state", { clear = true }),
    callback = function(args)
        snapshot_explorer(args.event == "WinClosed" and tonumber(args.match) or vim.api.nvim_get_current_win())
    end,
})

local function toggle_explorer()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == explorer_buf then
            snapshot_explorer(win)
            vim.api.nvim_win_close(win, false)
            return
        end
    end
    if explorer_buf and vim.api.nvim_buf_is_valid(explorer_buf) then
        local width = math.floor(vim.o.columns * vim.g.netrw_winsize / 100)
        vim.cmd(("topleft vertical sbuffer %d"):format(explorer_buf))
        vim.cmd(("vertical resize %d"):format(width))
        vim.wo.winfixwidth = true
        for k, v in pairs(explorer_wvars) do vim.w[k] = v end
    else
        vim.cmd("Lexplore")
        explorer_buf = vim.api.nvim_get_current_buf()
        vim.bo[explorer_buf].bufhidden = "hide"
    end
end
map("n", "<leader>ee", toggle_explorer, { silent = true, desc = "Toggle file explorer" })

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
