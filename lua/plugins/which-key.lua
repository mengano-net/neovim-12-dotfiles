local gh = function(x) return 'https://github.com/' .. x end

vim.pack.add({ gh('folke/which-key.nvim') })

local ok, wk = pcall(require, 'which-key')
if not ok then
    vim.notify("which-key not yet loaded — restart Nvim to complete setup", vim.log.levels.WARN)
    return
end

wk.setup({ preset = "modern" })

wk.add({
    mode = { "n", "v" },

    -- Groups ----------------------------------------------------------------
    { "<leader>b", group = "( b )uffers",
        expand = function() return require("which-key.extras").expand.buf() end },
    { "<leader>e", group = "( e )xplore" },  -- ee: open, er: recent, eR: refresh (netrw), eh: hidden
    { "<leader>E", group = "( E )dit" },
    { "<leader>f", group = "( f )ind" },       -- telescope (coming soon)
    { "<leader>g", group = "( g )oto" },
    { "<leader>G", group = "( G )it" },        -- git plugin (coming soon)
    { "<leader>h", group = "( h )unks — git" },-- git hunks (coming soon)
    { "<leader>l", group = "( l )sp" },
    { "<leader>t", group = "( t )erminal" },
    { "<leader>v", group = "( v )im" },

    -- Standalone keymaps ----------------------------------------------------
    { "<leader>?", function() wk.show({ global = false }) end,
        desc = "Buffer local keymaps" },
    { "<leader>w", "<cmd>w!<cr>",  desc = "( w )rite buffer" },
    { "<leader>x", "<cmd>bd!<cr>", desc = "De( x )troy buffer" },

    -- LSP (set on LspAttach; registered here for which-key labels) ----------
    { "<leader>lk", desc = "Signature help" },
    { "<leader>lr", desc = "Rename symbol" },
    { "<leader>la", desc = "Code actions" },
    { "<leader>lf", desc = "Format buffer or range" },
    { "<leader>gd", desc = "Goto definition" },
    { "<leader>gr", desc = "Goto references" },

    -- Diagnostics (native) --------------------------------------------------
    { "<leader>gj", "<cmd>lua vim.diagnostic.jump({count=1,  float=true})<cr>", desc = "Diagnostic ( j )ump down" },
    { "<leader>gk", "<cmd>lua vim.diagnostic.jump({count=-1, float=true})<cr>", desc = "Diagnostic ( k )ump up" },
    { "<leader>gf", function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_config(win).relative ~= "" then
                vim.api.nvim_set_current_win(win)
                return
            end
        end
        vim.diagnostic.open_float()
        vim.schedule(function()
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_config(win).relative ~= "" then
                    vim.api.nvim_set_current_win(win)
                    return
                end
            end
        end)
    end, desc = "( f )ocus diagnostic float" },
})
