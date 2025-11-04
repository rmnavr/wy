
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import pyparsing :as pp)
    (import re)

    (import  wy.Backend.Classes *)

    (import  wy.utils.fptk_local *)
    (require wy.utils.fptk_local *)

; _____________________________________________________________________________/ }}}1

; Pyparsing grammar setup:
; pp-entities ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv ALPHAS    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
    (setv WSYMBOLS  (+ "_" "$.-=+&*<>!/|" "%^?" ":#" "`'~@,"))  ; excluded: "\;()[]{}
    (setv NUMS      "0123456789")

    ; =========================================================

    (setv INDENT   (pp.Word $INDENT_MARK))
    (setv NEW_LINE (pp.Literal $NEWLINE_MARK))
    (setv CMARKER  (pp.Literal $CMARKER))
    (setv SEMIWORD (pp.Word (+ ALPHAS WSYMBOLS NUMS))) ; bundle of ASCII chars

    (setv QSTRING  (pp.Combine (+  (pp.Optional (pp.oneOf "r f b"))
                                   (pp.QuotedString   :quoteChar "\""
                                                      :escChar "\\"
                                                      :multiline True
                                                      :unquoteResults False))))

    (setv OCOMMENT (pp.Combine (+  (pp.Literal ";")
                                     (pp.SkipTo (pp.lineEnd)))))

    ; =========================================================
    ; parsing is done on CONTENT

    (setv ATOM    (| OCOMMENT QSTRING CMARKER SEMIWORD NEW_LINE INDENT))

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
                  (re_sub $NEWLINE_MARK ""))) ; "\n☇¦■smth" -> "\n smth"

    (.setParseAction HYEXPR   (fm (Token (cleanse_multiline (get it 1)) PKind.HYEXPR       TKind.RACont   ))) 
    (.setParseAction QSTRING  (fm (Token (cleanse_multiline (get it 0)) PKind.QSTRING      TKind.RACont   )))
    (.setParseAction OCOMMENT (fm (Token (get it 0)                     PKind.OCOMMENT     TKind.OComment )))
    (.setParseAction INDENT   (fm (Token (get it 0)                     PKind.INDENT       TKind.Indent   )))
    (.setParseAction NEW_LINE (fn [it] t_newline))
    (.setParseAction CMARKER  (fn [it] t_cmarker))

    (.setParseAction SEMIWORD (fm (semiword_to_token (get it 0))))

    (.setParseAction ORPHANB  (fm (raise (WyParserError #* (pick [0 2 1] it) "Orphan opener hy-bracket found"))))

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
        (setv rowsEnds   (lsums rowsHs))
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

