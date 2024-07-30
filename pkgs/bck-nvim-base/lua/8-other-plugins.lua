require('nvim-treesitter.configs').setup({
	highlight = {
		enable = true,
	},
})

----------------------------------------------------------------
require('project_nvim').setup({
	detection_methods = { "pattern" },
	patterns = { ".git", "flake.nix", "package.json" },
})

----------------------------------------------------------------
require('Comment').setup({})

----------------------------------------------------------------
require("bufferline").setup({
	options = {
		separator_style = "slant"
	}
})

----------------------------------------------------------------
vim.cmd("highlight NonText guifg=#404040")
require("ibl").setup({
	scope = { enabled = false },
	indent = { char = "\u{258f}" },
})

----------------------------------------------------------------
require('gitsigns').setup({})
vim.cmd("set signcolumn=yes") -- signcolumn=number ?
vim.cmd("highlight GitSignsAdd    ctermfg=2 guifg=#009900")
vim.cmd("highlight GitSignsChange ctermfg=3 guifg=#bbbb00")
vim.cmd("highlight GitSignsDelete ctermfg=1 guifg=#ff2222")
vim.keymap.set('n', '<space>gl', '<cmd>lua require("gitsigns").blame_line()<cr>')
vim.keymap.set('n', '<space>gp', '<cmd>lua require("gitsigns").preview_hunk()<cr>')
vim.keymap.set('n', '<space>gr', '<cmd>lua require("gitsigns").reset_hunk()<cr>')
vim.keymap.set('n', '<space>gs', '<cmd>lua require("gitsigns").stage_hunk()<cr>')
vim.keymap.set('n', '<space>gu', '<cmd>lua require("gitsigns").reset_buffer_index()<cr>')
