
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

; [F] utils: coloring ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv clrz_lg (fn [text] (termcolor.colored text "light_green")))
    (setv clrz_ow (fn [text] (termcolor.colored text None "on_white")))
    (setv clrz_g  (fn [text] (termcolor.colored text "green")))
    (setv clrz_r  (fn [text] (termcolor.colored text "red")))

; _____________________________________________________________________________/ }}}1
; [F] frame_hycode (for repl) ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv $FRAME_OP       "/=== TRANSPILED_HY_CODE ===")
    (setv $FRAME_CL    "\n\\=== TRANSPILED_HY_CODE ===")

    (defn frame_hycode
        [ #^ HyCode code
          #^ bool   [colored False]
        ]
        "this function is intended to be used in repl"
        (setv pre  (if colored (clrz_lg $FRAME_OP) $FRAME_OP))
        (setv bar  (if colored (clrz_lg "\n|") "\n|"))
        (setv post (if colored (clrz_lg $FRAME_CL) $FRAME_CL))
        (setv lines (lconcat [pre] (lmapm (sconcat bar it) (code.split "\n")) [post]))
        (str_join lines))

; _____________________________________________________________________________/ }}}1

; [F] process Bracketer errors ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn 
        get_codeline_with_neighbours
        [ #^ WyCode    code
          #^ StrictInt lineN ] ; in 1-based index due to wy line-count logic
        (setv lineN0 (dec lineN))
        (setv lines (code.split "\n"))
        ;
        (setv sep  (clrz_g "---------------"))
        (setv pre  (cut lines 0 lineN0))
        (setv post (cut lines (inc lineN0) None))
        (setv main (clrz_r (get lines lineN0)))
        ;
        (str_join [ sep
                    #* (take -5 pre)
                    main
                    #* (take 3 post)
                    sep]
                  :sep "\n"))
                  
    (defn 
        process_BracketerError
        [ #^ WyCode code
          #^ WyBracketerError e
        ]
        ;
        (setv lineN (second e.ndline.rowN))
        (print (clrz_r f"Indent error at line {lineN}:"))
        (print (get_codeline_with_neighbours code lineN)))

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

    (defn [validateF]
        wycode2tokens [#^ WyCode code]
        (->> code
             wycode_to_prepared_code
             prepared_code_to_ntlines
             (pluckm .tokens)))

    (defn [validateF] 
        print_wy2hy_steps
        [ #^ WyCode code
        ]
        ;
        (print (clrz_ow "Source (str):"))
        (print code)
        ;
        (print (clrz_ow "Prepared code (str):"))
        (print (setx _prepared_code (wycode_to_prepared_code code)))
        ;
        (print (clrz_ow "NTLines (list):"))
        (lprint (lmapm (sconcat (clrz_g "> ") (str it))
                       (setx _ntlines (prepared_code_to_ntlines _prepared_code))))
        ;
        (print (clrz_ow "NTLines expanded (list):"))
        (lprint (lmapm (sconcat (clrz_g "> ") (str it))
                       (setx _entlines (expand_ntlines _ntlines))))
        ;
        (print (clrz_ow "NDLines (list):"))
        (lprint (lmapm (sconcat (clrz_g "> ") (str it))
                       (setx _ndlines (deconstruct_ntlines _entlines))))
        ;
        (print (clrz_ow "BLines (list):"))
        (try (lprint (lmapm (sconcat (clrz_g "> ") (str it))
                            (setx _blines (bracktify_ndlines _ndlines))))
             (except [e WyBracketerError]
                     (process_BracketerError code e)
                     (sys.exit 1)))
        ;
        (print (clrz_ow "Final hy code (str):"))
        (print (setx _hycode (blines_to_hcode _blines)))
        ;
        (print (clrz_ow "============")))

; _____________________________________________________________________________/ }}}1

    (when (= __name__ "__main__")
          ; (setv _trnspld (convert_wy2hy "setv x 3\nprint x"))
          ; (print (frame_hycode _trnspld :colored True))
          ; (hy.eval (hy.read_many _trnspld))
          ; (print x)
          ;
          ;(print_wy2hy_steps "zus\n  xenum\n ynot\npups\nbubr")
          (lprint (wycode2tokens "C#C ()"))
      )


