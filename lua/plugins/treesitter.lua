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

-- nvim-treesitter `main` branch: no configs module and no setup() needed.
-- Highlighting is handled natively via vim.treesitter.start() in autocmds.lua.
local ok, ts = pcall(require, 'nvim-treesitter')
if not ok then
    vim.notify("nvim-treesitter not yet loaded — restart Nvim to complete setup", vim.log.levels.WARN)
    return
end

-- Building parsers needs the tree-sitter CLI (and a C compiler). Without it,
-- skip installs silently; bundled parsers (c, lua, markdown, vimdoc, ...) still work.
local can_build = vim.fn.executable('tree-sitter') == 1

-- Bundled parsers are already available. Only list parsers that need to be downloaded.
local ensure_installed = {
    "bash",
    "markdown_inline",
    "python",
    "toml",
    "yaml",
}

if can_build then
    local missing = vim.tbl_filter(function(lang)
        return not vim.list_contains(ts.get_installed(), lang)
    end, ensure_installed)
    if #missing > 0 then ts.install(missing) end
end

-- Treesitter indentation (experimental upstream)
local function enable_indent(buf)
    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
end

vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('treesitter_plugin', { clear = true }),
    callback = function(ev)
        local lang = vim.treesitter.language.get_lang(ev.match)
        if not lang then return end

        -- Parser already available (bundled with Nvim or installed)
        if vim.treesitter.language.add(lang) then
            enable_indent(ev.buf)
            return
        end

        -- Auto-install: parser on first open of a supported filetype, then highlight
        if can_build and vim.list_contains(ts.get_available(), lang) then
            ts.install(lang):await(function(err)
                if err then return end
                vim.schedule(function()
                    if vim.api.nvim_buf_is_valid(ev.buf) then
                        pcall(vim.treesitter.start, ev.buf)
                        enable_indent(ev.buf)
                    end
                end)
            end)
        end
    end,
})
