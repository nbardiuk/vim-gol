if exists('g:loaded_gol')
  finish
endif
let g:loaded_gol = 1

command! -nargs=? -complete=dir Gol call gol#open(<q-args>)
