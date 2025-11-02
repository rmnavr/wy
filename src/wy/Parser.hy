
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import pyparsing :as pp)

    (import wy.Classes *)

    (import  wy._fptk_local *)
    (require wy._fptk_local *)

; _____________________________________________________________________________/ }}}1

; 1) Atomize (atom is just str):
; pp-entities ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv ALPHAS    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
    (setv WSYMBOLS  (+ "_" "$.-=+&*<>!/|" "%^?"))  ; excluded :#`'~@"\;,
    (setv NUMS      "0123456789")
    (setv NUMS_     "0123456789_")

    ; =========================================================

    (setv INDENT       (pp.Word $INDENT_MARK))
    (setv NEW_LINE     (pp.Literal $NEWLINE_MARK))

    (setv OMARKER      (| #* (lmap pp.Literal $OMARKERS)))
    (setv DMARKER      (| #* (lmap pp.Literal $DMARKERS)))
    (setv CMARKER      (pp.Literal $CMARKER))
    (setv AMARKER      (pp.Literal $AMARKER))
    (setv RMARKER      (pp.Literal $RMARKER))
    (setv JMARKER      (pp.Literal $JMARKER))
    (setv HYMACRO_MARK (| #* (lmap pp.Literal $HY_MACROMARKS))) ; ' ` ~ ~@

    ; -1_200.1_000E+3_3 , -.1E3
    (setv NUMBER (| (pp.Combine (+ (pp.Optional (pp.oneOf "- +"))
                                   (pp.Word NUMS NUMS_)
                                   (pp.Optional ".")
                                   (pp.Optional (pp.Word NUMS NUMS_))
                                   (pp.Optional (+ (pp.oneOf "e E")
                                                   (pp.Optional (pp.oneOf "- +"))
                                                   (pp.Word NUMS NUMS_)))))
                    (pp.Combine (+ (pp.oneOf "- +")
                                   (pp.Word ".")
                                   (pp.Word NUMS NUMS_)
                                   (pp.Optional (+ (pp.oneOf "e E")
                                                   (pp.Optional (pp.oneOf "- +"))
                                                   (pp.Word NUMS NUMS_)))))))

    (setv WORD         (pp.Word (+ ALPHAS WSYMBOLS) (+ ALPHAS NUMS WSYMBOLS ":")))
    (setv RMACRO       (pp.Combine (+ "#" WORD)))
    (setv KEYWORD      (pp.Combine (+ ":" (pp.Word (+ ALPHAS "_") (+ ALPHAS "_" NUMS)))))
    (setv SUGAR        (| #* (lmap pp.Literal ["#**" "#*" "#_" "#^"])))
    (setv QSTRING      (pp.Combine (+  (pp.Optional (pp.oneOf "r f b"))
                                       (pp.QuotedString   :quoteChar "\""
                                                          :escChar "\\"
                                                          :multiline True
                                                          :unquoteResults False))))
    (setv OCOMMENT     (pp.Combine (+  (pp.Literal ";")
                                       (pp.SkipTo (pp.lineEnd)))))

    ; ==========================
    ; ATOM    = words and similar
    ; HYEXPR  = hy-bracketed expr
    ; CONTENT = 0+ ATOMs or HYEXPRs   <- this is on what parser runs

    (setv ATOM    (|  OCOMMENT QSTRING
                      KEYWORD NUMBER DMARKER OMARKER AMARKER RMARKER JMARKER
                      WORD SUGAR CMARKER 
                      HYMACRO_MARK RMACRO
                      NEW_LINE INDENT))

    (setv QEXPR   (pp.Forward))           ; [ ... ]
    (setv SEXPR   (pp.Forward))           ; ( ... ) #( ... )
    (setv CEXPR   (pp.Forward))           ; { ... } #{ ... }

    (setv HYEXPR  (pp.originalTextFor (| QEXPR SEXPR CEXPR)))
    (setv CONTENT (pp.Group (pp.ZeroOrMore (| HYEXPR ATOM))))

    (setv LPAR    (| #* (lmap pp.Literal $HY_OPENERS1)))
    (setv LBRCKT  (| #* (lmap pp.Literal $HY_OPENERS2)))
    (setv LCRB    (| #* (lmap pp.Literal $HY_OPENERS3)))
    (setv RPAR    (pp.Literal ")"))
    (setv RBRCKT  (pp.Literal "]"))
    (setv RCRB    (pp.Literal "}"))

    (<<   SEXPR   (pp.originalTextFor (pp.Group (+ LPAR   CONTENT RPAR))))
    (<<   QEXPR   (pp.originalTextFor (pp.Group (+ LBRCKT CONTENT RBRCKT))))
    (<<   CEXPR   (pp.originalTextFor (pp.Group (+ LCRB   CONTENT RCRB))))

; _____________________________________________________________________________/ }}}1
; add actions to pp-entities ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ StrictStr
        cleanse_multiline
        [#^ StrictStr text]
        "removes indent/newline marks"
        (->> text (re_sub $INDENT_MARK " ")
                  (re_sub $NEWLINE_MARK "")))

    (.setParseAction HYEXPR       (fm (PAtom PKind.HYEXPR       (cleanse_multiline (get it 1))))) ; [14, '()', 16]
    (.setParseAction QSTRING      (fm (PAtom PKind.QSTRING      (cleanse_multiline (get it 0)))))
    (.setParseAction OCOMMENT     (fm (PAtom PKind.OCOMMENT     (get it 0))))
    (.setParseAction KEYWORD      (fm (PAtom PKind.KEYWORD      (get it 0))))
    (.setParseAction NUMBER       (fm (PAtom PKind.NUMBER       (get it 0))))
    (.setParseAction WORD         (fm (PAtom PKind.WORD         (get it 0))))
    (.setParseAction SUGAR        (fm (PAtom PKind.SUGAR        (get it 0))))
    (.setParseAction OMARKER      (fm (PAtom PKind.OMARKER      (get it 0))))
    (.setParseAction DMARKER      (fm (PAtom PKind.DMARKER      (get it 0))))
    (.setParseAction CMARKER      (fm (PAtom PKind.CMARKER      (get it 0))))
    (.setParseAction AMARKER      (fm (PAtom PKind.AMARKER      (get it 0))))
    (.setParseAction RMARKER      (fm (PAtom PKind.RMARKER      (get it 0))))
    (.setParseAction JMARKER      (fm (PAtom PKind.JMARKER      (get it 0))))
    (.setParseAction HYMACRO_MARK (fm (PAtom PKind.HYMACRO_MARK (get it 0))))
    (.setParseAction RMACRO       (fm (PAtom PKind.RMACRO       (get it 0))))
    (.setParseAction NEW_LINE     (fm (PAtom PKind.NEW_LINE     (get it 0))))
    (.setParseAction INDENT       (fm (PAtom PKind.INDENT       (get it 0))))

; _____________________________________________________________________________/ }}}1

    (defn [validateF] #^ (of List PAtom)
        prepared_code_to_patoms
        [ #^ PreparedCode prepared_code
        ]
        (setv _list
            (-> prepared_code
                        CONTENT.scanString
                        list))
        (if (zerolenQ _list)
            (return [])
            (return (list (get _list 0 0 0)))))

    ; continue from: PAtoms (classify by parsed) to Tokens (classify by actions)?

; [step] run py parse               :: Prepared Code -> [Atom ...] ‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ (of List str)
        prepared_code_to_atoms
        [ #^ PreparedCode prepared_code
        ]
        (->> prepared_code
             CONTENT.scanString
             list
             (lmapm (get it 0)) ; remove column info
             flatten
             ))

; _____________________________________________________________________________/ }}}1
; [step] remove garbage from atoms  :: Atom -> Atom ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ Atom
        remove_garbage_from_atom
        [#^ Atom atom]
        "de facto removes indent/newline marks from qstring and bracketed HyExprs,
         for other atoms returns themselves"
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
        (lmulticut_by :keep_border False :merge_border False (fm (eq it.kind TKind.NewLine)) tokens))

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


