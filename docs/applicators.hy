
    $
    :$
    $$

    ; $: 1) +1 nested level
    ;    2) close inline markers

        ; visual underlining of argument lol:
        nth 1 $ xs
          \here

        ; closes inline markers:
        lmap : p> (plus 3) str $ 3
          \here
        (lmap (p> (plus 3) str) 3)

        ; applicate function: 
        : p> : plus 3 :: str $ 3
         \here
        ((p> (plus 3) str) 3)

    ; $$:

        setv sumArgs : p> (reduce plus 2) (flip div 2) $$ data
                    \split
        (setv sumArgs ((p> (reduce plus 2) (flip div 2)) data))

        print : setx sumArgs : p> (reduce plus 2) (flip div 2) $$ data
             \here?         \here?


        : setx sumArgs : p> (reduce plus 2) (flip div 2) $$ data


