local gh = function(x) return 'https://github.com/' .. x end

-- Run :TSUpdate after install or update
vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
        if ev.data.spec.name == 'nvim-treesitter' and
           (ev.data.kind == 'install' or ev.data.kind == 'update') then
            vim.cmd('TSUpdate')
        end
    end,
})

vim.pack.add({ gh('nvim-treesitter/nvim-treesitter') })

local ok, configs = pcall(require, 'nvim-treesitter.configs')
if not ok then
    vim.notify("nvim-treesitter not yet loaded — restart Nvim to complete setup", vim.log.levels.WARN)
    return
end

-- Bundled parsers (c, lua, markdown, vimdoc) are already available.
-- Only list parsers that need to be downloaded.
configs.setup({
    ensure_installed = {
        "bash",
        "markdown_inline",
        "python",
        "toml",
        "yaml",
    },
    auto_install   = true,   -- install parser on first open of unknown filetype
    sync_install   = false,
    ignore_install = {},
    indent         = { enable = true },
    -- Highlighting is handled natively via vim.treesitter.start() in autocmds.lua
})
