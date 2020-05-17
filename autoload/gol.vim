function! s:neighbours(x, y)
    let ns = []
    for dx in range(-1, 1)
        for dy in range(-1, 1)
            if dx != 0 || dy != 0
                let ns += [[a:x + dx, a:y + dy]]
            endif
        endfor
    endfor
    return ns
endfunction

function! s:alive_neighbours(cells, x, y)
  let ns = 0
  for [nx, ny] in s:neighbours(a:x, a:y)
      let ns += get(a:cells, join([nx, ny]), 0)
  endfor
  return ns
endfunction

function! s:next(cells)
    let next = {}
    for k in keys(a:cells)
        let [x,y] = split(k)

        let ns = s:alive_neighbours(a:cells, x, y)
        if ns == 2 || ns == 3
           let next[k] = 1
        endif

        for [x, y] in s:neighbours(x,y)
            let k = join([x, y])
            if !get(next, k, 0) && !get(a:cells, k, 0)
                let ns = s:alive_neighbours(a:cells, x, y)
                if ns == 3
                    let next[k] = 1
                endif
            endif
        endfor
    endfor
    return next
endfunction

function! s:trim_right(str)
    return substitute(a:str, '\s*$', '', '')
endfunction

function! s:parse(width, height, top)
    let lines = getline(a:top, a:top + a:height)

    let cells = {}
    for y in range(a:height)
        let line = get(lines, y, '')
        for x in range(a:width)
            if 32 < strgetchar(line, x)
                let cells[join([x, y])] = 1
            endif
        endfor
    endfor

    return cells
endfunction

function! s:render(width, height, top, cells)
    for y in range(a:height)
        let row = ''
        for x in range(a:width)
            if get(a:cells, join([x,y]), 0)
                let row .= '0'
            else
                let row .= ' '
            endif
        endfor
        call setline(a:top + y, s:trim_right(row))
    endfor
    redraw
endfunction

function! gol#step()
    let width = winwidth(0)
    let height = winheight(0)
    let top = line('w0')

    let cells = s:parse(width, height, top)
    let cells = s:next(cells)
    call s:render(width, height, top, cells)
endfunction

function! gol#open(...)
    let width = winwidth(0)
    let height = winheight(0)
    let cells = s:parse(width, height, line('w0'))

    enew!
    setlocal buftype=nofile
    setlocal nobuflisted
    setlocal filetype=gol

    call s:render(width, height, 1, cells)
endfunction
