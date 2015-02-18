
" Returns 1 when a cabal file exists in the current directory, and 0 otherwise.
function! CabalFileExists()

    return len(glob('*.cabal')) > 0

endfunction

