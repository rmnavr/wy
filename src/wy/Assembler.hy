
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

; direct usage:
; [F] convert_wy2hy (assembly function) ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ HyCode
        convert_wy2hy
        [ #^ WyCode code
        ]
        ;
        (->> code
             wycode_to_prepared_code
             prepared_code_to_ntlines  ; parser
             expand_ntlines            ; expander
             deconstruct_ntlines        
             bracktify_ndlines         ; bracketer
             blines_to_hcode))

; _____________________________________________________________________________/ }}}1

; utils: coloring ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv clrz_lg (fn [text] (termcolor.colored text "light_green")))
    (setv clrz_ow (fn [text] (termcolor.colored text None "on_white")))
    (setv clrz_g  (fn [text] (termcolor.colored text "green")))
    (setv clrz_r  (fn [text] (termcolor.colored text "red")))

; _____________________________________________________________________________/ }}}1
; for repl:
; [F] frame_hycode  ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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
; for debug:
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
; pretty-prenters helpers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF]
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

; _____________________________________________________________________________/ }}}1
; [F] pretty-process errors ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn 
        process_ParserError
        [ #^ WyCode        code
          #^ WyParserError e
        ]
        ;
        (setv msg (sconcat f"Parser error at position {e.startpos}-{e.endpos}:"
                           f"\n{e.msg}"))
        (print (clrz_r msg)))

    (defn 
        process_ExpanderError
        [ #^ WyCode        code
          #^ WyParserError e
        ]
        ;
        (setv lineN (first e.ntline.lineNs))
        (print (clrz_r f"Syntax error at line {lineN}:") f"\n{e.msg}")
        (print (get_codeline_with_neighbours code lineN)))
                  
    (defn 
        process_BracketerError
        [ #^ WyCode           code
          #^ WyBracketerError e
        ]
        ;
        (setv lineN (first e.ndline.rowN))
        (print (clrz_r f"Indent error at line {lineN}:"))
        (print (get_codeline_with_neighbours code lineN)))

; _____________________________________________________________________________/ }}}1
; [F] main: debug_wy2hy ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn 
        print_wy2hy_steps
        [ #^ WyCode code
        ]
        ;
        (print (clrz_ow "Source (str):"))
        ; Preparator:
        (print (clrz_ow "Prepared code (str):"))
        (setv dts [])
        (dt_calc "START TIMER" :fresh_run True) 
        (print (setx _prepared_code (wycode_to_prepared_code code)))
        (dts.append (dt_calc "<- Preparator"))
        ; Parser:
        (print (clrz_ow "NTLines (list):"))
        (try (lprint (lmapm (sconcat (clrz_g "> ") (str it))
                            (setx _ntlines (prepared_code_to_ntlines _prepared_code))))
             (except [e WyParserError] (process_ParserError code e) (sys.exit 1)))
        (dts.append (dt_calc "<- Parser"))
        ; Expander (including: omarker2sm, syntax_check):
        (print (clrz_ow "NTLines expanded (list):"))
        (try (lprint (lmapm (sconcat (clrz_g "> ") (str it))
                            (setx _entlines (expand_ntlines _ntlines))))
             (except [e WyExpanderError] (process_ExpanderError code e) (sys.exit 1)))
        (dts.append (dt_calc "<- Expander"))
        ; Deconstructor:
        (print (clrz_ow "NDLines (list):"))
        (lprint (lmapm (sconcat (clrz_g "> ") (str it))
                       (setx _ndlines (deconstruct_ntlines _entlines))))
        (dts.append (dt_calc "<- Deconstructor"))
        ; Bracketer:
        (print (clrz_ow "BLines (list):"))
        (try (lprint (lmapm (sconcat (clrz_g "> ") (str it))
                            (setx _blines (bracktify_ndlines _ndlines))))
             (except [e WyBracketerError] (process_BracketerError code e) (sys.exit 1)))
        (dts.append (dt_calc "<- Bracketer"))
        ; Writer:
        (print (clrz_ow "Final hy code (str):"))
        (print (setx _hycode (blines_to_hcode _blines)))
        (dts.append (dt_calc "<- Writer"))
        ;
        (print (clrz_ow "============"))
        (print "Run times:")
        (lprint dts))

; _____________________________________________________________________________/ }}}1

    (when (= __name__ "__main__")
          (setv wycode (read_file "_tmp_del_me.wy"))
          (print_wy2hy_steps wycode)
          ;(print_wy2hy_steps "zus\n  xenum\n ynot\npups\nbubr")
          ;(wycode2tokens "C#C ()")
      )


