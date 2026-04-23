-- Capabilities ---------------------------------------------------------------
local capabilities = vim.tbl_deep_extend(
    "force",
    vim.lsp.protocol.make_client_capabilities(),
    {
        textDocument = {
            foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly     = true,
            },
        },
    }
)

-- Diagnostics -----------------------------------------------------------------
vim.diagnostic.config({
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "E",
            [vim.diagnostic.severity.WARN]  = "W",
            [vim.diagnostic.severity.HINT]  = "H",
            [vim.diagnostic.severity.INFO]  = "I",
        },
    },
    virtual_text     = false,
    underline        = true,
    update_in_insert = true,
    severity_sort    = true,
    float = {
        border    = "rounded",
        focusable = false,
        source    = "if_many",
        scope     = "cursor",
    },
})

-- Rounded borders for hover / signature help ----------------------------------
local orig_floating_preview = vim.lsp.util.open_floating_preview
---@diagnostic disable-next-line: duplicate-set-field
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts        = opts or {}
    opts.border = opts.border or "rounded"
    return orig_floating_preview(contents, syntax, opts, ...)
end

-- LSP keymaps (set on attach) -------------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
    callback = function(ev)
        local map  = vim.keymap.set
        local opts = { buffer = ev.buf, silent = true }

        map("n", "K",           vim.lsp.buf.hover,         vim.tbl_extend("force", opts, { desc = "Hover documentation" }))
        map("n", "<leader>lk",  vim.lsp.buf.signature_help,vim.tbl_extend("force", opts, { desc = "(k) Signature help" }))
        map("n", "<leader>lr",  vim.lsp.buf.rename,        vim.tbl_extend("force", opts, { desc = "(r)ename symbol" }))
        map("n", "<leader>la",  vim.lsp.buf.code_action,   vim.tbl_extend("force", opts, { desc = "Code (a)ctions" }))
        map("n", "<leader>gd",  vim.lsp.buf.definition,    vim.tbl_extend("force", opts, { desc = "Goto (d)efinition" }))
        map("n", "<leader>gr",  vim.lsp.buf.references,    vim.tbl_extend("force", opts, { desc = "Goto (r)eferences" }))
    end,
})

-- Server configurations -------------------------------------------------------
vim.lsp.config('lua_ls', {
    capabilities = capabilities,
    cmd          = { "lua-language-server" },
    filetypes    = { "lua" },
    root_markers = {
        ".luarc.json", ".luarc.jsonc", ".luacheckrc",
        ".stylua.toml", "stylua.toml",
        "selene.toml", "selene.yml",
        ".git",
    },
    settings = {
        Lua = {
            runtime     = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace   = { checkThirdParty = false },
            format = {
                enable        = true,
                defaultConfig = { indent_style = "space", indent_size = "4" },
            },
            telemetry  = { enable = false },
            completion = { callSnippet = "Replace" },
        },
    },
})

vim.lsp.config('pyright', {
    capabilities = capabilities,
    cmd          = { "pyright-langserver", "--stdio" },
    filetypes    = { "python" },
    root_markers = {
        "pyproject.toml", "setup.py", "setup.cfg",
        "requirements.txt", "Pipfile", "pyrightconfig.json",
        ".git",
    },
})

vim.lsp.config('bashls', {
    capabilities = capabilities,
    cmd          = { "bash-language-server", "start" },
    filetypes    = { "sh", "zsh" },
    root_markers = { ".git" },
})

vim.lsp.config('yamlls', {
    capabilities = capabilities,
    cmd          = { "yaml-language-server", "--stdio" },
    filetypes    = { "yaml", "yml" },
    root_markers = { ".git" },
    settings = {
        yaml = {
            hover    = true,
            format   = { enable = true, singleQuote = true },
            validate = true,
            customTags = {
                "!fn",    "!And",   "!If",          "!Not",
                "!Equals","!Or",    "!Base64",       "!Cidr",
                "!Ref",   "!ImportValue",
                "!Sub sequence",    "!Sub scalar",
                "!GetAtt","!GetAZs",
                "!Join sequence",   "!Equals sequence",
                "!FindInMap sequence", "!Select sequence",
                "!Split sequence",
            },
        },
    },
})

vim.lsp.config('marksman', {
    capabilities = capabilities,
    cmd          = { "marksman", "server" },
    filetypes    = { "markdown" },
    root_markers = { ".marksman.toml", ".git" },
})

-- Enable servers --------------------------------------------------------------
vim.lsp.enable({
    "lua_ls",
    "pyright",
    "bashls",
    "yamlls",
    "marksman",
})
