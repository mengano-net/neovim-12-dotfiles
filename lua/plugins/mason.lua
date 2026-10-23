local gh = function(x) return 'https://github.com/' .. x end

vim.pack.add({ gh('williamboman/mason.nvim') })

local ok_mason, mason = pcall(require, 'mason')
if not ok_mason then
    vim.notify("mason not yet loaded — restart Nvim to complete setup", vim.log.levels.WARN)
    return
end

-- Mason prepends its bin dir to PATH, so everything below is found by
-- vim.lsp (lua/lsp/init.lua), conform, nvim-lint, and nvim-treesitter.
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

-- Every external tool the config uses, by Mason package name.
-- Installed automatically on startup when missing; update with :Mason -> U.
local ensure_installed = {
    -- Language servers (configured in lua/lsp/init.lua)
    "lua-language-server",  -- lua_ls; also the Lua formatter
    "pyright",
    "bash-language-server",
    "yaml-language-server",
    "marksman",
    "json-lsp",
    "terraform-ls",
    -- Formatters (lua/plugins/conform.lua)
    "black",
    "isort",
    "prettier",
    "beautysh",
    -- Linters (lua/plugins/lint.lua); markdownlint-cli2 also formats markdown
    "pylint",
    "markdownlint-cli2",
    -- Builds treesitter parsers (lua/plugins/treesitter.lua)
    "tree-sitter-cli",
}

-- Install after the UI attaches; skipped in headless runs (CI, scripts)
vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("mason_ensure_installed", { clear = true }),
    once = true,
    callback = function()
        if #vim.api.nvim_list_uis() == 0 then return end
        local registry = require("mason-registry")
        registry.refresh(function()
            for _, name in ipairs(ensure_installed) do
                local ok, pkg = pcall(registry.get_package, name)
                if not ok then
                    vim.notify("mason: unknown package " .. name, vim.log.levels.WARN)
                elseif not pkg:is_installed() and not pkg:is_installing() then
                    vim.notify("mason: installing " .. name)
                    pkg:install({}, function(success, err)
                        if success then return end
                        vim.schedule(function()
                            vim.notify(("mason: failed to install %s: %s"):format(name, tostring(err)),
                                vim.log.levels.WARN)
                        end)
                    end)
                end
            end
        end)
    end,
})
