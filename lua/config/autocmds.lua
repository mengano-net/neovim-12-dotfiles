local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Augroups --------------------------------------------------------------------
local general  = augroup("general",  { clear = true })
local git      = augroup("git",      { clear = true })
local markdown = augroup("markdown", { clear = true })
local terminal = augroup("terminal", { clear = true })
local plantuml = augroup("plantuml", { clear = true })

-- Winbar ----------------------------------------------------------------------
vim.api.nvim_set_hl(0, "WinBarPath",     { fg = "#dedede", bg = "#363636" })
vim.api.nvim_set_hl(0, "WinBarModified", { fg = "#ff3838", bg = "#363636" })

-- Evaluated dynamically on every redraw via %{%v:lua...%}
_G.WinbarEval = function()
    local path = vim.fn.expand("%:~:.")
    path = path:gsub("/", " > ")
    local modified = vim.bo.modified and " [+]" or ""
    return "%#WinBarPath#  " .. path .. "%#WinBarModified#" .. modified .. "%*"
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
        vim.opt_local.spelllang     = "en_us"
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
