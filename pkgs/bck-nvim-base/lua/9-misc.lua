vim.cmd("set mouse=")
vim.cmd("set number relativenumber")
vim.cmd("set nowrap")
vim.cmd("set scrolloff=9")
vim.cmd("set tabstop=4")
vim.cmd("set shiftwidth=4")
vim.cmd("set ignorecase smartcase")
vim.cmd("set clipboard=unnamedplus")

vim.keymap.set('n', '<space>ff', '<cmd>Telescope find_files<cr>')
vim.keymap.set('n', '<space>fr', '<cmd>Telescope oldfiles<cr>')
vim.keymap.set('n', '<space>fg', '<cmd>Telescope git_files<cr>')

vim.keymap.set('n', '>', '>>^')
vim.keymap.set('n', '<', '<<^')
vim.keymap.set('v', '<', '<gv^')
vim.keymap.set('v', '>', '>gv^')

vim.keymap.set('n', '<space>w', '<cmd>w<cr>')
vim.keymap.set('n', '<space>q', '<cmd>q<cr>')
vim.keymap.set('n', '<space>c', '<cmd>:bdelete<cr>')
vim.keymap.set('n', '<A-j>', '<cmd>bprevious<cr>')
vim.keymap.set('n', '<A-k>', '<cmd>bnext<cr>')

vim.keymap.set('n', "<C-Up>", "<cmd>resize -2<cr>")
vim.keymap.set('n', "<C-Down>", "<cmd>resize +2<cr>")
vim.keymap.set('n', "<C-Left>", "<cmd>vertical resize -2<cr>")
vim.keymap.set('n', "<C-Right>", "<cmd>vertical resize +2<cr>")

vim.api.nvim_create_autocmd('TextYankPost', {
	callback = function()
		vim.highlight.on_yank()
	end
})

local fname = os.getenv("HOME") .. "/.bck-nvim.lua"
local f = io.open(fname, "r")
if f ~= nil then
	io.close(f)
	vim.cmd('luafile ' .. fname)
end
