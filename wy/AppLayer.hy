
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import  _fptk_local *)
    (require _fptk_local *)

    (import Classes *)

    (sys.setrecursionlimit 2000) ; needed for pyparser, I saw it crash at 1300

    (import Preparator    [wycode_to_prepared_code])
    (import Parser        [prepared_code_to_ntlines])
    (import Expander      [expand_ntlines])
    (import Deconstructor [deconstruct_ntlines])
    (import Bracketer     [bracktify_ndlines])
    (import Writer        [blines_to_hcode])

; _____________________________________________________________________________/ }}}1

    (defn [validateF] #^ HyCode
        convert_wy2hy
        [ #^ WyCode code
        ]
        ;
        (->> code
             wycode_to_prepared_code
             prepared_code_to_ntlines
             expand_ntlines
             deconstruct_ntlines
             bracktify_ndlines
             blines_to_hcode))

    (when (= __name__ "__main__")

        (-> "..\\tests\\_test6_TT.wy"
            read_file
            convert_wy2hy
            print
            )

    )

