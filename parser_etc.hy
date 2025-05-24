
; lens ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv x (list_n 3 (list_n 3 [2 1 3])))

    setv x : list_n 3 : list_n 3 [2 1 3]

    ((lns (Each) 1 (mth> .sort)) x)

    : lns (Each) 1 : mth> .sort
    \ x

    ((. lens (Each) [1] [2]) 1)
    : 
      . lens : Each
             L\1
              \[2]
      1

    : ; seen as ( 
      lns : Each
          \ 1
            mth> .sort
    \ x

    l> data : Each
             \1 
              mth> .sort 3

    lmap 
        p> : nth 1
             sqrt
             neg
             str
        [[0 1]
        \[1 2]
        \[3 4]]

; _____________________________________________________________________________/ }}}1

    ; «:» is opening bracket, NOT function execution per se
    ; «\» is «no bracket»
    ; «L» is «:» 
    ; rule (not for compiler, but for programmer): avoid using nested (), but 1 level is very ok 
    ; Не надо делать новый язык! Это Hy, просто без скобочек блеать!!!
    \\ keep ident, see as open bracket 

    ; «:» is one-shot ()
    ; «L» works as indent at exact place

; class ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    defclass L dataclass
        Point L
        \\   #^ int x
        setv #^ int y 10
        ;
        defn getXY #^ (of Tuple int int)
          L self
            scale
          L * y scale
            * x scale

; _____________________________________________________________________________/ }}}1
; function ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    defn L decorator
        #^ TimeUnit
        execution_time 
        L #^ Callable f
        \ #^ int      L n 1
        \ #^ int      L tUnit "ns"
        setv count hy.I.time.perf_counter
        setv n : int n
        do_n n : f
        setv seconds : - t1 t0
        case tUnit UNIT.S
                   do : setv time_n seconds
                        setv unit_str " s"
                  \UNIT.MS
                   do
                      setv time_n
                           -> seconds : div 3
                                        mul 1000
                      setv time_n : / (mul 1000 seconds) 3
                      setv unit_str "ms"
        sconcat line_01 "\n"
              \ line_02_time1 " as " line_02_n " // " line_02_timeN

; _____________________________________________________________________________/ }}}1
; smth ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    do : setv xs L_ [0 1] [2 3] [3 4]
    / 
      . lens (Each) [3]
      3

         setv ds L : dict :x 0 :y 1
                     dict :x 2 :y 3
                 
         setv i 1
         setv i 0
         defclass [dataclass] Point [] : #^ int x
                                         #^ int y
         setv ps L : Point 0 1
                     Point 2 3
        \"vrbls initialized"

    (do (setv xs [[0 1] [2 3]])
        (setv ds [(dict :x 0 :y 1) (dict :x 2 :y 3)])
        (setv i  0)
        (setv i  0)
        (defclass [dataclass] Point [] (#^ int x) (#^ int y))
        (setv ps [(Point 0 1) (Point 2 3)])
        "vrbls initialized")

; _____________________________________________________________________________/ }}}1
; smth ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    lmap 
        p> : nth 1
             sqrt
             neg
             str
        L L\0 1
        \ L\1 2
        \ L\3 4


    (pargs.append `(partial ~@(cut &arg 0 None)))

    pargs.append
        ` partial
          ~@ cut &arg 0 None

    pargs.append
        ` partial 
            fn [args mth] : mth #** args
            L ~@: get (_extractDottedCall arg) "args"

; _____________________________________________________________________________/ }}}1

    ((partial plus 3) 4)

        : partial plus 3
        \ 4

        * 
          : (partial plus 3) 4
          \ 4
        \ 5

        ( 
          ( (partial plus 3) 4
          \ 4)
        \ 5)

        ( 
          ( ( partial plus 3)
            \ 4)
        \ 5)

