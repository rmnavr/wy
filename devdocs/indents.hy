
; 1 ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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

    ))))

; _____________________________________________________________________________/ }}}1
; 2 ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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

