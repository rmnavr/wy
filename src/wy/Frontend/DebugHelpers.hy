
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import  sys) (sys.setrecursionlimit 3000) ; needed for pyparser, I saw it crash at 1300

    (import  wy.utils.fptk_local *)
    (require wy.utils.fptk_local *)
    (import  wy.utils.coloring *)

    (import  wy.Backend.Classes *)

    (import  wy.Backend.Assembler     [transpile_wy2hy])
    (import  wy.Frontend.ErrorHelpers [prettify_WyError])

    (import  wy.Backend.Preparator    [wycode_to_prepared_code])
    (import  wy.Backend.Parser        [prepared_code_to_ntlines])
    (import  wy.Backend.Expander      [expand_ntlines])
    (import  wy.Backend.Deconstructor [deconstruct_ntlines])
    (import  wy.Backend.Bracketer     [bracktify_ndlines])
    (import  wy.Backend.Writer        [blines_to_hcode])

; _____________________________________________________________________________/ }}}1

; utils: timer ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; state-full function
    ; that prints t=0 for first call and dt=0.003s and such
    ; for subsequent clls

    (defn dt_calc
        [ [msg       ""]
          [fresh_run False]
          [last_T    [None]]
        ]
        (when fresh_run (assoc last_T 0 None))
        (if (neq msg "")
            (setv msg_ (sconcat " " msg))
            (setv msg_ msg))
        (setv _time_getter hy.I.time.perf_counter)
        (setv curT (_time_getter))
        ;;
        (if (=  (get last_T 0) None)
            (do (assoc last_T 0 curT)
                (return (sconcat "[ Timer started ]" msg_)))
            (do (setv dT (- curT (get last_T 0)))
                (assoc last_T 0 curT)
                (return (sconcat f"[dT = {dT :.6f} s]" msg_)))))


; _____________________________________________________________________________/ }}}1

; [helper] only_print (raise on errors) ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn 
        print_wy2hy_steps_with_raise
        [ #^ WyCode code
        ]
        "will raise (not print) errors"
        ;
        (print (clrz_ow "Source (str):"))
        (print code)
        ; Preparator:
        (print (clrz_ow "[Preparator]    Prepared code (str):"))
        (setv dts [])
        (dt_calc "START TIMER" :fresh_run True) 
        (print (setx _prepared_code (wycode_to_prepared_code code)))
        (dts.append (dt_calc "<- Preparator"))
        ; Parser:
        (print (clrz_ow "[Parser]        NTLines (list):"))
        (lprint (lmapm (sconcat (clrz_g "> ") (str it))
                       (setx _ntlines (prepared_code_to_ntlines _prepared_code))))
        (dts.append (dt_calc "<- Parser"))
        ; Expander (including: omarker2sm, syntax_check):
        (print (clrz_ow "[Expander]      NTLines expanded (list):"))
        (lprint (lmapm (sconcat (clrz_g "> ") (str it))
                       (setx _entlines (expand_ntlines _ntlines))))
        (dts.append (dt_calc "<- Expander"))
        ; Deconstructor:
        (print (clrz_ow "[Deconstructor] NDLines (list):"))
        (lprint (lmapm (sconcat (clrz_g "> ") (str it))
                       (setx _ndlines (deconstruct_ntlines _entlines))))
        (dts.append (dt_calc "<- Deconstructor"))
        ; Bracketer:
        (print (clrz_ow "[Bracketer]     BLines (list):"))
        (lprint (lmapm (sconcat (clrz_g "> ") (str it))
                       (setx _blines (bracktify_ndlines _ndlines))))
        (dts.append (dt_calc "<- Bracketer"))
        ; Writer:
        (print (clrz_ow "[Writer]        Final hy code (str):"))
        (print (setx _hycode (blines_to_hcode _blines)))
        (dts.append (dt_calc "<- Writer"))
        ;
        (print (clrz_ow "============"))
        (print "Run times:")
        (lprint dts))

; _____________________________________________________________________________/ }}}1
; [helper] wrapper on printer (pretty-print wy-errors) ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn
        print_wy2hy_steps_with_pretty_errors_print
        [ #^ WyCode code
        ]
        "will pretty print WyErrors
         will raise other errors"
        (setv outp "")
        (try (setv outp (print_wy2hy_steps_with_raise code))
             (except [e [ WyParserError
                          WyParserError2
                          WyExpanderError
                          WyDeconstructorError
                          WyBracketerError ]]
                     (setv PTEMsg (prettify_WyError code e))
                     (print PTEMsg.msg))
             (except [e Exception]
                     (print "Unexpected error:")
                     (raise e))) ; unlike run_wy2hy_transpilation, here Unexpected error is raised instead of returns as Failure
        (return outp))

; _____________________________________________________________________________/ }}}1
; [F] print_wy2hy_steps ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn
        print_wy2hy_steps
        [ #^ WyCode code
          #^ bool   [pretty_errors True]
        ]
        (if pretty_errors
            (print_wy2hy_steps_with_pretty_errors_print code)
            (print_wy2hy_steps_with_raise               code)))

; _____________________________________________________________________________/ }}}1

    (setv $TEST (read_file "E:/00_Vault/SynchW/04 Opensource/Hy/wy/tests/FE03_REPL.wy"))
    (setv $TEST
    "
     \"riba\ngus\" $ y


    "

        )

    (when  (= __name__ "__main__")
        (print_wy2hy_steps $TEST
                           :pretty_errors True))



