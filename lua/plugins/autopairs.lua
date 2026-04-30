-- lua/plugins/autopairs.lua
-- macOS:  `brew install` not needed — pure Lua, no binary dependency
-- CentOS: same — no binary dependency

local gh = function(x) return 'https://github.com/' .. x end

vim.pack.add({ gh('windwp/nvim-autopairs') })

local ok, autopairs = pcall(require, 'nvim-autopairs')
if not ok then
    vim.notify("nvim-autopairs not yet loaded — restart Nvim to complete setup", vim.log.levels.WARN)
    return
end

autopairs.setup({
    check_ts = true,
    ts_config = {
        lua        = { "string", "source" },
        javascript = { "string", "template_string" },
        python     = { "string" },
    },
    disable_filetype = { "TelescopePrompt" },
    -- fast_wrap intentionally omitted — not used in prior workflow
})
