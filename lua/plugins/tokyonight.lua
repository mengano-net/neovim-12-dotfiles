local gh = function(x) return 'https://github.com/' .. x end

vim.pack.add({ gh('folke/tokyonight.nvim') })

vim.cmd.colorscheme("tokyonight-night")
