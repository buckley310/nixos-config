"misc
set mouse=
set encoding=utf-8
set number relativenumber
set list listchars=tab:\|\ ,trail:-
set nowrap
set scrolloff=9
set tabstop=4
set shiftwidth=4

set termguicolors
colorscheme codedark

nnoremap <space>H :call CocActionAsync('doHover')<cr>


"configure plugins
let g:gitgutter_sign_removed = "\uE0B8"
let g:gitgutter_sign_removed_first_line = "\uE0BC"
let g:gitgutter_sign_modified_removed = '~~'
set updatetime=500

let g:startify_custom_header = "''"
let g:startify_custom_indices = map(range(1,100), 'string(v:val)')

let NERDTreeMinimalUI=1
let g:NERDTreeExtensionHighlightColor = {}
let g:NERDTreeExtensionHighlightColor['nix'] = "689FB6"
let g:NERDTreeExtensionHighlightColor['tf'] = "834F79"

let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols = {}
let g:WebDevIconsUnicodeDecorateFileNodesExtensionSymbols['tf'] = "\uE69A"


"auto formatting
let g:formatters_python = ['black']

let g:formatdef_nixpkgsfmt="'nixpkgs-fmt'"
let g:formatters_nix = ['nixpkgsfmt']

let g:formatdef_prettier="'prettier --stdin-filepath ' . expand('%:p')"
let g:formatters_js = ['prettier']
let g:formatters_json = ['prettier']
let g:formatters_ts = ['prettier']
let g:formatters_yaml = ['prettier']

autocmd BufWritePre * :Autoformat


"menus
nnoremap <silent> <space>e :NERDTreeFocus<CR>:vertical resize 30<CR>
nnoremap <silent> <space>o :Startify<CR>


"buffers
nnoremap <silent> <space>w :q<CR>
nnoremap <silent> <space>q :bd<CR>
nnoremap <silent> <space>d :bnext<CR>
nnoremap <silent> <space>a :bprevious<CR>


"window shortcuts
nnoremap <space>h <C-W>h
nnoremap <space>j <C-W>j
nnoremap <space>k <C-W>k
nnoremap <space>l <C-W>l
nnoremap <space>v <C-W>v
nnoremap <space>s <C-W>s
