local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Augroups --------------------------------------------------------------------
local general    = augroup("general",    { clear = true })
local git        = augroup("git",        { clear = true })
local markdown   = augroup("markdown",   { clear = true })
local terminal   = augroup("terminal",   { clear = true })
local plantuml   = augroup("plantuml",   { clear = true })
local netrw      = augroup("netrw",      { clear = true })
local treesitter = augroup("treesitter", { clear = true })

-- Treesitter ------------------------------------------------------------------
-- Enable native treesitter highlighting for any filetype that has a parser.
-- Silently skips filetypes with no parser available.
autocmd("FileType", {
    group = treesitter,
    callback = function(ev)
        pcall(vim.treesitter.start, ev.buf)
    end,
})

-- Winbar ----------------------------------------------------------------------
-- Two-tone: light pill for path (dark text on light bg), red [+] on dark bar.
-- No patched-font glyphs -- plain ASCII only.
vim.api.nvim_set_hl(0, "WinBarPath",     { fg = "#363636", bg = "#dedede" })
vim.api.nvim_set_hl(0, "WinBarModified", { fg = "#ff3838", bg = "#363636" })

-- Evaluated dynamically on every redraw via %{%v:lua...%}
_G.WinbarEval = function()
    local path = vim.api.nvim_eval_statusline("%f", {}).str
    if path == "" then path = "[No Name]" end
    path = path:gsub("/", " > ")
    local modified = vim.bo.modified and "%#WinBarModified# [+]%*" or ""
    return "%#WinBarPath#  " .. path .. "  %*" .. modified
end

local winbar_excluded = {
    [""]         = true,
    netrw        = true,
    fugitive     = true,
    gitcommit    = true,
    help         = true,
    toggleterm   = true,
}

autocmd("BufWinEnter", {
    group = general,
    callback = function()
        if winbar_excluded[vim.bo.filetype] then
            vim.wo.winbar = ""
        else
            vim.wo.winbar = "%{%v:lua.WinbarEval()%}"
        end
    end,
})

-- General ---------------------------------------------------------------------
autocmd("TextYankPost", {
    group = general,
    callback = function()
        vim.hl.on_yank({ higroup = "IncSearch", timeout = 500 })
    end,
})

-- Git -------------------------------------------------------------------------
autocmd("FileType", {
    group = git,
    pattern = { "gitcommit", "gitrebase" },
    callback = function()
        vim.opt_local.spell     = true
        vim.opt_local.spelllang = "en"
        vim.cmd("startinsert | 1")
    end,
})

-- Markdown & prose ------------------------------------------------------------
-- Covers both markdown and LaTeX; consolidates what was two separate BufEnter
-- autocmds in the previous config
autocmd("FileType", {
    group = markdown,
    pattern = { "markdown", "tex" },
    callback = function()
        vim.opt_local.conceallevel  = 2
        vim.opt_local.spell         = true
        vim.opt_local.spelllang     = "en"
        vim.opt_local.linebreak     = true
        vim.opt_local.shiftwidth    = 2
        vim.opt_local.softtabstop   = 2
        vim.opt_local.tabstop       = 2
        vim.opt_local.formatoptions = "awtq"
    end,
})

-- Terminal --------------------------------------------------------------------
-- Terminal-mode keymaps (jk, <esc> to normal mode) live in keymaps.lua
autocmd("TermOpen", {
    group = terminal,
    pattern = "term://*",
    callback = function()
        vim.opt_local.number         = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn     = "no"
        vim.cmd("startinsert")
    end,
})

-- Netrw -----------------------------------------------------------------------
autocmd("FileType", {
    group = netrw,
    pattern = "netrw",
    callback = function()
        local opts = { buffer = true, silent = true }
        vim.keymap.set("n", "<leader>eR", "<C-l>", vim.tbl_extend("force", opts, { desc = "Refresh tree" }))
        vim.keymap.set("n", "<leader>eh", "gh",    vim.tbl_extend("force", opts, { remap = true, desc = "Toggle hidden files" }))
    end,
})

-- Close netrw when a file buffer is entered
autocmd("BufWinEnter", {
    group = netrw,
    callback = function()
        local ft = vim.bo.filetype
        local bt = vim.bo.buftype
        if ft == "netrw" or bt ~= "" then return end
        if vim.fn.isdirectory(vim.fn.expand("%")) == 1 then return end

        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "netrw" then
                vim.api.nvim_win_close(win, false)
                break
            end
        end
    end,
})

-- PlatUML ---------------------------------------------------------------------
autocmd({ "BufRead", "BufNewFile" }, {
    group = plantuml,
    pattern = "*.puml",
    callback = function()
        vim.opt_local.filetype    = "plantuml"
        vim.opt_local.shiftwidth  = 4
        vim.opt_local.softtabstop = 4
        vim.opt_local.tabstop     = 4
    end,
})
