
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import pyparsing :as pp)

    (import wy.Classes *)

    (import  wy._fptk_local *)
    (require wy._fptk_local *)

; _____________________________________________________________________________/ }}}1

; Pyparsing grammar setup:
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
                    (pp.Combine (+ (pp.Optional (pp.oneOf "- +"))
                                   (pp.Word ".")
                                   (pp.Word NUMS NUMS_)
                                   (pp.Optional (+ (pp.oneOf "e E")
                                                   (pp.Optional (pp.oneOf "- +"))
                                                   (pp.Word NUMS NUMS_)))))))

    (setv WORD         (| (pp.Word (+ ALPHAS WSYMBOLS) (+ ALPHAS NUMS WSYMBOLS ":"))))
    (setv CHEAT_WORD   (pp.Combine (+ "$" WORD))) ; [QUICK_SOLUTION] solves case where «$PUPS» is seen as AMARKER+WORD instead of just WORD 

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
                      KEYWORD NUMBER DMARKER OMARKER CHEAT_WORD AMARKER RMARKER
                      JMARKER WORD SUGAR CMARKER 
                      HYMACRO_MARK RMACRO
                      NEW_LINE INDENT))

    (setv QEXPR   (pp.Forward))           ; [ ... ]
    (setv SEXPR   (pp.Forward))           ; ( ... ) #( ... )
    (setv CEXPR   (pp.Forward))           ; { ... } #{ ... }

    (setv HYEXPR  (pp.originalTextFor (| QEXPR SEXPR CEXPR))) ; origText will force it to be parsed as [14, '()', 16]

    (setv LPAR    (| #* (lmap pp.Literal $HY_OPENERS1)))
    (setv LBRCKT  (| #* (lmap pp.Literal $HY_OPENERS2)))
    (setv LCRB    (| #* (lmap pp.Literal $HY_OPENERS3)))
    (setv RPAR    (pp.Literal ")"))
    (setv RBRCKT  (pp.Literal "]"))
    (setv RCRB    (pp.Literal "}"))
    (setv ORPHANB (pp.originalTextFor (| LPAR LBRCKT LCRB))) ; origText will force it to be parsed as [3, '#(', 4]

    (setv CONTENT (pp.Group (pp.ZeroOrMore (| HYEXPR ORPHANB ATOM))))

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
                  (re_sub $NEWLINE_MARK ""))) ; "\n☇¦smth" -> "\nsmth"

    (.setParseAction HYEXPR       (fm (Token (cleanse_multiline (get it 1)) PKind.HYEXPR       TKind.RACont   ))) 
    (.setParseAction QSTRING      (fm (Token (cleanse_multiline (get it 0)) PKind.QSTRING      TKind.RACont   )))
    (.setParseAction HYMACRO_MARK (fm (Token (get it 0)                     PKind.HYMACRO_MARK TKind.RACont   )))
    (.setParseAction RMACRO       (fm (Token (get it 0)                     PKind.RMACRO       TKind.RACont   )))
    (.setParseAction OCOMMENT     (fm (Token (get it 0)                     PKind.OCOMMENT     TKind.OComment )))
    (.setParseAction KEYWORD      (fm (Token (get it 0)                     PKind.KEYWORD      TKind.RACont   )))
    (.setParseAction NUMBER       (fm (Token (get it 0)                     PKind.NUMBER       TKind.RACont   )))
    (.setParseAction WORD         (fm (Token (get it 0)                     PKind.WORD         TKind.RAOpener )))
    (.setParseAction CHEAT_WORD   (fm (Token (get it 0)                     PKind.WORD         TKind.RAOpener ))) ; [QUICK_SOLUTION] see above
    (.setParseAction SUGAR        (fm (Token (get it 0)                     PKind.SUGAR        TKind.RACont   )))
    (.setParseAction DMARKER      (fm (Token (get it 0)                     PKind.DMARKER      TKind.DMarker  )))
    (.setParseAction OMARKER      (fm (Token (get it 0)                     PKind.OMARKER      TKind.OMarker  )))
    (.setParseAction INDENT       (fm (Token (get it 0)                     PKind.INDENT       TKind.Indent   )))
    ; those tokens always have the same atom:
    (.setParseAction CMARKER      (fn [it] t_cmarker))
    (.setParseAction AMARKER      (fn [it] t_amarker))
    (.setParseAction RMARKER      (fn [it] t_rmarker))
    (.setParseAction JMARKER      (fn [it] t_jmarker))
    (.setParseAction NEW_LINE     (fn [it] t_newline))

    (.setParseAction ORPHANB (fm (raise (WyParserError #* (pick [0 2 1] it) "Orphan opener hy-bracket found"))))

; _____________________________________________________________________________/ }}}1

; [F] Parsing whole  :: PreparedCode -> [Token ...] ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ (of List Token)
        prepared_code_to_tokens
        [ #^ PreparedCode prepared_code
        ]
        (setv _list
            (-> prepared_code
                CONTENT.scanString
                list))
        (if (zerolenQ _list) 
            (return []) ; case for when no pp-entities are found (meaning empty string or similar was parsed)
            (return (list (get _list 0 0 0)))))

; _____________________________________________________________________________/ }}}1
; [F] Split to lines :: [Token ...] -> [NTLine ...] ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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
        (lmapm (NTLine :lineNs #(%2 %3 %4) :tokens %1)
               _tlines
               rowNs
               rowsStarts
               rowsEnds))

    (defn [validateF] #^ (of List (of List Token))
        split_tokens_by_newline_tokens
        [ #^ (of List Token) tokens
        ]
        "newline tokens themselves are removed"
        (lmulticut_by (fm (eq it.tkind TKind.NewLine))
                      tokens
                      :keep_border False
                      :merge_border False))

    (defn [validateF] #^ StrictInt
        count_n_of_rows_that_tline_takes
        [#^ (of List Token) tokens]
        (->> tokens
             (filterm (eq it.pkind PKind.QSTRING))
             (mapm (len (re.findall "\n" %1.atom)))
             sum
             (plus 1)))

; _____________________________________________________________________________/ }}}1

; [I] PreparedCode to NTLines ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ (of List NTLine)
        prepared_code_to_ntlines
        [ #^ PreparedCode prepared_code
        ]
        (->> prepared_code
             prepared_code_to_tokens
             tokens_to_NTLines))

; _____________________________________________________________________________/ }}}1

