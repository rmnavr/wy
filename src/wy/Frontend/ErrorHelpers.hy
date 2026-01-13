
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import  sys) (sys.setrecursionlimit 3000) ; needed for pyparser, I saw it crash at 1300

    (require wy.utils.fptk_local.loader [load_fptk])
    (load_fptk "core" "resultM")
    (import  wy.utils.coloring *)

    (import  wy.Backend.Classes *)
    (import  wy.Backend.Assembler [transpile_wy2hy])

; _____________________________________________________________________________/ }}}1

; [C] PrettyTEMsg ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defclass [dataclass] PrettyTEMsg []
        "Pretty Transpilation Error Message.
         This is essentially str synonim, but differentiated from pure str
         (this is used in Result monad subtypes of run_wy2hy_transpilation)"
        (#^ str msg))

; _____________________________________________________________________________/ }}}1

; helper: pretty extract codeline ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ str
        extract_codeline_with_neighbours
        [ #^ WyCode            code
          #^ int               lineN1         ; start     ; in 1-based index due to wy line-count logic
          #^ (of Optional int) [lineN2 None]] ; end>start ; in 1-based index due to wy line-count logic
        (setv $PRE 5)
        (setv $POST 3)
        ;
        (if (noneQ lineN2)
            (setv lineN2_ lineN1)
            (setv lineN2_ lineN2))
        ;
        (setv nmbrdLines (numerize_lines code))
        ;
        (setv preNs                                                 ; in 1-based index
            (lfilter (pflip geq 1)
                     (range_ (minus lineN1 $PRE) (dec lineN1))))
        (setv mainNs (lrange_ lineN1 lineN2_))                       ; in 1-based index
        (setv postNs                                                ; in 1-based index
            (lfilter (pflip leq (len nmbrdLines))
                     (range_ (inc lineN2_) (plus lineN2_ $POST))))
        ;
        (str_join
            (flatten [ (pick (lmap dec preNs) nmbrdLines)
                       (lmap clrz_r (pick (lmap dec mainNs) nmbrdLines))
                       (pick (lmap dec postNs) nmbrdLines)])
                  :sep "\n"))

    (defn #^ (of List str)
        numerize_lines
        [ #^ str code
        ]
        "returns code in form (numbering starts from 1):
         1| smth smth
         2| ololo
        "
        (setv codelines (code.split "\n"))
        (setv nZeroes (len (str (len codelines))))
        (lmap (fn [n cl] (sconcat f"{n :0{nZeroes}d}| " cl))
                  (inf_range 1)
                  codelines))

; _____________________________________________________________________________/ }}}1
; helper: preparedcode charpos to lineN ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of Optional int)
        charpos_to_lineN
        [ #^ int char_pos ; 0-based index
          #^ str text
        ]
        "returned lineN is given in 1-based index"
        (setv newline_positions
              (lfor [&i &ch] (enumerate text)
                    :if (eq &ch "\n")
                    &i))
        (setv breaks [0 #* newline_positions (-> text len dec)])
        (for [[&i [&a &b]] (enumerate (pairwise breaks))]
              (when (and (>= char_pos &a) (<= char_pos &b))
                    (return (inc &i))))
        (return None))

    (defn #^ (of Optional int)
        preparedcode_charpos_to_orig_lineN
        [ #^ int    char_pos ; 0-based index
          #^ WyCode code     ; yes, WyCode is used to calc PreparedCode positions
         ]
         (setv lines (code.split "\n"))
         (setv semiprep_lines (lmap (partial sconcat $NEWLINE_MARK) lines))
         (setv semiprep_code  (str_join semiprep_lines :sep "\n"))
         (return (charpos_to_lineN char_pos semiprep_code)))

; _____________________________________________________________________________/ }}}1
; pretty-process Wy errors :: Code -> Error => PrettyTEMsg ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ PrettyTEMsg
        prettify_WyError
        [ #^ WyCode        code
          #^ WyParserError e
        ]
        (cond (oftypeQ WyParserError         e) (PrettyTEMsg (str_prepare_ParserError        code e))
              (oftypeQ WyParserError2        e) (PrettyTEMsg (str_prepare_ParserError2       code e))
              (oftypeQ WyExpanderError       e) (PrettyTEMsg (str_prepare_ExpanderError      code e))
              (oftypeQ WyDeconstructorError  e) (PrettyTEMsg (str_prepare_DeconstructorError code e))
              (oftypeQ WyBracketerError      e) (PrettyTEMsg (str_prepare_BracketerError     code e))
              ; if non Wy-error types were provided:
              True                         f"Unexpected error:\n{e}"))

    (defn #^ str
        str_prepare_ParserError
        [ #^ WyCode        code
          #^ WyParserError e
        ]
        ; since e.startpos and e.endpos are given on PreparedCode rather than on WyCode,
        ; positioning have to be readjusted — it is done here
        (setv lineN (preparedcode_charpos_to_orig_lineN e.startpos code)) ; removes ■ and ☇¦
        ;
        (setv l1 (sconcat (clrz_r f"Parser error at {lineN}: ") f"{e.msg}"))
        (setv l2 (extract_codeline_with_neighbours code lineN))
        (sconcat l1 "\n" l2))

    (defn #^ str
        str_prepare_ParserError2
        [ #^ WyCode         code
          #^ WyParserError2 e
        ]
        (setv [_ lineN1 lineN2] e.ntline.lineNs)
        (if (eq lineN1 lineN2)
            (setv lineNstr f"line {lineN1}")
            (setv lineNstr f"lines {lineN1}-{lineN2}"))
        ;
        (setv l1 (sconcat (clrz_r f"Parser error at {lineNstr}: ") f"{e.msg}"))
        (setv l2 (extract_codeline_with_neighbours code lineN1 lineN2))
        (sconcat l1 "\n" l2))

    (defn #^ str
         str_prepare_ExpanderError
         [ #^ WyCode        code
           #^ WyParserError e
         ]
         ;
        (setv [_ lineN1 lineN2] e.ntline.lineNs)
         (if (eq lineN1 lineN2)
             (setv lineNstr f"line {lineN1}")
             (setv lineNstr f"lines {lineN1}-{lineN2}"))
         ;
         (setv l1 (sconcat (clrz_r f"Syntax error at {lineNstr}: ") f"{e.msg}"))
         (setv l2 (extract_codeline_with_neighbours code lineN1 lineN2))
         (sconcat l1 "\n" l2))

    (defn #^ str
        str_prepare_DeconstructorError
        [ #^ WyCode        code
          #^ WyParserError e
        ]
        ;
        (setv lineN1 (second e.ndline1.rowN))
        (setv lineN2 (third  e.ndline2.rowN))
        (if (eq lineN1 lineN2)
            (setv lineNstr f"line {lineN1}")
            (setv lineNstr f"lines {lineN1}-{lineN2}"))
        ;
        (setv l1 (sconcat (clrz_r f"Indent error at {lineNstr}: ") f"{e.msg}"))
        (setv l2 (extract_codeline_with_neighbours code lineN1 lineN2))
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

    (defn [] #^ (of Result HyCode PrettyTEMsg)
        run_wy2hy_transpilation
        [ #^ WyCode code
          #^ bool   [silent True]
        ]
        "Returns result monad.
         On success places transpiled HyCode in monad,
         on failure places prettified error msg in monad;
         ;
         Never raises (catches ALL errors)
         ;
         silent=True - immediately prints found error msg (prettified)
        "
        (try (setv _trnsplR (Success (transpile_wy2hy code)))
             (except [e [ WyParserError
                          WyParserError2
                          WyExpanderError
                          WyDeconstructorError
                          WyBracketerError]]
                     (setv _trnsplR (Failure (prettify_WyError code e))))
             (except [e Exception]
                     (setv _trnsplR (Failure (PrettyTEMsg f"Unexpected error:\n{e}")))))
        ;
        (when (and (not silent) (failureQ _trnsplR))
              (print :file sys.stderr (-> _trnsplR unwrapE (getattrm .msg))))
        (return _trnsplR))

; _____________________________________________________________________________/ }}}1


