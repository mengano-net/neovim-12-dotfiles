-- lua/plugins/fzf-lua.lua
-- Replaces telescope.nvim + plenary + fzf-native.
-- No build step — uses the system fzf binary directly.
--
-- LSP keymaps (gd, gr, ls, lt) are intentionally NOT here.
-- They will be wired in lua/lsp/ inside LspAttach, using fzf-lua as the
-- picker backend, so they only activate when an LSP client is attached.

local gh = function(x) return 'https://github.com/' .. x end

vim.pack.add({ gh('ibhagwan/fzf-lua') })

local ok, fzf = pcall(require, 'fzf-lua')
if not ok then
    vim.notify("fzf-lua not yet loaded — restart Nvim to complete setup", vim.log.levels.WARN)
    return
end

-- Setup -----------------------------------------------------------------------
-- Resolve fzf binary to full path so nvim finds it regardless of $PATH
-- (macOS GUI apps inherit a trimmed PATH that often misses /opt/homebrew/bin)
local fzf_bin = vim.fn.exepath("fzf")
if fzf_bin == "" then
    vim.notify("fzf-lua: fzf binary not found in PATH — install via `brew install fzf`", vim.log.levels.ERROR)
    return
end

fzf.setup({
    fzf_bin = fzf_bin,

    winopts = {
        height  = 0.40,
        width   = 1.00,
        row     = 1.00,       -- anchored to bottom, like old telescope layout_config
        border  = "none",
        preview = {
            layout     = "horizontal",
            horizontal = "right:50%",
        },
    },

    keymap = {
        fzf = {
            ["ctrl-q"] = "select-all+accept",   -- send all results to quickfix
        },
    },

    files = {
        -- Respect .gitignore; skip .git and node_modules
        fd_opts = "--color=never --type f --hidden --follow --exclude .git --exclude node_modules",
    },

    grep = {
        rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=512",
    },
})

-- Helpers ---------------------------------------------------------------------
-- Replicate telescope's smart git/non-git file finder
local function find_files()
    vim.fn.system("git rev-parse --is-inside-work-tree")
    if vim.v.shell_error == 0 then
        fzf.git_files({ prompt = "Git Files> " })
    else
        fzf.files()
    end
end

-- Keymaps ---------------------------------------------------------------------
local map = function(lhs, fn, desc)
    vim.keymap.set("n", lhs, fn, { silent = true, desc = desc })
end

-- Files group (<leader>f)
map("<leader>ff", find_files,                      "(f)ind files")
map("<leader>fb", fzf.blines,                      "fuzzy in (b)uffer")
map("<leader>fc", fzf.grep_cword,                  "grep under (c)ursor")
map("<leader>fs", fzf.live_grep,                   "(s)earch live grep")
map("<leader>fr", fzf.oldfiles,                    "(r)ecent files")
map("<leader>fj", fzf.jumps,                       "(j)ump list")

-- Buffers (<leader>b)
map("<leader>bl", fzf.buffers,                     "(l)ist buffers")

-- Vim meta (<leader>v)
map("<leader>vt", fzf.help_tags,                   "help (t)ags")
map("<leader>vc", fzf.commands,                    "(c)ommands")

-- LSP pickers (fzf-lua backed) ------------------------------------------------
-- Set buffer-local, only when an LSP client attaches — these keymaps depend on
-- an active LSP client. Non-picker LSP keymaps (hover, rename, etc.) live in
-- lua/lsp/ under LspAttach.
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("fzf_lsp_keymaps", { clear = true }),
    callback = function(ev)
        local lmap = function(lhs, fn, desc)
            vim.keymap.set("n", lhs, fn, { buffer = ev.buf, silent = true, desc = desc })
        end

        lmap("<leader>gd", fzf.lsp_definitions,      "(d)efinitions")
        lmap("<leader>gr", fzf.lsp_references,        "(r)eferences")
        lmap("<leader>ls", fzf.lsp_document_symbols,  "(s)ymbols")
        lmap("<leader>lt", fzf.lsp_typedefs,          "(t)ype definitions")
        lmap("<leader>gi", fzf.lsp_implementations,   "(i)mplementations")
    end,
})
