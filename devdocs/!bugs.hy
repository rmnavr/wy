
    defn #^ (of Tuple int float float float float float float float)
       \memf_line_to_numbers
        L #^ (of Tuple str str str str str str str str) line
        ;
        setv [n f xf xs yf ys zf zs] line
        return
            #: 
                int n    :: float f
                float xf :: float xs
                float yf :: float ys
                float zf :: float zs


    ; if there is space after ":" will give incorrect result
    : 
      fn [x] (pow x 2)
      3
