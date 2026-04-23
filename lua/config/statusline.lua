-- lua/config/statusline.lua
-- Native statusline — replaces nvim-lualine, no plugins required.
-- Rendered via %{%v:lua.StatuslineRender()%}; laststatus=3 (global bar) is
-- set in options.lua.
--
-- Sections (left → right):
--   [MODE]  [branch]          [diagnostics]  [filetype]  [words?]  [line:col  pct%]
--
-- NOTE: git diff counts (added/modified/removed) require gitsigns — wire up
-- when gitsigns is added to lua/plugins/.

local M = {}

-- Mode -------------------------------------------------------------------------
local mode_labels = {
    n        = "NORMAL",   no       = "N-OP",     nov      = "N-OP",
    noV      = "N-OP",     nt       = "NORMAL",
    v        = "VISUAL",   V        = "V-LINE",
    ["\22"]  = "V-BLOCK",
    s        = "SELECT",   S        = "S-LINE",   ["\19"]  = "S-BLOCK",
    i        = "INSERT",   ic       = "INSERT",   ix       = "INSERT",
    R        = "REPLACE",  Rc       = "REPLACE",  Rv       = "V-REPL",
    c        = "COMMAND",  cv       = "EX",       ce       = "EX",
    r        = "PROMPT",   rm       = "MORE",     ["r?"]   = "CONFIRM",
    ["!"]    = "SHELL",    t        = "TERMINAL",
}

local mode_hls = {
    n       = "SLNormal",
    v       = "SLVisual",  V       = "SLVisual",   ["\22"] = "SLVisual",
    s       = "SLVisual",  S       = "SLVisual",   ["\19"] = "SLVisual",
    i       = "SLInsert",  ic      = "SLInsert",   ix      = "SLInsert",
    R       = "SLReplace", Rc      = "SLReplace",  Rv      = "SLReplace",
    c       = "SLCommand", cv      = "SLCommand",  ce      = "SLCommand",
    t       = "SLTerminal",
}

-- Git branch -------------------------------------------------------------------
-- Reads .git/HEAD directly — fast synchronous read of a tiny file, no plugin.
local function git_branch()
    local root = vim.fs.find(".git", { upward = true, path = vim.fn.expand("%:p:h") })[1]
    if not root then return "" end
    local f = io.open(root .. "/HEAD", "r")
    if not f then return "" end
    local line = f:read("*l")
    f:close()
    if not line then return "" end
    return line:match("ref: refs/heads/(.+)") or line:sub(1, 7)
end

-- Diagnostics ------------------------------------------------------------------
local sev = vim.diagnostic.severity

local function diagnostics()
    local counts = vim.diagnostic.count(0)
    local parts = {}
    local map = {
        { sev.ERROR, "SLDiagError", "E:" },
        { sev.WARN,  "SLDiagWarn",  "W:" },
        { sev.INFO,  "SLDiagInfo",  "I:" },
        { sev.HINT,  "SLDiagHint",  "H:" },
    }
    for _, entry in ipairs(map) do
        local n = counts[entry[1]] or 0
        if n > 0 then
            table.insert(parts, "%#" .. entry[2] .. "#" .. entry[3] .. n)
        end
    end
    if #parts == 0 then return "" end
    return table.concat(parts, " ") .. "%*"
end

-- Word count -------------------------------------------------------------------
-- Only shown for prose filetypes (matches markdown/tex autocmd in autocmds.lua)
local prose_ft = { markdown = true, text = true, tex = true, rst = true }

local function word_count()
    if not prose_ft[vim.bo.filetype] then return "" end
    return "W:" .. vim.fn.wordcount().words
end

-- Excluded filetypes -----------------------------------------------------------
-- Mirrors lualine's disabled_filetypes; these get a plain filetype label only.
local excluded_ft = {
    [""]          = true,
    netrw         = true,
    fugitive      = true,
    gitcommit     = true,
    help          = true,
    toggleterm    = true,
    qf            = true,
    lspinfo       = true,
    man           = true,
}

-- Render -----------------------------------------------------------------------
function M.render()
    local ft = vim.bo.filetype

    if excluded_ft[ft] then
        return " " .. (ft ~= "" and ft or "?")
    end

    local mode   = vim.fn.mode()
    local label  = mode_labels[mode] or mode:upper()
    local hl     = mode_hls[mode] or "SLNormal"

    -- Left
    local s = "%#" .. hl .. "# " .. label .. " %*"

    local branch = git_branch()
    if branch ~= "" then
        s = s .. " %#SLBranch#  " .. branch .. " %*"
    end

    -- NOTE: git diff counts go here once gitsigns is wired up.
    -- Format: %#SLDiffAdd#+N %#SLDiffChange#~N %#SLDiffDelete#-N

    -- Right (pushed by %=)
    s = s .. "%="

    local diag = diagnostics()
    if diag ~= "" then
        s = s .. diag .. "  "
    end

    s = s .. "%#SLFiletype# " .. (ft ~= "" and ft or "?") .. " %* "

    local words = word_count()
    if words ~= "" then
        s = s .. words .. "  "
    end

    s = s .. "%l:%c  %p%% "

    return s
end

-- Highlights -------------------------------------------------------------------
-- Re-runs on ColorScheme so theme changes don't wipe our groups.
local function setup_highlights()
    -- Mode blocks (colored bg, dark text, bold)
    vim.api.nvim_set_hl(0, "SLNormal",   { fg = "#282c34", bg = "#61afef", bold = true })
    vim.api.nvim_set_hl(0, "SLInsert",   { fg = "#282c34", bg = "#98c379", bold = true })
    vim.api.nvim_set_hl(0, "SLVisual",   { fg = "#282c34", bg = "#c678dd", bold = true })
    vim.api.nvim_set_hl(0, "SLReplace",  { fg = "#282c34", bg = "#e06c75", bold = true })
    vim.api.nvim_set_hl(0, "SLCommand",  { fg = "#282c34", bg = "#e5c07b", bold = true })
    vim.api.nvim_set_hl(0, "SLTerminal", { fg = "#282c34", bg = "#56b6c2", bold = true })
    -- Contextual segments (muted bg)
    vim.api.nvim_set_hl(0, "SLBranch",   { fg = "#abb2bf", bg = "#3e4452" })
    vim.api.nvim_set_hl(0, "SLFiletype", { fg = "#abb2bf", bg = "#3e4452" })
    -- Diagnostics (fg only — rides on the StatusLine bg)
    vim.api.nvim_set_hl(0, "SLDiagError", { fg = "#e06c75" })
    vim.api.nvim_set_hl(0, "SLDiagWarn",  { fg = "#e5c07b" })
    vim.api.nvim_set_hl(0, "SLDiagInfo",  { fg = "#61afef" })
    vim.api.nvim_set_hl(0, "SLDiagHint",  { fg = "#98c379" })
end

setup_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("statusline_hl", { clear = true }),
    callback = setup_highlights,
})

-- Wire the global statusline ---------------------------------------------------
_G.StatuslineRender = M.render
vim.opt.statusline = "%{%v:lua.StatuslineRender()%}"

return M
