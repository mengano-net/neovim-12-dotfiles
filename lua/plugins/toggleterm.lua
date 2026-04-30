-- lua/plugins/toggleterm.lua
-- macOS:  no binary dependency — pure Lua plugin
-- CentOS: no binary dependency — pure Lua plugin

local gh = function(x) return 'https://github.com/' .. x end

vim.pack.add({ gh('akinsho/toggleterm.nvim') })

local ok, toggleterm = pcall(require, 'toggleterm')
if not ok then
    vim.notify("toggleterm not yet loaded — restart Nvim to complete setup", vim.log.levels.WARN)
    return
end

local function term_size(term)
    if term.direction == "horizontal" then
        return math.floor(vim.o.lines * 0.4)
    elseif term.direction == "vertical" then
        return math.floor(vim.o.columns * 0.4)
    end
end

toggleterm.setup({
    size            = term_size,
    open_mapping    = [[<c-\>]],
    hide_numbers    = true,
    start_in_insert = true,
    persist_size    = true,
    close_on_exit   = true,
    shell           = "zsh",
    float_opts      = { border = "rounded" },
})

-- Keymaps
local map = function(lhs, cmd, desc)
    vim.keymap.set("n", lhs, cmd, { silent = true, desc = desc })
end

map("<leader>tf", "<cmd>ToggleTerm direction=float<CR>",      "(f)loat terminal")
map("<leader>th", "<cmd>ToggleTerm direction=horizontal<CR>", "(h)orizontal terminal")
map("<leader>tv", "<cmd>ToggleTerm direction=vertical<CR>",   "(v)ertical terminal")
