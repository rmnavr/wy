
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import  wy._fptk_local *)
    (import hy)
    (require wy._fptk_local *)

    (import wy.Classes *)

    (sys.setrecursionlimit 2000) ; needed for pyparser, I saw it crash at 1300
    (import termcolor)

    (import wy.Preparator    [wycode_to_prepared_code])
    (import wy.Parser        [prepared_code_to_ntlines])
    (import wy.Expander      [expand_ntlines])
    (import wy.Deconstructor [deconstruct_ntlines])
    (import wy.Bracketer     [bracktify_ndlines])
    (import wy.Writer        [blines_to_hcode])

; _____________________________________________________________________________/ }}}1

; [F] convert_wy2hy ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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

; _____________________________________________________________________________/ }}}1
; [F] frame_hycode ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv $FRAME_OP       "/=== TRANSPILED_HY_CODE ===")
    (setv $FRAME_CL    "\n\\=== TRANSPILED_HY_CODE ===")
    (setv $FRAME_COLOR "light_green") ; can be any value that is accepted by termcolor.colored

    (defn frame_hycode
        [ #^ HyCode code
          #^ bool   [colored False]
        ]
        (setv pre  (if colored (clrz $FRAME_OP) $FRAME_OP))
        (setv bar  (if colored (clrz "\n|") "\n|"))
        (setv post (if colored (clrz $FRAME_CL) $FRAME_CL))
        (setv lines (lconcat [pre] (lmapm (sconcat bar it) (code.split "\n")) [post]))
        (str_join lines))

    (defn clrz [text] (termcolor.colored text $FRAME_COLOR))

; _____________________________________________________________________________/ }}}1

    (when (= __name__ "__main__")
          ; (setv _trnspld (convert_wy2hy "setv x 3\nprint x"))
          ; (print (frame_hycode _trnspld :colored True))
          ; (hy.eval (hy.read_many _trnspld))
          ; (print x)
          )

