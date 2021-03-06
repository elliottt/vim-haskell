
" Returns 1 when a cabal file exists in the current directory, and 0 otherwise.
function! haskell#CabalFileExists() abort

    return len(glob('*.cabal')) > 0

endfunction

" Returns 1 when a stack.yaml file exists in the current directory, and 0
" otherwise.
function! haskell#StackYamlFileExists() abort

    return len(findfile('stack.yaml', '.;', -1)) > 0

endfunction

" Returns 1 when a cabal.project or cabal.project.local file is discovered in
" this directory, or any above.
function! haskell#CabalProjectFileExists() abort

    if len(findfile('cabal.project', '.;', -1)) > 0
        return 1
    endif

    if len(findfile('cabal.project.local', '.;', -1)) > 0
        return 1
    endif

    return 0

endfunction

" Given a module name, attempt to find the file it corresponds to
function! haskell#FindImport(modname, ix) abort

    let l:fname=substitute(a:modname,'\.','/','g')
    let l:dirs=split(&path, ',')
    let l:suff=split(&suffixesadd, ',')
    let l:off=a:ix

    for dir in split(&path, ',')
        for suffix in split(&suffixesadd, ',')

            let l:matches=globpath(l:dir, l:fname . l:suffix, 0, 1)
            if len(l:matches) > l:off
                execute 'edit ' . get(l:matches, l:off)
                return
            endif

            let l:off -= len(l:matches)

        endfor
    endfor

    echohl ErrorMsg
    echom 'Unable to find module: ' . a:modname
    echohl None

endfunction

" Run fast tags for the given file, updating the nearest tags file found.
function! haskell#UpdateFastTags(file) abort
    let l:tagfile=findfile('tags', '.;')
    if l:tagfile != ""
        exe "silent !fast-tags -o " . shellescape(l:tagfile) . " ./" . shellescape(a:file)
    endif
endfunction

" Setup the include and includeexpr options to parse import declarations
function! haskell#FollowImports() abort

    setlocal include=\\s*import\\s\\+\\(qualified\\s\\+\\)\\?\\zs[^\ \\t]\\+\\ze
    setlocal suffixes+=.hi,.o
    setlocal suffixesadd=.hs,.hsc,.y,.x
    setlocal path=.,*

endfunction

" Setup insert-mode macros for unicode
function! haskell#UnicodeMacros() abort

    inoremap -> →
    inoremap <- ←
    inoremap :: ∷
    inoremap forall ∀
    inoremap => ⇒

    digraph fa 8704
    digraph ZZ 8484

endfunction

command! -count=0 HaskGf call haskell#FindImport(expand('<cfile>'), "<count>")
nnoremap <silent> <Plug>(haskell-gf) :HaskGf<Return>
