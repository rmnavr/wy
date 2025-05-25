
; how to indent ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    \atr — DOES introduce new indent level

    (fn atr         +1
        \atr            ; ~
        \atr            ; ~
        (fn atr     +1  ; 
        )\atr       -1  ; CLOSES
        \atr            ; ~
    )\atr           -1  ; CLOSES
    \atr

    (fn atr
        (fn atr
        )\atr           ; -> CLOSES block-indent
        \atr            
        (fn atr         ; -> RESTARTS block-indent
        \atr            
    ))(fn atr
    )(fn atr

    (fn atr         +1
        \atr        ; DOES introduce new indent level
        (fn atr     +1
        )\atr       -1
        \atr
    )\atr           -1

    (fn atr
        (fn atr
            \atr 
            \atr 
        )\atr 
        \atr

    (fn atr
        (fn atr
        )(fn atr
            \atr
            (fn atr
        )\atr
        \atr
        )(fn






                            i action    accum   kind
                            - ------    -----   ----
    (fn atr                 0 
   *)
    (fn atr                 0 +C        C       OPENER
    :   (fn atr             1 +C        CC      OPENER
    :   :   \at             2           CC      CONTINUATOR
    :   :   (fn atr         2 +C        CCC     OPENER
    :   :   :   (fn atr     3 +C        CCCC    OPENER
    :   :   :   :   \at     4           CCCC    CONTINUATOR
    :   :   :   :   :   \at 5           CCCC    CONTINUATOR
    :   :   :   :   \at     4           CCCC    CONTINUATOR
    :   :   :   :   (fn atr 4 +C        CCCCC   OPENER
    :   :   :  *)  *)                   
    :   :   :   (fn atr     4 -CC +C    CCCC    OPENER
    :  *)  *)  *)
    :   (fn atr             1 -CCC +C   CC      OPENER
   *)  *)                   
    \EL                     0 -CC       _       EOBLOCK

    0   1   2   3   4

    (fn atr                 0 C
    :   (fn atr             1 CC
    :   :   (fn atr         2 CCC
    :   :   :   (fn atr     3 CCCC
    :   :   :   :   \at     4 CCCC
    :   :   :   :   \at     4 CCCC
    :   :   :  *)
    :   :   :   \at         3 CCC
    :   :   :   \at         3 CCC
    :  *)  *)               
    :   \at                 1 C
   *)   
    \EL                     0 C


; _____________________________________________________________________________/ }}}1

    ! do not confuse:
      - brackets to close
      - indent_levels to close

    ! work correctly on comments and strings!
    ! no-ident works bad -> solve the issue!

    stages:
    1 hysky code
    2 split «: func» to 2 lines // currently: will parse "strings" non ideally but will still work
      add «✠✠✠✠» at indents
    3 parse to   ["✠✠✠✠" "\\" "x"]
    4 process to ["✠✠✠✠" "))" "(" "x"]
      


;   0 1 2
    : partial plus 3 
      : lns 1 2
        \     (Each) (collect)

    + tabs vs spaces
    + only one-line brackets are allowed currently
    + work on empty code
    + hy.vim: #_ "highlight bracket opener ()"
    + insert at (list pos)
    + string with comment only?

    line starters:
        :
        #:
        C
        #C
        L
        ; later: add ~ ~@ ` '

    inline openers:
        
        ::



    ====================================================================================================

    partial : pupos :: riba
        print

    (partial (pupos) (riba)
        print)

    possible line starts:
        \x
        partial plus 3
        : partial 
        L partial
        C partial


    : : L partial plus 3

    partial plus
    \3

partial plus

    : partial plus 3

    : : partial plus 3

    : : : partial plus 3


    *
      : partial plus 3
      \ 4
      \ 4
    \ 5

;   0 1 2
    : partial plus 3 
      : lns 1 2
        \     (Each) (collect)

    lmap 
        pflip getattr "x"
;   0   1 2
        L [1 2 3]
          [3 4 5]
        starmap bubr
                riba
;   0   1       2
        lmap
           L [1 2 3]
             [7 8 9]
;   0   1  2 3
          

    (   
        (partial plus 3) 
        (   (. lens [1]
                   \[2] (Each)
                    riba
            )
        )
    )


        
    (fn   
        (fn attr)
        (fn 
            (fn attr 
            \ attr
            )
        )
    )


    (
        (partial plus 3)
        \3
    )
    \EL

