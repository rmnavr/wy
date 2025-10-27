
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import  wy._fptk_local *)
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
; [F] wy2REPL ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv $FRAME_OP       "/=== TRANSPILED WY->HY CODE ===")
    (setv $FRAME_CL    "\n\\=== TRANSPILED WY->HY CODE ===")
    (setv $FRAME_COLOR "light_green") ; can be any value that is accepted by termcolor.colored

    (defn [validateF]
        wy2REPL
        [ #^ WyCode code
          *
          #^ bool [spy False]
          #^ bool [frame False]
          #^ bool [colored_frame False]
        ]
        "- spy           -- also prints transpiled hy-code before executing it
         - frame         -- wrap printed code into frame (to make it visualy stand out)
         - colored_frame -- make frame colored (to make it stand out even more)
        "
        (setv _hy_code (convert_wy2hy code))
        (when spy
            (if frame
                (print (frame_hycode colored_frame _hy_code))
                (print _hy_code)))
        (hy.eval (hy.read_many _hy_code)))

    (defn frame_hycode
        [ #^ bool   colored
          #^ HyCode code
        ]
        (setv pre  (if colored (clrz $FRAME_OP) $FRAME_OP))
        (setv bar  (if colored (clrz "\n|") "\n|"))
        (setv post (if colored (clrz $FRAME_CL) $FRAME_CL))
        (setv lines (lconcat [pre] (lmapm (sconcat bar it) (code.split "\n")) [post]))
        (str_join lines))

    (defn clrz [text] (termcolor.colored text $FRAME_COLOR))

; _____________________________________________________________________________/ }}}1

    (when (= __name__ "__main__")
          ; (print (frame_hycode True "bubr\n  riba"))
          ; (wy2REPL "print 3" :spy True :frame True :colored_frame True)
          )

