lvim.format_on_save = true

vim.opt.relativenumber = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.whichwrap = ""

local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
	{ exe = "nixpkgs-fmt", filetypes = { "nix" } },
	{ exe = "black", filetypes = { "python" } },
	{
		name = "prettier",
		filetypes = {
			"html",
			"json",
			"js",
			"typescript",
			"yaml"
		},
	},
}
