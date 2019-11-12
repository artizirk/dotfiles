" show some context lines up/down of the cursor
set scrolloff=3
set ignorecase
set cursorline
hi cursorline cterm=none term=none
autocmd WinEnter * setlocal cursorline
autocmd WinLeave * setlocal nocursorline
highlight CursorLine guibg=#303000 ctermbg=234
"highlight CursorLine guibg=#303000 ctermbg=lightgray

" configure reasonable swap file
" https://begriffs.com/posts/2019-07-19-history-use-vim.html?hn=3#backups-and-undo
runtime swap.vim

let g:deoplete#enable_at_startup = 1

" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %
