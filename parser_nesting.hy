

    partial : pupos :: riba
    (partial (pupos) (riba))

    possible line starts:
        \x
        partial plus 3
        : partial 
        L partial


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
        (   (. lens [1] [2] (Each)
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

    (fn atr                 0 +C        C
    :   (fn atr             1 +C        CC
    :   :   \at             2           CC
    :   :   (fn atr         2 +C        CCC
    :   :   :   (fn atr     3 +C        CCCC
    :   :   :   :   \at     4           CCCC
    :   :   :   :   :   \at 5           CCCC
    :   :   :   :   \at     4           CCCC
    :   :   :   :   (fn atr 4 +C        CCCCC
    :   :   :  *)  *)                   
    :   :   :   (fn atr     4 -CC +C    CCCC
    :  *)  *)  *)
    :   (fn atr             1 -CCC +C   CC
   *)  *)                   
    \EL                     0 -CC       _

    0   1   2   3   4

    (fn atr                 0 C
    :   (fn atr             1 CC
    :   :   (fn atr         2 CCC
    :   :   :   (fn atr     3 CCCC
    :   :   :   :   \at     4 CCCC
    :   :   :  *)
    :   :   :   \at         3 CCC
    :  *)  *)               
    :   \at                 1 C
   *)   
    \EL                     0 C

