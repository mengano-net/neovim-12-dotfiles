local gh = function(x) return 'https://github.com/' .. x end

vim.pack.add({ gh('lewis6991/gitsigns.nvim') })

local ok, gitsigns = pcall(require, 'gitsigns')
if not ok then
    vim.notify("gitsigns.nvim not yet loaded — restart Nvim to complete setup", vim.log.levels.WARN)
    return
end

gitsigns.setup({
    signs = {
        add    = { text = "▎" },
        change = { text = "▎" },
    },
    attach_to_untracked = true,

    on_attach = function(bufnr)
        local gs   = require("gitsigns")
        local opts = { buffer = bufnr, silent = true }
        local map  = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", opts, { desc = desc }))
        end

        -- Hunk navigation
        map("n", "<leader>hj", gs.next_hunk,         "( j )ext hunk")
        map("n", "<leader>hk", gs.prev_hunk,         "( k )revious hunk")
        map("n", "<leader>hp", gs.preview_hunk,      "( p )review hunk")
        map("n", "<leader>hr", gs.reset_hunk,        "( r )eset hunk")
        map("n", "<leader>hs", gs.stage_hunk,        "( s )tage hunk")
        map("n", "<leader>hu", gs.undo_stage_hunk,   "( u )n-stage hunk")

        -- Buffer-level operations
        map("n", "<leader>GB", function() gs.blame_line({ full = false }) end, "( B )lame line")
        map("n", "<leader>GS", gs.stage_buffer,  "( S )tage buffer")
        map("n", "<leader>GR", gs.reset_buffer,  "( R )eset buffer")
    end,

    -- NOTE: statusline diff counts (added/modified/removed) will be wired into
    -- lua/config/statusline.lua once gitsigns is confirmed working. Use:
    --   require("gitsigns").get_hunks(bufnr)  -- returns hunk list
    --   vim.b.gitsigns_status_dict            -- {added=N, changed=N, removed=N}
})
