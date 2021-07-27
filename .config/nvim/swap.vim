" Protect changes between writes. Default values of
" updatecount (200 keystrokes) and updatetime
" (4 seconds) are fine
set swapfile
set directory^=~/.config/nvim/swap//

" protect against crash-during-write
set writebackup
" but do not persist backup after successful write
set nobackup
" use rename-and-write-new method whenever safe
set backupcopy=auto

" consolidate the writebackups -- not a big
" deal either way, since they usually get deleted
set backupdir^=~/.config/nvim/backup//

" persist the undo tree for each file
set undofile
set undodir^=~/.config/nvim/undo//
