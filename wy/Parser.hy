
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import pyparsing :as pp)

    (import Classes *)

    (import  _fptk_local *)
    (require _fptk_local *)

; _____________________________________________________________________________/ }}}1

    ; 1) Atomize:
; pp atoms ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv ALPHAS    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
    (setv WSYMBOLS  (+ "_" "$.-=+&*<>!/|" "%^?"))  ; excluded :#`'~@"\;,
    (setv NUMS      "0123456789")

    (setv LPAR      (| #* (lmap pp.Literal $HY_OPENERS1)))
    (setv RPAR      (pp.Literal ")"))

    (setv LBRCKT    (| #* (lmap pp.Literal $HY_OPENERS2)))
    (setv RBRCKT    (pp.Literal "]"))

    (setv LCRB      (| #* (lmap pp.Literal $HY_OPENERS3)))
    (setv RCRB      (pp.Literal "}"))

    ; =========================================================

    (setv NUMBER (| (pp.Combine (+ (pp.Optional "-")
                                   (pp.Word NUMS)
                                   (pp.Optional ".")
                                   (pp.Optional (pp.Word NUMS))
                                   (pp.Optional (+ (pp.oneOf "e E")
                                                   (pp.Optional (pp.oneOf "- +"))
                                                   (pp.Word NUMS)))))
                    (pp.Combine (+ (pp.Word ".") (pp.Word NUMS)))))

    (setv INDENT       (pp.Word $INDENT_MARK))
    (setv NEW_LINE     (pp.Literal $NEWLINE_MARK))
    (setv WY_MARKER    (| #* (lmap pp.Literal $WY_MARKERS)))
    (setv HYMACRO_MARK (| #* (lmap pp.Literal $HY_MACROMARKS)))
    (setv UNPACKER     (| (pp.Literal "#**") (pp.Literal "#*")))
    (setv WORD         (pp.Word (+ ALPHAS WSYMBOLS) (+ ALPHAS NUMS WSYMBOLS ":")))
    (setv KEYWORD      (pp.Combine (+ ":" (pp.Word (+ ALPHAS "_") (+ ALPHAS "_" NUMS)))))
    (setv QSTRING      (pp.Combine (+  (pp.Optional (pp.oneOf "r f b"))
                                       (pp.QuotedString   :quoteChar "\""
                                                          :escChar "\\"
                                                          :multiline True
                                                          :unquoteResults False))))
    (setv OCOMMENT     (pp.Combine (+  (pp.Literal ";")
                                       (pp.SkipTo (pp.lineEnd)))))


    ; ==========================
    ; ATOM    = words and similar
    ; EXPR    = bracketed
    ; CONTENT = 0+ words or bracketed

    (setv ICOMMENT     (pp.Forward))
    (setv ANNOTATION   (pp.Forward))
    (setv QEXPR        (pp.Forward))           ; [ ... ]
    (setv SEXPR        (pp.Forward))           ; ( ... ) #( ... )
    (setv CEXPR        (pp.Forward))           ; { ... } #{ ... }

    (setv ATOM         (|  OCOMMENT
                           ICOMMENT
                           ANNOTATION
                           QSTRING
                           KEYWORD
                           WORD
                           UNPACKER
                           WY_MARKER
                           HYMACRO_MARK
                           NUMBER
                           NEW_LINE
                           INDENT))

    (setv EXPR         (| QEXPR SEXPR CEXPR))

    (setv CONTENT      (pp.Group (pp.ZeroOrMore (| EXPR ATOM))))
    (<<   QEXPR        (pp.Group (+ LBRCKT CONTENT RBRCKT)))
    (<<   SEXPR        (pp.Group (+ LPAR   CONTENT RPAR)))
    (<<   CEXPR        (pp.Group (+ LCRB   CONTENT RCRB)))

    (<<   ICOMMENT     (pp.Group (+ (pp.Literal "#_") (| EXPR ATOM))))
    (<<   ANNOTATION   (pp.Group (+ (pp.Literal "#^") (| EXPR ATOM))))

; _____________________________________________________________________________/ }}}1
; [step] run py parse               :: Prepared Code -> [Atom ...] ‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ (of List Atom)
        prepared_code_to_atoms
        [ #^ PreparedCode prepared_code
        ]
        (->> prepared_code
             CONTENT.scanString
             list                                ; generator to list
             (map (fm (cut %1 None -2)) #_ here) ; remove column info
             flatten))

; _____________________________________________________________________________/ }}}1
; [step] remove garbage from atoms  :: Atom -> Atom ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ Atom
        remove_garbage_from_atom
        [#^ Atom atom]
        "de facto removes indent/newline marks from qstring, for other atoms returns themselves"
        (if (qstring_atomQ atom)
            (->> atom
                 (re_sub $INDENT_MARK " ")
                 (re_sub $NEWLINE_MARK ""))
            atom))

; _____________________________________________________________________________/ }}}1

    ; 2) Tokenize (see in Classes.hy) and split into Numbered Lines Of Tokens:
; [step] all tokens to NTLines      :: [Token ...] -> [NTLine ...] ‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ (of List NTLine)
        tokens_to_NTLines
        [ #^ (of List Token) tokens
        ]
        (setv _tlines (split_tokens_by_newline_tokens tokens))
        (setv rowNs      (range_ 1 (len _tlines)))
        (setv rowsHs     (lmap count_n_of_rows_that_tline_takes _tlines))
        (setv rowsEnds   (funcy.lsums rowsHs))
        (setv rowsStarts (lmapm (- %1 %2 -1) rowsEnds rowsHs))
        ;
        (lmapm (NTLine :tokens         %1
                       :rowN           %2
                       :realRowN_start %3
                       :realRowN_end   %4) 
               _tlines
               rowNs
               rowsStarts
               rowsEnds))

    (defn [validateF] #^ (of List (of List Token))
        split_tokens_by_newline_tokens
        [ #^ (of List Token) tokens
        ]
        "newline tokens themselves are removed"
        (when (= tokens []) (return []))
        (setv _tlines [])
        ;
        (for [&token tokens]
            (if (eq &token.kind TKind.NewLine)
                (_tlines.append [])
                (. (last _tlines) (append &token))))
        (return _tlines))

    (defn [validateF] #^ StrictInt
        count_n_of_rows_that_tline_takes
        [#^ (of List Token) tokens]
        (->> tokens
             (lmapm (len (re.findall "\n" %1.atom)))
             sum
             (plus 1)))

; _____________________________________________________________________________/ }}}1

; indents count ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; ""  -> []
    ;
    ;  ↓
    ; "x" -> [1]
    ;
    ;  ₁↓
    ; " x" -> [2]
    ;
    ;  ₁↓₃
    ; "\ x"-> [2]
    ;
    ;  ₁↓₃₄↓₆₇₈↓₀₁₂₃₄₅₆↓
    ; " L  #:  ~@#:   \ : x" -> [2 5 9 17]

    (defn [validateF] #^ (of List Token)
        count_indents_for_ntline [#^ NTLine ntline]
        ;
        (setv _indentable_tokens [])
        (for [&token ntline.tokens]
            (cond (eq &token.kind TKind.Indent)  (    += _indentable_tokens [&token])
                  (eq &token.kind TKind.OMarker) (    += _indentable_tokens [&token])
                  (eq &token.kind TKind.CMarker) (do (+= _indentable_tokens [&token]) (break))
                  True                           (break)))
        _indentable_tokens)

; _____________________________________________________________________________/ }}}1
; run ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import Preparator [prepare_code_for_pyparsing])

    (setv _code " L #: : ~@#:   : x\\ 3 4 $ 7\n : #: riba\n1 2 \"\n\n  : L 2\"\n: \\ L 3 \"riba\nbubr\"\"riba\nbubr\"\"riba\nbubr\"")
    ;(setv _code " L  #:  ~@#:   \\ 1")
    (setv _prepared_code (prepare_code_for_pyparsing _code))

    (setv _x
        (->> _prepared_code
             prepared_code_to_atoms
             (lmap remove_garbage_from_atom)
             (lmap atom_to_token)
             tokens_to_NTLines))

    (lprint _x)

; _____________________________________________________________________________/ }}}1

