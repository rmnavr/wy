
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import termcolor)
    (import sys) (sys.setrecursionlimit 3000) ; needed for pyparser, I saw it crash at 1300

    (import  wy._fptk_local *)
    (require wy._fptk_local *)

    (import wy.Classes *)
    (import wy.Preparator    [wycode_to_prepared_code])
    (import wy.Parser        [prepared_code_to_ntlines])
    (import wy.Expander      [expand_ntlines])
    (import wy.Deconstructor [deconstruct_ntlines])
    (import wy.Bracketer     [bracktify_ndlines])
    (import wy.Writer        [blines_to_hcode])

; _____________________________________________________________________________/ }}}1

; [F] convert_wy2hy (assembly function) ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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
; [F] debug_wy2hy ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv clrz_d (fn [text] (termcolor.colored text None "on_white")))
    (setv clrz_u (fn [text] (termcolor.colored text "green")))

    (defn [validateF] 
        print_wy2hy_steps
        [ #^ WyCode code
        ]
        ;
        (print (clrz_d "Source (str):"))
        (print code)
        ;
        (print (clrz_d "Prepared code (str):"))
        (print (setx _prepared_code (wycode_to_prepared_code code)))
        ;
        (print (clrz_d "NTLines (list):"))
        (lprint (lmapm (sconcat (clrz_u "> ") (str it))
                       (setx _ntlines (prepared_code_to_ntlines _prepared_code))))
        ;
        (print (clrz_d "NTLines expanded (list):"))
        (lprint (lmapm (sconcat (clrz_u "> ") (str it))
                       (setx _entlines (expand_ntlines _ntlines))))
        ;
        (print (clrz_d "NDLines (list):"))
        (lprint (lmapm (sconcat (clrz_u "> ") (str it))
                       (setx _ndlines (deconstruct_ntlines _entlines))))
        ;
        (print (clrz_d "BLines (list):"))
        (lprint (lmapm (sconcat (clrz_u "> ") (str it))
                       (setx _blines (bracktify_ndlines _ndlines))))
        ;
        (print (clrz_d "Final hy code (str):"))
        (print (setx _hycode (blines_to_hcode _blines)))
        ;
        (print (clrz_d "============")))

; _____________________________________________________________________________/ }}}1

; [F] frame_hycode (for repl) ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv $FRAME_OP       "/=== TRANSPILED_HY_CODE ===")
    (setv $FRAME_CL    "\n\\=== TRANSPILED_HY_CODE ===")
    (setv $FRAME_COLOR "light_green") ; can be any value that is accepted by termcolor.colored

    (setv clrz_f (fn [text] (termcolor.colored text $FRAME_COLOR)))

    (defn frame_hycode
        [ #^ HyCode code
          #^ bool   [colored False]
        ]
        "this function is intended to be used in repl"
        (setv pre  (if colored (clrz_f $FRAME_OP) $FRAME_OP))
        (setv bar  (if colored (clrz_f "\n|") "\n|"))
        (setv post (if colored (clrz_f $FRAME_CL) $FRAME_CL))
        (setv lines (lconcat [pre] (lmapm (sconcat bar it) (code.split "\n")) [post]))
        (str_join lines))

; _____________________________________________________________________________/ }}}1

    (when (= __name__ "__main__")
          ; (setv _trnspld (convert_wy2hy "setv x 3\nprint x"))
          ; (print (frame_hycode _trnspld :colored True))
          ; (hy.eval (hy.read_many _trnspld))
          ; (print x)
          (print_wy2hy_steps "z\n  x\n y")
      )

