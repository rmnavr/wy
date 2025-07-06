
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import wy.Classes *)
    (import wy.Preparator [prepare_code_for_pyparsing])
    (import wy.Parser     [prepared_code_to_tlines_and_positions tline_to_dline])
    (import wy.Bracketer  [$CARD0 run_processor blines_to_hcode])

    (import sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))
    (sys.setrecursionlimit 2000) ; needed for pyparser, I saw it crash at 1300

    (import  _fptk_local *)
    (require _fptk_local *)

; _____________________________________________________________________________/ }}}1

; IO ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ WyCodeFull
        file_to_code #_ IO
        [#^ str file_name]
        (with [file (open file_name
                          "r"
                          :encoding "utf-8")]
              (setv outp (file.read)))
        (return outp))

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
; for debug: step_by_step ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ;(setv _prepared_code (prepare_code_for_pyparsing _hysky))
    ;(setv _prepared_code (prepare_code_for_pyparsing _wy_code))
    ;(setv [_tlines _positions] (prepared_code_to_tlines_and_positions _prepared_code))
    ;(setv _dlines (lmap tline_to_dline  _tlines))
    ;(setv _blines (run_processor $CARD0 _dlines)) ; produces +1 extra empty line at the end
    ;(setv _hycode (blines_to_hcode _blines _positions))     
    ;(print _hycode)

; _____________________________________________________________________________/ }}}1

    (when (= __name__ "__main__")
        (setv _wy_code (-> "..\\tests\\_test5.wy" file_to_code))
        (setv [t_s prompt outp] (with_execution_time (fm (convert_wy2hy _wy_code)) :tUnit "s"))
        (print f"> transpiled in {t_s :.3f} seconds")
        (print outp)
    )
