-- Leader keys — must be set before any mappings are defined
vim.api.nvim_set_keymap("", "<Space>", "<Nop>", { noremap = true, silent = true })
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Spell -----------------------------------------------------------------------
-- Ensure the spell directory and .add file exist on first run
local spell_dir  = vim.fn.stdpath("config") .. "/spell"
local spell_file = spell_dir .. "/en.utf-8.add"

if vim.fn.isdirectory(spell_dir) == 0 then
    vim.uv.fs_mkdir(spell_dir, 493) -- 493 = 0o755
end

if vim.fn.filereadable(spell_file) == 0 then
    local ok, err = pcall(function()
        local fd = vim.uv.fs_open(spell_file, "w", 420) -- 420 = 0o644
        if fd then vim.uv.fs_close(fd) end
    end)
    if not ok then
        vim.notify("Could not create spell file: " .. spell_file, vim.log.levels.ERROR)
    end
end

vim.opt.spellfile  = spell_file
vim.opt.spelllang  = "en"
vim.opt.spell      = false -- enable per-filetype via autocmds

-- UI --------------------------------------------------------------------------
vim.opt.background    = "dark"
vim.opt.cmdheight     = 1
vim.opt.colorcolumn   = "80"
vim.opt.conceallevel  = 0
vim.opt.cursorline    = true
vim.opt.cursorcolumn  = false
vim.opt.laststatus    = 3   -- global statusline (single bar across all splits)
vim.opt.list          = true
vim.opt.number        = true
vim.opt.relativenumber = true
vim.opt.ruler         = true
vim.opt.showcmd       = false
vim.opt.showmode      = false
vim.opt.showbreak     = "> "
vim.opt.signcolumn    = "yes:2"
vim.opt.termguicolors = true
vim.opt.wildmenu      = true
vim.opt.wildoptions   = "pum"


-- Completion ------------------------------------------------------------------
-- NOTE: replace "preview" with "popup" once vim.lsp.completion is wired up;
-- "popup" renders the extra info as a floating window instead of a split scratch buffer
vim.opt.completeopt = "menu,menuone,preview,noselect,noinsert"
vim.opt.pumheight   = 20

-- Editing ---------------------------------------------------------------------
vim.opt.autoindent     = true
vim.opt.backspace      = "indent,eol,start"
vim.opt.breakindent    = true
vim.opt.breakindentopt = "shift:2"
vim.opt.expandtab      = true
vim.opt.shiftround     = true
vim.opt.shiftwidth     = 4
vim.opt.softtabstop    = 4
vim.opt.tabstop        = 4
vim.opt.textwidth      = 80

-- Search ----------------------------------------------------------------------
vim.opt.hlsearch   = true
vim.opt.incsearch  = true
vim.opt.ignorecase = false
vim.opt.smartcase  = true

-- Files & persistence ---------------------------------------------------------
vim.opt.autoread     = true
vim.opt.autowrite    = true
vim.opt.backup       = false
vim.opt.fileencoding = "utf-8"
vim.opt.swapfile     = false
vim.opt.undofile     = true
vim.opt.undodir      = os.getenv("HOME") .. "/.cache/nvim/undodir"
vim.opt.writebackup  = false

-- Navigation ------------------------------------------------------------------
vim.opt.scrolloff    = 5
vim.opt.sidescrolloff = 5
vim.opt.splitright   = true
vim.opt.splitbelow   = true
vim.opt.wrap         = true

-- Performance -----------------------------------------------------------------
vim.opt.redrawtime = 250
vim.opt.timeoutlen = 1000
vim.opt.updatetime = 150

-- Clipboard & input -----------------------------------------------------------
vim.opt.clipboard   = "unnamedplus"
vim.opt.mousescroll = "ver:0,hor:0"

-- Misc ------------------------------------------------------------------------
vim.opt.dictionary = "/usr/share/dict/words"
vim.opt.diffopt    = { "filler", "internal", "algorithm:histogram", "indent-heuristic" }

vim.opt.shortmess:append("c")
vim.opt.whichwrap:append("<,>,[,],h,l")
vim.opt.iskeyword:append("-,_")

-- netrw ---------------------------------------------------------------------
vim.g.netrw_altv         = 1   -- open vertical splits to the left (used by :Vex)
vim.g.netrw_liststyle    = 3   -- tree view
vim.g.netrw_winsize      = 45  -- 45% of window width
vim.g.netrw_browse_split = 4   -- open files in the previously active window

-- Disable unused built-in plugins ---------------------------------------------
-- netrw intentionally left enabled — using it as the native file browser (:Ex, :Vex, :Sex)
vim.g.loaded_gzip              = 1
vim.g.loaded_zip               = 1
vim.g.loaded_zipPlugin         = 1
vim.g.loaded_tar               = 1
vim.g.loaded_tarPlugin         = 1
vim.g.loaded_getscript         = 1
vim.g.loaded_getscriptPlugin   = 1
vim.g.loaded_vimball           = 1
vim.g.loaded_vimballPlugin     = 1
vim.g.loaded_2html_plugin      = 1
vim.g.loaded_logipat           = 1
vim.g.loaded_rrhelper          = 1
vim.g.loaded_matchit           = 1
