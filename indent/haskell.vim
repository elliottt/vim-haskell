

if exists('b:did_indent')
    finish
endif

let b:did_indent = 1

setlocal indentexpr=GetHaskellIndent(v:lnum)
setlocal indentkeys=!^F,o,O

function! GetBlockMarker(line)

  let l:i     = match(a:line, '$') - 1
  let l:lev   = { '{': 0, '(': 0, '[': 0 }
  let l:close = { '}': '{', ')': '(', ']': '[' }

  while l:i >= 0

      let l:char = a:line[l:i]

      " would this character open a block?
      if has_key(l:lev, l:char)

          " are there any closed blocks that this would have opened?
          if l:lev[l:char] > 0
              let l:lev[l:char] -= 1
          else
              return l:i
          endif

      " would this character close a block?
      elseif has_key(l:close, l:char)
          let l:lev[l:close[l:char]] += 1
      endif

      let l:i -= 1

  endwhile

  return 0

endfunction

function! GetHaskellIndent(lnum)
    " the line above the current line
    let l:line = getline(a:lnum - 1)

    " when the line is just whitespace, match to the same level.
    if l:line =~# '^\s*$'
        return match(l:line, '\S')
    endif


    " the indent level of the previous line
    let l:indent = indent(a:lnum - 1)


    " when the line ends in a do, indent by shiftWidth
    if l:line =~# '^\k\+.*=\s*\%(do\)\?$'
        let l:indent = match(l:line, '\S') + &shiftwidth

    elseif l:line =~# 'module.*($'
        let l:indent = match(l:line, '\S') + &shiftwidth

    " indent to the last open list bracket/open paren/open brace
    elseif l:line =~# '\(\[[^\]]*\|([^)]*\|{[^}]*\)$'
        let l:indent = GetBlockMarker(l:line)

    " when in a data or newtype declaration, indent to the '='
    elseif l:line =~# '^\(data\|newtype\)\>.*=.\+'
        let l:indent = match(l:line, '=')

    " when in a GADT, class, or instance, just indent by shiftWidth
    elseif l:line =~# '^data\>[^=]\+\|^class\>\|^instance\>'
        let l:indent = match(l:line, '\S') + &shiftwidth

    " indent case arms by shiftWidth
    elseif l:line =~# '\<case\>.*\<of\>'
        let l:indent = match(l:line, '\S') + &shiftwidth

    " indent else branches on their own line to the 'then' token
    elseif l:line =~# '\<if\>.*\<then\>.*\%(\<else\>\)\@!'
        let l:indent = match(l:line, '\<then\>')

    " indent the arms of an if by 3
    elseif l:line =~# '\<if\>'
        let l:indent = match(l:line, '\<if\>') + 3

    elseif l:line =~# '\<do$'
        let l:indent = match(l:line, '\S') + &shiftwidth

    elseif l:line =~# '->$'
        let l:indent = match(l:line, '\S') + &shiftwidth

    elseif l:line =~# '\<\%(do\|let\|where\|in\|then\|else\)$'
        let l:indent = indent(a:lnum - 1)

    elseif l:line =~# '\<do\>'
        let l:indent = match(l:line, '\<do\>') + 3

    elseif l:line =~# '\<let\>.*\s=$'
        let l:indent = match(l:line, '\<let\>') + 4 + &shiftwidth

    elseif l:line =~# '\<let\>'
        let l:indent = match(l:line, '\<let\>') + 4

    elseif l:line =~# '\<where\>'
        let l:indent = match(l:line, '\<where\>') + 6

    elseif l:line =~# '\s=$'
        let l:indent = indent(a:lnum - 1) + &shiftwidth

    endif


    if synIDattr(synIDtrans(synID(a:lnum - 1, l:indent, 1)), 'name')
                \ =~# '\%(Comment\|String\)$'
        return indent(a:lnum - 1)
    endif

    return l:indent
endfunction

