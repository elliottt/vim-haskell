
" Returns 1 when a cabal file exists in the current directory, and 0 otherwise.
function! haskell#CabalFileExists() abort

    return len(glob('*.cabal')) > 0

endfunction

" Given a module name, attempt to find the file it corresponds to
function! haskell#FindImport(modname) abort

    let l:fname=substitute(a:modname,'\.','/','g').'.hs'
    if filereadable(l:fname)
        return l:fname
    endif

    " Try to find it relative to the current directory
    let l:globs=glob('*/' . l:fname, 0, 1)
    if len(l:globs) > 0
        return get(l:globs, 0)
    else
        return l:fname
    endif
endfunction
