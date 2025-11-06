
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import  sys) (sys.setrecursionlimit 3000) ; needed for pyparser, I saw it crash at 1300

    (import  wy.utils.fptk_local *)
    (require wy.utils.fptk_local *)
    (import  wy.utils.coloring *)

    (import  wy.Backend.Classes *)
    (import  wy.Backend.Assembler [transpile_wy2hy])

; _____________________________________________________________________________/ }}}1

    (defclass [] PrettyTEMsg [BaseModel]
        "Pretty Transpilation Error Message.
         This is essentially str synonim, but differentiated by pydantic."
        (#^ StrictStr msg)
        (defn __init__ [self m] (-> (super) (.__init__ :msg m))))

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

    (defn #^ PrettyTEMsg
        prettify_WyError
        [ #^ WyCode        code
          #^ WyParserError e
        ]
        (cond (oftypeQ WyParserError e)    (PrettyTEMsg (str_prepare_ParserError    code e))
              (oftypeQ WyExpanderError e)  (PrettyTEMsg (str_prepare_ExpanderError  code e))
              (oftypeQ WyBracketerError e) (PrettyTEMsg (str_prepare_BracketerError code e))
              ; if non Wy-error types were provided:
              True                         f"Unexpected error:\n{e}"))

    (defn #^ str
        str_prepare_ParserError
        [ #^ WyCode        code
          #^ WyParserError e
        ]
        ; todo: convert positions to actual line JFK
        (setv l1 (clrz_r f"Parser error at position {e.startpos}-{e.endpos}:"))
        (setv l2 f"{e.msg}: {e.char}")
        ;
        (sconcat l1 " " l2))

    (defn #^ str
        str_prepare_ExpanderError
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
                  
    (defn #^ str
        str_prepare_BracketerError
        [ #^ WyCode           code
          #^ WyBracketerError e
        ]
        ;
        (setv lineN (second e.ndline.rowN))
        (setv l1 (sconcat (clrz_r f"Indent error at line {lineN}: ") f"{e.msg}"))
        (setv l2 (extract_codeline_with_neighbours code lineN))
        (sconcat l1 "\n" l2))

; _____________________________________________________________________________/ }}}1

; [F] run wy2hy transpilation -> Result[HyCode, PrettyTEMsg] ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ (of Result HyCode PrettyTEMsg)
        run_wy2hy_transpilation
        [ #^ WyCode code
          #^ bool   [silent True] ; when False, immediately prints found msg
        ]
        "On success returns HyCode, 
         on failure, returns prettified error msg;
         Never raises"
        (try (setv _trnsplR (Success (transpile_wy2hy code)))
             (except [e [ WyParserError
                          WyExpanderError
                          WyBracketerError]]
                     (setv _trnsplR (Failure (prettify_WyError code e))))
             (except [e Exception]
                     (setv _trnsplR (Failure (PrettyTEMsg f"Unexpected error:\n{e}")))))
        ;
        (when (and (not silent) (failureQ _trnsplR))
              (print :file sys.stderr (-> _trnsplR unwrapE (getattrm .msg))))
        (return _trnsplR))

; _____________________________________________________________________________/ }}}1


