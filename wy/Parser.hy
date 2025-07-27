
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import pyparsing :as pp)

    (import Classes *)

    (import  _fptk_local *)
    (require _fptk_local *)

; _____________________________________________________________________________/ }}}1

; 1) Atomize (atom is just str):
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

    (setv EXPR         (pp.originalTextFor (| QEXPR SEXPR CEXPR)))

    (setv CONTENT      (pp.Group (pp.ZeroOrMore (| EXPR ATOM))))
    (<<   SEXPR        (pp.Group (+ LPAR   CONTENT RPAR)))
    (<<   QEXPR        (pp.Group (+ LBRCKT CONTENT RBRCKT)))
    (<<   CEXPR        (pp.Group (+ LCRB   CONTENT RCRB)))

    (<<   ICOMMENT     (pp.Group (+ (pp.Literal "#_") (| EXPR ATOM))))
    (<<   ANNOTATION   (pp.Group (+ (pp.Literal "#^") (| EXPR ATOM))))

; _____________________________________________________________________________/ }}}1
; [step] run py parse               :: Prepared Code -> [Atom ...] ‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ (of List Any) ; "Any" is because pydantic can't process pp.ParseResults for some reason
        prepared_code_to_atoms
        [ #^ PreparedCode prepared_code
        ]
        (->> prepared_code
             CONTENT.scanString
             list
             (lmapm (get it 0)) ; remove column info
             flatten
             ))

             ; list                                ; generator to list
             ; (map (fm (cut_ %1 1 -3)) #_ here) ; remove column info
             ; flatten))

; _____________________________________________________________________________/ }}}1
; [step] remove garbage from atoms  :: Atom -> Atom ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ Atom
        remove_garbage_from_atom
        [#^ Atom atom]
        "de facto removes indent/newline marks from qstring and bracketed HyExprs, for other atoms returns themselves"
        (if (or (qstring_atomQ atom)
                (hyexpr_atomQ  atom))
            (->> atom
                 (re_sub $INDENT_MARK " ")
                 (re_sub $NEWLINE_MARK ""))
            atom))

; _____________________________________________________________________________/ }}}1

; 2) Tokenize (see in Classes.hy) and split into Numbered Lines Of Tokens:
; // atom2token is done by function from Classes.hy
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
        (lmulticut_by (fm (eq it.kind TKind.NewLine)) tokens))

    (defn [validateF] #^ StrictInt
        count_n_of_rows_that_tline_takes
        [#^ (of List Token) tokens]
        (->> tokens
             (lmapm (len (re.findall "\n" %1.atom)))
             sum
             (plus 1)))

; _____________________________________________________________________________/ }}}1

; 3) Assembly
; [assm] PreparedCode to NTLines ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ (of List NTLine)
        prepared_code_to_ntlines
        [ #^ PreparedCode prepared_code
        ]
        (->> prepared_code
             prepared_code_to_atoms
             (lmap remove_garbage_from_atom)
             (lmap atom_to_token)
             tokens_to_NTLines))    

; _____________________________________________________________________________/ }}}1

