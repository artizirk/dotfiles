" show some context lines up/down of the cursor
set scrolloff=3
set ignorecase

" Python formating
autocmd FileType python set tabstop=4 shiftwidth=4 softtabstop=4 expandtab

set cursorline
hi cursorline cterm=none term=none
autocmd WinEnter * setlocal cursorline
autocmd WinLeave * setlocal nocursorline
highlight CursorLine guibg=#303000 ctermbg=234
"highlight CursorLine guibg=#303000 ctermbg=lightgray

" configure reasonable swap file
" https://begriffs.com/posts/2019-07-19-history-use-vim.html?hn=3#backups-and-undo
runtime swap.vim

" enable <C-X><C-O> omni completion
set omnifunc=syntaxcomplete#Complete
" more advanced deoplete completion
let g:deoplete#enable_at_startup = 1

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

" F5 to save and make
:map <f5> :w \| :make<CR>

" show special chars
set list
set listchars=tab:\ \ ,trail:·,nbsp:⎵
" TODO: toggle between listchars to show tabs and new lines

" spellcheck
set spelllang=en
" enable via set spell
