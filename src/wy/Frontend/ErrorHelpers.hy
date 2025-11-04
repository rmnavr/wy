
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import  sys) (sys.setrecursionlimit 3000) ; needed for pyparser, I saw it crash at 1300

    (import  wy.utils.fptk_local *)
    (require wy.utils.fptk_local *)
    (import  wy.utils.coloring *)

    (import  wy.Backend.Classes *)
    (import  wy.Backend.Assembler [transpile_wy2hy])

; _____________________________________________________________________________/ }}}1

; helpers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ str
        extract_codeline_with_neighbours
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
; pretty-process Wy errors :: Code -> Error => str ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ str
        prettify_WyError
        [ #^ WyCode        code
          #^ WyParserError e
        ]
        (cond (oftypeQ WyParserError e)    (prettify_ParserError    code e)
              (oftypeQ WyExpanderError e)  (prettify_ExpanderError  code e)
              (oftypeQ WyBracketerError e) (prettify_BracketerError code e)
              ; if non Wy-error types were provided:
              True                         f"Unexpected error:\n{e}"))

    (defn #^ str
        prettify_ParserError
        [ #^ WyCode        code
          #^ WyParserError e
        ]
        ; todo: convert positions to actual line JFK
        (setv l1 (clrz_r f"Parser error at position {e.startpos}-{e.endpos}:"))
        (setv l2 f"{e.msg}")
        ;
        (sconcat l1 " " l2))

    (defn 
        prettify_ExpanderError
        [ #^ WyCode        code
          #^ WyParserError e
        ]
        ;
        (setv lineN1 (second e.ntline.lineNs))
        (setv lineN2 (third  e.ntline.lineNs))
        (if (eq lineN1 lineN2)
            (setv lineNstr f"line {lineN1}")
            (setv lineNstr f"lines {lineN1}-{lineN2}"))
        ;
        (setv l1 (sconcat (clrz_r f"Syntax error at {lineNstr}: ") f"{e.msg}"))
        (setv l2 (extract_codeline_with_neighbours code lineN1))
        (sconcat l1 "\n" l2))
                  
    (defn 
        prettify_BracketerError
        [ #^ WyCode           code
          #^ WyBracketerError e
        ]
        ;
        (setv lineN (second e.ndline.rowN))
        (setv l1 (sconcat (clrz_r f"Indent error at line {lineN}: ") f"{e.msg}"))
        (setv l2 (extract_codeline_with_neighbours code lineN))
        (sconcat l1 "\n" l2))

; _____________________________________________________________________________/ }}}1

; [F] run_wy2hy_transpilation ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ HyCode
        run_wy2hy_transpilation
        [ #^ WyCode code
          #^ bool   [silent False]
        ]
        "prints (not raises!) error when error encountered;
         returns empty string when transpilation failed"
        (setv outp "")
        (try (setv outp (transpile_wy2hy code))
             (except [e [ WyParserError
                          WyExpanderError
                          WyBracketerError]]
                     (unless silent
                             (print (prettify_WyError code e))))
             (except [e Exception]
                     (unless silent
                             (print f"Unexpected error:\n{e}"))))
        (return outp))

; _____________________________________________________________________________/ }}}1


