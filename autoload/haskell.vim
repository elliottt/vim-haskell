
" Returns 1 when a cabal file exists in the current directory, and 0 otherwise.
function! haskell#CabalFileExists() abort

    return len(glob('*.cabal')) > 0

endfunction

