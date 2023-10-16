vim.opt.mouse = ""
vim.opt.relativenumber = true
vim.opt.whichwrap = ""

vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pylyzer" })

lvim.format_on_save = true

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
