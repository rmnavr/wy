
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import pyparsing :as pp)

    (import Classes *)

    (import sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))

    (require hyrule [of as-> -> ->> doto case branch unless lif do_n list_n ncut])
    (import  _hyextlink *)
    (require _hyextlink [f:: fm p> pluckm lns &+ &+> l> l>=] :readers [L])

; _____________________________________________________________________________/ }}}1

    ; Part 1: Tokenize

; atoms ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv ALPHAS    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
    (setv WSYMBOLS  (+ "_" "$.-=+&*<>!/|" "%^?"))  ; no: :#`'~@"\ ;,
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
                           INDENT))

    (setv EXPR         (| QEXPR SEXPR CEXPR))

    (setv CONTENT      (pp.Group (pp.ZeroOrMore (| EXPR ATOM))))
    (<<   QEXPR        (pp.Group (+ LBRCKT CONTENT RBRCKT)))
    (<<   SEXPR        (pp.Group (+ LPAR   CONTENT RPAR)))
    (<<   CEXPR        (pp.Group (+ LCRB   CONTENT RCRB)))

    (<<   ICOMMENT     (pp.Group (+ (pp.Literal "#_") CONTENT)))
    (<<   ANNOTATION   (pp.Group (+ (pp.Literal "#^") CONTENT)))

; _____________________________________________________________________________/ }}}1
; replace indent marks in qstrings ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; updates "text  \n✠✠✠✠   text" to "text  \n       text"

    (defn #^ Token
        replace_indentmarks_if_qstrings
        [#^ Token token]
        "if is NOT a qstring, return same"
        (if (and (>= (len token) 3)
                 (= (first token) "\"")
                 (= (last  token) "\""))
            (->> token (re.sub (+ r"" $BASE_INDENT r"(" $INDENT_MARK "*)") (fm (%1.group 1)))    ; remove 4 artificial indent-marks from the start
                       (re.sub (+ r"" $INDENT_MARK) " "))        ; replace remaining with spaces
            token))

; _____________________________________________________________________________/ }}}1
; pyparse run ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of List Token)
        run_pyparse
        [ #^ PreparedCodeFull code
        ]
        (setv result (->> code CONTENT.scanString
                               list                                 ; generator to list
                               (map (fm (cut %1 None -2)) #_ here) ; remove column info
                               flatten))
        (lmap (p> str
                  replace_indentmarks_if_qstrings)
              result))

; _____________________________________________________________________________/ }}}1

; split to tlines ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of List TokenizedLine)
        split_parsed_to_tlines
        [ #^ (of List Token) parsed
        ]
        (when (= parsed []) (return []))
        (setv tlines [])
        ;
        (for [&elem parsed]
            (if (re_test (sconcat "^" $INDENT_MARK) &elem)
                (tlines.append [&elem])
                (. (get tlines -1) (append &elem))))
        (return tlines))

; _____________________________________________________________________________/ }}}1
; assembly (to tlines) ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of List TokenizedLine)
        prepared_code_to_tlines
        [ #^ PreparedCodeFull code
        ]
        (-> code run_pyparse
                 split_parsed_to_tlines))

; _____________________________________________________________________________/ }}}1

    ; Part 2: TokenizedLine -> DeconstructedLine

; testers: is regarded as continuator ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ bool
        token_regarded_as_continuatorQ
        [ #^ Token token
        ]
        (or (digit_tokenQ        token)
            (qstring_tokenQ      token)
            (keyword_tokenQ      token)
            (annotation_tokenQ   token)
            (icomment_tokenQ     token)
            (unpacker_tokenQ     token)
            (hy_macromark_tokenQ token)
            (hy_bracket_tokenQ   token)))

    (defn #^ bool
        hy_bracket_tokenQ
        [ #^ Token token
        ]
        (or (hy_opener_tokenQ       token)
            (closing_bracket_tokenQ token)))

    (defn #^ bool
        hy_opener_tokenQ
        [ #^ Token token
        ]
        (in token $HY_OPENERS))

    (defn #^ bool
        closing_bracket_tokenQ
        [ #^ Token token
        ]
        (in token $CLOSER_BRACKETS))

    (defn #^ bool
        hy_macromark_tokenQ
        [ #^ Token token
        ]
        (in token $HY_MACROMARKS))

    (defn #^ bool
        annotation_tokenQ
        [ #^ Token token
        ]
        (= token "#^"))

    (defn #^ bool
        icomment_tokenQ
        [ #^ Token token
        ]
        (= token "#_"))

    (defn #^ bool
        unpacker_tokenQ
        [ #^ Token token
        ]
        (in token ["#*" "#**"]))

    (defn #^ bool
        digit_tokenQ
        [ #^ Token token
        ]
        (re_test r"^\.?\d" token))

    (defn #^ bool
        ocomment_tokenQ
        [ #^ Token token
        ]
        "ocomment is Outer Comment starting with ; symbol"
        (re_test "^;" token))

    (defn #^ bool
        qstring_tokenQ
        [ #^ Token token
        ]
        (re_test "^[rbf]?\"" token))

    (defn #^ bool
        keyword_tokenQ
        [ #^ Token token
        ]
        (re_test r":\w+" token))

; _____________________________________________________________________________/ }}}1
; testers: wy token type ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ bool
        omarker_tokenQ
        [ #^ Token token
        ]
        (in token $OMARKERS))

    (defn #^ bool
        cmarker_tokenQ
        [ #^ Token token
        ]
        (in token $CMARKERS))

; _____________________________________________________________________________/ }}}1

; structural kind testers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ type
        decide_structural_kind
        [ #^ TokenizedLine tline
        ]
        (cond ; ["✠✠✠✠"]
              (= (len tline) 1)
              EmptyLineDL
              ;
              ; ["✠✠✠✠" "; text"]
              (and (= (len tline) 2)
                   (ocomment_tokenQ (second tline)))
              OnlyOCommentDL
              ;
              ; ["✠✠✠✠" "~@:"]
              (and (= (len tline) 2)
                   (omarker_tokenQ (second tline)))
              GroupStarterDL
              ;
              ; ["✠✠✠✠" "~@:" "smth"] ; <- can only come from source lines like «: : func»
              (and (>= (len tline) 3)
                   (omarker_tokenQ (second tline)))
              ContinuatorDL
              ;
              ; ["✠✠✠✠" "\\" ...]
              ; ["✠✠✠✠" "1" ...]
              (and (>= (len tline) 2)
                   (or (cmarker_tokenQ (second tline))
                       (token_regarded_as_continuatorQ (second tline))))
              ContinuatorDL
              ;
              True
              ImpliedOpenerDL))

; _____________________________________________________________________________/ }}}1
; DL constructors ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ bool
        construct_GroupStarterDL
        [ #^ TokenizedLine tline
        ]
        (DeconstructedLine :kind_spec      (GroupStarterDL :smarker (second tline))
                           :equiv_indent   (- (len (first tline)) $ELIN)
                           :body_tokens    []
                           :ending_comment None))

    (defn #^ bool
        construct_EmptyLineDL
        [ #^ TokenizedLine tline
        ]
        (DeconstructedLine :kind_spec      (EmptyLineDL)
                           :equiv_indent   (len $BASE_INDENT)
                           :body_tokens    []
                           :ending_comment None))

    (defn #^ bool
        construct_OnlyOCommentDL
        [ #^ TokenizedLine tline
        ]
        (DeconstructedLine :kind_spec      (OnlyOCommentDL)
                           :equiv_indent   (- (len (first tline)) $ELIN)
                           :body_tokens    []
                           :ending_comment (second tline)))

    (defn #^ bool
        construct_ImpliedOpenerDL
        [ #^ TokenizedLine tline
        ]
        (if (ocomment_tokenQ (last tline))
            (setv _body    (cut tline 1 -1)
                  _comment (last tline))
            (setv _body    (cut tline 1 None)
                  _comment None))
        (DeconstructedLine :kind_spec      (ImpliedOpenerDL)
                           :equiv_indent   (- (len (first tline)) $ELIN)
                           :body_tokens    _body
                           :ending_comment _comment))

    (defn #^ bool
        construct_ContinuatorDL
        [ #^ TokenizedLine tline
        ]
        (if (ocomment_tokenQ (last tline))
            (setv _bodyWithNoComment (cut tline 1 -1)
                  _comment           (last tline))
            (setv _bodyWithNoComment (cut tline 1 None)
                  _comment           None))
        (if (cmarker_tokenQ (second tline))
            ; if true -> we have continuation marker
            (setv _ctoken    (second tline)
                  _indent    (+ (len (first tline))
                                (neg $ELIN)
                                (if (= "\\" (second tline)) 1 0))
                  _bodyFinal (cut _bodyWithNoComment 1 None))
            ; if false -> we have «regarded as continuator» token
            (setv _ctoken    None
                  _bodyFinal _bodyWithNoComment
                  _indent    (- (len (first tline)) $ELIN)))
        (DeconstructedLine :kind_spec      (ContinuatorDL :cmarker _ctoken)
                           :equiv_indent   _indent
                           :body_tokens    _bodyFinal
                           :ending_comment _comment))

; _____________________________________________________________________________/ }}}1
; -> tline to dline ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ DeconstructedLine
        tline_to_dline
        [ #^ TokenizedLine tline
        ]
        (case (decide_structural_kind tline)
              GroupStarterDL  (construct_GroupStarterDL  tline)
              ContinuatorDL   (construct_ContinuatorDL   tline)
              ImpliedOpenerDL (construct_ImpliedOpenerDL tline)
              OnlyOCommentDL  (construct_OnlyOCommentDL  tline)
              EmptyLineDL     (construct_EmptyLineDL     tline)))

; _____________________________________________________________________________/ }}}1

