
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import Classes *)
    (import Preparator [prepare_code_for_pyparsing])
    (import Parser     [prepared_code_to_tlines tline_to_dline])
    (import Bracketer  [$CARD0 run_processor blines_to_hcode])

    (import sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))
    (sys.setrecursionlimit 2000) ; needed for pyparser, I saw it crash at 1300

    (require hyrule [of as-> -> ->> doto case branch unless lif do_n list_n ncut])
    (import  _hyextlink *)
    (require _hyextlink [f:: fm p> pluckm lns &+ &+> l> l>=] :readers [L])

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
        wy2hy
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
        (try (setv _tlines (prepared_code_to_tlines _prepared_code))
             (except [e Exception] (raise (Exception (nth 1 errors)))))
        ;
        (try (setv _dlines (lmap tline_to_dline  _tlines))
             (except [e Exception] (raise (Exception (nth 2 errors)))))
        ;
        (try (setv _blines (run_processor $CARD0 _dlines))
             (except [e Exception] (raise (Exception (nth 3 errors)))))
        ;
        (try (setv _hycode (blines_to_hcode _blines))
             (except [e Exception] (raise (Exception (nth 4 errors)))))
        ;
        (return _hycode))

; _____________________________________________________________________________/ }}}1

; for debug: step_by_step ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ;(setv _prepared_code (prepare_code_for_pyparsing _hysky))
    ;(setv _tlines        (prepared_code_to_tlines _prepared_code))  ; tokenize
    ;(setv _dlines        (lmap tline_to_dline  _tlines))            ; deconstruct
    ;(setv _blines        (run_processor $CARD0 _dlines))            ; bracketize
    ;(setv _hycode        (blines_to_hcode _blines))                 ; assembly

    ;(print  "=== source hysky code ===")  (print  _hysky)           (print "")
    ;(print  "=== prepared code ===")      (print  _prepared_code)   (print "")
    ;(print  "=== tokenized lines ===")    (lprint _tlines)          (print "")
    ;(print  "=== decontructed lines ===") (lprint _dlines)          (print "")
    ;(print  "=== bracketed lines ===")    (lprint _blines)          (print "")
    ;(print  "=== final hy code ===")      (print _hycode)           (print "")
    ;(print  "=== repl result ===")        (-> _hycode hy.read_many hy.eval)

; _____________________________________________________________________________/ }}}1

    (when (= __name__ "__main__")
        (setv _wy_code (-> "tests\\_test1.wy" file_to_code))
        (setv [t_s prompt outp] (execution_time (fm (wy2hy _wy_code)) :tUnit "s"))
        (print f"> transpiled in {t_s :.3f} seconds")
        (print outp)
        ;(-> _hysky wy2hy hy.read_many hy.eval)
    )
