local gh = function(x) return 'https://github.com/' .. x end

vim.pack.add({ gh('mfussenegger/nvim-lint') })

local ok, lint = pcall(require, 'lint')
if not ok then
    vim.notify("nvim-lint not yet loaded — restart Nvim to complete setup", vim.log.levels.WARN)
    return
end

lint.linters_by_ft = {
    python   = { "pylint" },
    markdown = { "markdownlint-cli2" },
}

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
    group    = vim.api.nvim_create_augroup("lint", { clear = true }),
    callback = function() lint.try_lint() end,
})
