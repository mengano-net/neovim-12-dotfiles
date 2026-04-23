local gh = function(x) return 'https://github.com/' .. x end

vim.pack.add({ gh('stevearc/conform.nvim') })

local ok, conform = pcall(require, 'conform')
if not ok then
    vim.notify("conform.nvim not yet loaded — restart Nvim to complete setup", vim.log.levels.WARN)
    return
end

conform.setup({
    formatters_by_ft = {
        bash       = { "beautysh" },
        css        = { "prettier" },
        html       = { "prettier" },
        json       = { "prettier" },
        javascript = { "prettier" },
        lua        = { "stylua" },
        markdown   = { "markdownlint-cli2" },
        python     = { "isort", "black" },
        sh         = { "beautysh" },
        zsh        = { "beautysh" },
    },
    format_on_save = { timeout_ms = 5000, lsp_format = "fallback" },
})

vim.keymap.set({ "n", "v" }, "<leader>lf", function()
    -- Write first so file-based formatters (e.g. markdownlint-cli2) operate on current content
    vim.cmd("silent! write")
    conform.format({
        async      = false,
        timeout_ms = 5000,
        lsp_format = "fallback", -- fall back to LSP formatting if no formatter configured
    })
    -- Trigger linting after formatting
    local ok_lint, lint = pcall(require, 'lint')
    if ok_lint then lint.try_lint() end
end, { desc = "(f)ormat buffer or range" })
