
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import  wy._fptk_local *)
    (require wy._fptk_local *)

    (import wy.Classes *)

    (sys.setrecursionlimit 2000) ; needed for pyparser, I saw it crash at 1300

    (import wy.Preparator    [wycode_to_prepared_code])
    (import wy.Parser        [prepared_code_to_ntlines])
    (import wy.Expander      [expand_ntlines])
    (import wy.Deconstructor [deconstruct_ntlines])
    (import wy.Bracketer     [bracktify_ndlines])
    (import wy.Writer        [blines_to_hcode])

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
        (-> "..\\tests\\old\\_test6_TT.wy"
            read_file
            convert_wy2hy
            print
            )
)

