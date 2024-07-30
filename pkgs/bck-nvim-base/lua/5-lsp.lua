local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local noFormat = function(client, _)
	client.server_capabilities.documentFormattingProvider = false
end

----------------------------------------------------------------
lspconfig.lua_ls.setup({
	capabilities = capabilities,
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" }
			}
		}
	}
})

----------------------------------------------------------------
lspconfig.pyright.setup({
	capabilities = capabilities,
})

----------------------------------------------------------------
lspconfig.tsserver.setup({
	capabilities = capabilities,
	on_attach = noFormat,
})

----------------------------------------------------------------
lspconfig.html.setup({
	capabilities = capabilities,
	on_attach = noFormat,
})

----------------------------------------------------------------
lspconfig.cssls.setup({
	capabilities = capabilities,
	on_attach = noFormat,
})

----------------------------------------------------------------
lspconfig.nil_ls.setup({
	capabilities = capabilities,
	cmd = { "nil" },
	settings = {
		['nil'] = {
			formatting = {
				command = { "nixpkgs-fmt" },
			},
		},
	},
})

----------------------------------------------------------------
lspconfig.jsonls.setup({
	capabilities = capabilities,
	on_attach = noFormat,
})

----------------------------------------------------------------
lspconfig.yamlls.setup({
	capabilities = capabilities,
	settings = {
		yaml = {
			customTags = {
				-- https://github.com/aws-cloudformation/cfn-lint-visual-studio-code/blob/3ff0b8cc1bbfc34448c865b54deff8c7d030beba/server/src/cfnSettings.ts
				"!And sequence",
				"!If sequence",
				"!Not sequence",
				"!Equals sequence",
				"!Or sequence",
				"!FindInMap sequence",
				"!Base64 scalar",
				"!Join sequence",
				"!Cidr sequence",
				"!Ref scalar",
				"!Sub scalar",
				"!Sub sequence",
				"!GetAtt scalar",
				"!GetAtt sequence",
				"!GetAZs mapping",
				"!GetAZs scalar",
				"!ImportValue mapping",
				"!ImportValue scalar",
				"!Select sequence",
				"!Split sequence",
			},
		},
	},
	on_attach = function(client, _)
		client.server_capabilities.documentFormattingProvider = true
	end,
})

----------------------------------------------------------------
----------------------------------------------------------------
----------------------------------------------------------------
local efmprettier = {
	{
		formatStdin = true,
		formatCommand = "prettier --stdin-filepath ${INPUT}",
	}
}
lspconfig.efm.setup({
	filetypes = {
		"css",
		"html",
		"javascript",
		"json",
		"typescript",
		"python",
	},
	init_options = {
		documentFormatting = true
	},
	settings = {
		languages = {
			css = efmprettier,
			html = efmprettier,
			javascript = efmprettier,
			json = efmprettier,
			typescript = efmprettier,
			python = {
				{
					formatStdin = true,
					formatCommand = "black --quiet -",
				},
			},
		},
	},
})

----------------------------------------------------------------
vim.api.nvim_create_autocmd("BufWritePre", {
	callback = function(e)
		for _, client in pairs(vim.lsp.buf_get_clients(e.buf)) do
			if client.supports_method("textDocument/formatting") then
				return vim.lsp.buf.format()
			end
		end
	end
})
