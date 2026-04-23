local gh = function(x) return 'https://github.com/' .. x end

vim.pack.add({
    gh('williamboman/mason.nvim'),
    gh('williamboman/mason-lspconfig.nvim'),
})

local ok_mason, mason = pcall(require, 'mason')
if not ok_mason then
    vim.notify("mason not yet loaded — restart Nvim to complete setup", vim.log.levels.WARN)
    return
end

mason.setup({
    ui = {
        icons = {
            package_installed   = "+",
            package_pending     = "~",
            package_uninstalled = "-",
        },
    },
    max_concurrent_installers = 10,
})

local ok_mlsp, mlsp = pcall(require, 'mason-lspconfig')
if not ok_mlsp then return end

-- Ensures servers are installed; configuration is handled in lua/lsp/init.lua
mlsp.setup({
    ensure_installed = {
        "lua_ls",
        "bashls",
        "yamlls",
        "pyright",
        "marksman",
    },
    automatic_installation = false,
})
