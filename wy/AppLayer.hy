
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import Classes *)
    (import Preparator [prepare_code_for_pyparsing])
    (import Parser     [prepared_code_to_tlines_and_positions tline_to_dline])
    (import Bracketer  [$CARD0 run_processor blines_to_hcode])

    (import sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))
    (sys.setrecursionlimit 2000) ; needed for pyparser, I saw it crash at 1300

    (import  wy._fptk_local *)
    (require wy._fptk_local *)

; _____________________________________________________________________________/ }}}1

; wy2hy ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ HyCodeFull
        convert_wy2hy
        [ #^ WyCodeFull code
        ]
        ;
        (setv prefix "[wy2hy] Failed at: ")
        (setv errors [ "Stage 1 (code preparation stage)"
                       "Stage 2 (pyparsing stage)"
                       "Stage 3 (constructing deconstructing lines stage)"
                       "Stage 4 (bracket count stage)"
                       "Stage 5 (final assembly stage)"
                     ])
        (setv errors (lmap (partial sconcat prefix) errors))
        ;
        (try (setv _prepared_code (prepare_code_for_pyparsing code))
             (except [e Exception] (raise (Exception (nth 0 errors)))))
        ;
        (try (setv [_tlines _positions]
                   (prepared_code_to_tlines_and_positions _prepared_code))
             (except [e Exception] (raise (Exception (nth 1 errors)))))
        ;
        (try (setv _dlines (lmap tline_to_dline _tlines))
             (except [e Exception] (raise (Exception (nth 2 errors)))))
        ;
        (try (setv _blines (run_processor $CARD0 _dlines))
             (except [e Exception] (raise (Exception (nth 3 errors)))))
        ;
        (try (setv _hycode (blines_to_hcode _blines _positions))
             (except [e Exception] (raise (Exception (nth 4 errors)))))
        ;
        (return _hycode))

; _____________________________________________________________________________/ }}}1

    ; «run_processor» produces +1 extra empty line at the end (dt)

    (when (= __name__ "__main__")
        (setv _wy_code (read_file "..\\tests\\!Examples_for_docs.wy"))
        (setv _prepared_code (prepare_code_for_pyparsing _wy_code))
        (setv [_tlines _positions] (prepared_code_to_tlines_and_positions _prepared_code))
        (setv _dlines (lmap tline_to_dline  _tlines))
        (setv _blines (run_processor $CARD0 _dlines))
        (setv _hy_code (blines_to_hcode _blines _positions))
        ;
        (print _hy_code)
        )
