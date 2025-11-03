
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import termcolor)
    (import sys) (sys.setrecursionlimit 3000) ; needed for pyparser, I saw it crash at 1300

    (import  wy.utils.fptk_local *)
    (require wy.utils.fptk_local *)
    (import  wy.utils.coloring *)

    (import  wy.Backend.Classes *)
    (import  wy.Backend.Preparator    [wycode_to_prepared_code])
    (import  wy.Backend.Parser        [prepared_code_to_ntlines])
    (import  wy.Backend.Expander      [expand_ntlines])
    (import  wy.Backend.Deconstructor [deconstruct_ntlines])
    (import  wy.Backend.Bracketer     [bracktify_ndlines])
    (import  wy.Backend.Writer        [blines_to_hcode])

; _____________________________________________________________________________/ }}}1

; assembling transpilation pipeline:
; [F] transpile_wy2hy ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ HyCode
        transpile_wy2hy
        [ #^ WyCode code
        ]
        "can be used for dev/debug, since always raises exceptions"
        (->> code
             wycode_to_prepared_code
             repared_code_to_ntlines
             expand_ntlines
             deconstruct_ntlines        
             bracktify_ndlines
             blines_to_hcode))

; _____________________________________________________________________________/ }}}1
; [F] convert_wy2hy (assembly function) ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ HyCode
        convert_wy2hy
        [ #^ WyCode code
        ]
        ;
        (->> code
             ; Preparator:
             wycode_to_prepared_code
             ; Parser:
             (f> (try (prepared_code_to_ntlines it)
                      ))
             ; Expander (including: omarker2sm, syntax_check):
             (f> (try (expand_ntlines it)
                      ))
             ; Deconstructor:
             deconstruct_ntlines        
             ; Bracketer:
             (f> (try (bracktify_ndlines it)
                      ))
             ; Writer:
             blines_to_hcode))

    ; NOT USED CURRENTLY
    (defn [validateF] #^ HyCode
        run_wy2hy_transpilation
        [ #^ WyCode code
          #^ bool   exit_on_error
        ]
        "supposed to be called from other python scripts,
         this is why it doesn't sys.exit on finish"
        (try (transpile_wy2hy code)
             (except [e WyParserError]    (print_ParserError    code e))
             (except [e WyExpanderError]  (print_ExpanderError  code e))
             (except [e WyBracketerError] (print_BracketerError code e))
             (except [e Exception]        (print e))
             ))

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
; pretty-printers helpers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF]
        get_codeline_with_neighbours
        [ #^ WyCode    code
          #^ StrictInt lineN ] ; in 1-based index due to wy line-count logic
        (setv lineN0 (dec lineN))
        (setv lines  (code.split "\n"))
        ;
        (setv digitsN (len (str (len lines))))
        (setv lines   (lmap (fn [n l] (sconcat f"{n :0{digitsN}d}| " l))
                            (inf_range 1)
                            lines))
        ;
        (setv pre  (cut lines 0 lineN0))
        (setv post (cut lines (inc lineN0) None))
        (setv main (clrz_r (get lines lineN0)))
        ;
        (str_join [ #* (take -5 pre)
                    main
                    #* (take 3 post) ]
                  :sep "\n"))

; _____________________________________________________________________________/ }}}1
; [F] pretty-process errors ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn 
        print_ParserError
        [ #^ WyCode        code
          #^ WyParserError e
        ]
        ; todo: convert positions to actual line JFK
        (print (clrz_r f"Parser error at position {e.startpos}-{e.endpos}:"))
        (print f"{e.msg}"))

    (defn 
        print_ExpanderError
        [ #^ WyCode        code
          #^ WyParserError e
        ]
        ;
        (setv lineN1 (second e.ntline.lineNs))
        (setv lineN2 (third  e.ntline.lineNs))
        (if (eq lineN1 lineN2)
            (setv lineNstr f"line {lineN1}")
            (setv lineNstr f"lines {lineN1}-{lineN2}"))
        (print (clrz_r f"Syntax error at {lineNstr}:") f"\n{e.msg}")
        (print (get_codeline_with_neighbours code lineN1)))
                  
    (defn 
        print_BracketerError
        [ #^ WyCode           code
          #^ WyBracketerError e
        ]
        ;
        (setv lineN (second e.ndline.rowN))
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
             (except [e WyParserError] (print_ParserError code e) (sys.exit 1)))
        (dts.append (dt_calc "<- Parser"))
        ; Expander (including: omarker2sm, syntax_check):
        (print (clrz_ow "NTLines expanded (list):"))
        (try (lprint (lmapm (sconcat (clrz_g "> ") (str it))
                            (setx _entlines (expand_ntlines _ntlines))))
             (except [e WyExpanderError] (print_ExpanderError code e) (sys.exit 1)))
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
             (except [e WyBracketerError] (print_BracketerError code e) (sys.exit 1)))
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
          (setv wycode (read_file "..\\test.wy"))
          (print_wy2hy_steps wycode)
          (print (convert_wy2hy wycode)))

    (setv $DUMMY_HYCODE "\"wy2hy convertion failed\"")

    ; raise (traise) + catch later
    ; print
    ; sys.exit

