
    (import  _fptk_local *)
    (require _fptk_local *)

    (import wy [ convert_wy2hy :as w2h
                 print_wy2hy_steps])

; [F] testing machinery ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; used for removing indent upto and including «|» in strings like:
    ; "func
    ;       |  1.0  
    ;       |  -1.0"
    (def:: str => str
        wystrip [wy_code]
        (re_sub r"\n\s+\|" "\n" wy_code))

    (defmacro wy_str_test [a b] `(assertm eq (w2h (wystrip ~a)) (wystrip ~b)))

; _____________________________________________________________________________/ }}}1

; continuators ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv cont_wy "func
                  |    -1.0
                  |    \"string\"
                  |    f\"string\"
                  |    b\"string\"
                  |    r\"string\"
                  |    :keyword
                  |    (smth)
                  |    #(smth)
                  |    {smth}
                  |    #{smth}
                  |    [smth]
                  |    #^
                  |    #*
                  |    #**")

    (setv cont_hy "(func
                  |    -1.0
                  |    \"string\"
                  |    f\"string\"
                  |    b\"string\"
                  |    r\"string\"
                  |    :keyword
                  |    (smth)
                  |    #(smth)
                  |    {smth}
                  |    #{smth}
                  |    [smth]
                  |    #^
                  |    #*
                  |    #**)")

    (wy_str_test cont_wy cont_hy)

; _____________________________________________________________________________/ }}}1
; numbers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; +1_200.1_000E+3_3
    ; -.1E3

    (setv numbers_wyhy
        "1
        |1_000
        |-1
        |-1_000
        |+1
        |+1_000
        |1.
        |1_000.
        |-1.
        |-1_000.
        |+1.
        |+1_000.
        |1.1
        |1_000.1_000
        |-1.1
        |-1_000.1_000
        |+1.1
        |+1_000.1_000
        |.1
        |.1_000
        |-.1
        |-.1_000
        |+.1
        |+.1_000
        |1E1
        |1E+1
        |1E-1
        |1_000E1_000
        |1_000E+1_000
        |1_000E-1_000
        |1.E1
        |1.E+1
        |1.E-1
        |1_000.E1_000
        |1_000.E+1_000
        |1_000.E-1_000
        |+1.E1
        |+1.E+1
        |+1.E-1
        |+1_000.E1_000
        |+1_000.E+1_000
        |+1_000.E-1_000
        |-1.1_000E1
        |-1.1_000E+1
        |-1.1_000E-1
        |-1_000.1E1_000
        |-1_000.1E+1_000
        |-1_000.1E-1_000")

    (wy_str_test numbers_wyhy numbers_wyhy)

; _____________________________________________________________________________/ }}}1

    (assertm eq (w2h "")      "")
    (assertm eq (w2h "; 123") "; 123")
    (assertm eq (w2h "1.E-3") "1.E-3")
    (assertm eq (w2h "\\1")   " 1")
    (assertm eq (w2h "\\ 1")  "  1")
    (assertm eq (w2h " \\ 1") "   1")

    (assertm eq (w2h "x")     "(x)")
    (assertm eq (w2h "\nx")   "\n(x)")
    (assertm eq (w2h "\\x")   " x")
    (assertm eq (w2h "\\ x")  "  x")
    (assertm eq (w2h " \\ x") "   x")

    (assertm eq (w2h "[ncut : 1]")    "[ncut : 1]")
    (assertm eq (w2h "[ncut :\n 1]")  "[ncut :\n 1]")

