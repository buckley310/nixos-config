local sections = require('lualine').get_config().sections
sections.lualine_x = {
	function()
		local bufnr = vim.api.nvim_get_current_buf()
		local clients = vim.lsp.buf_get_clients(bufnr)
		if next(clients) == nil then
			return ''
		end
		local c = {}
		for _, client in pairs(clients) do
			table.insert(c, client.name)
		end
		return '\u{f013} ' .. table.concat(c, ',')
	end,
	'filetype',
}

require('lualine').setup({
	options = {
		disabled_filetypes = { 'NvimTree' },
	},
	sections = sections,
})

vim.cmd("set noshowmode")
