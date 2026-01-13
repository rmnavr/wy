
    (require wy.utils.fptk_local.core.from_hyrule [
        of                  #_ "[GROUP] Typing: Base            | | example: (of List int) which is equiv to py-code: List[int]"
        comment             #_ "[GROUP] Misc                    | |"
        ncut                #_ "[GROUP] Getters: idxs and keys  | |"
        case                #_ "[GROUP] FP: threading           | |"
        unless              #_ "[GROUP] FP: threading           | |"
        lif                 #_ "[GROUP] FP: threading           | |"
        branch              #_ "[GROUP] FP: threading           | |"
        ->                  #_ "[GROUP] FP: Composition         | |"
        ->>                 #_ "[GROUP] FP: Composition         | |"
        as->                #_ "[GROUP] FP: Composition         | |"
        doto                #_ "[GROUP] FP: Composition         | | mutating"
        do_n                #_ "[GROUP] FP: n-applicators       | (do_n   n #* body) -> None | expands to ~ (do body body body ...)"
        list_n              #_ "[GROUP] FP: n-applicators       | (list_n n #* body) -> List |"
    ])

    (require wy.utils.fptk_local.core.macros [
        def::               #_ "[GROUP] Typing: Base            | | example: (f:: int -> int => (of Tuple int str)) will produce: Callable[[int, int], Tuple[int,str]]"
        f::                 #_ "[GROUP] Typing: Base            | | define func with Haskell-style signature; example: (def:: int -> int => float fdivide [x y] (/ x y))"
        fm                  #_ "[GROUP] FP: threading           | (fm (* it 3)) | anonymous function that accepts args in form of 'it' or '%1', '%2', ... '%9'"
        f>                  #_ "[GROUP] FP: threading           | (f> (* it 3) 4) | anonymous function with fm syntax, immediately applicates args"
        mapm                #_ "[GROUP] FP: threading           | | same as map, but expects fm-syntax for func"
        lmapm               #_ "[GROUP] FP: threading           | | same as lmap, but expects fm-syntax for func"
        filterm             #_ "[GROUP] APL: filtering          | (filterm f xs)  | same as filter, but expects fm-syntax for func"
        lfilterm            #_ "[GROUP] APL: filtering          | (lfilterm f xs) | list version of lfilterm"
        =>                  #_ "[GROUP] FP: Composition         | | unification of dot-macro and ->"
        =>>                 #_ "[GROUP] FP: Composition         | | unification of dot-macro and ->>"
        p:                  #_ "[GROUP] FP: Composition         | | aplicator, pipe of partials"
        pluckm              #_ "[GROUP] Getters: keys and attrs | (pluckm n xs) (pluckm key ys) (pluckm .attr zs) | accepts fptk-style .arg syntax"
        lpluckm             #_ "[GROUP] Getters: keys and attrs | | list version of pluckm"
        getattrm            #_ "[GROUP] Getters: keys and attrs | (getattrm Object 'attr') (getattrm Object .attr) | accepts fptk-style .attr syntax"
        timing              #_ "[GROUP] Benchmarking            | (timing expr1 expr2 ...) -> #(float, Any) | returns time (in seconds) and result of execution of (fn [] expr1 expr2 ...)"
        assertm             #_ "[GROUP] Testing                 | (assertm op arg1 arg2) | tests if (op arg1 arg2), for example (= 1 1)"
        gives_error_typeQ   #_ "[GROUP] Testing                 | | example: (assertm gives_error_typeQ (get [1] 2) IndexError)"
     ])

     ; lns macros are defined in macros.hy, yes, but not imported into core


