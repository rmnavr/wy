
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

    (setv LPAR      (| (pp.Literal "(") (pp.Literal "#(")))
    (setv RPAR      (pp.Literal ")"))
    (setv LCRB      (| (pp.Literal (py "'{'")) (pp.Literal (py "'#{'"))))
    (setv RBRCKT    (pp.Literal "]"))
    (setv LBRCKT    (pp.Literal "["))
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
    (setv SKY_MARKER   (| #* (lmap pp.Literal $SKY_MARKERS)))
    (setv HYMACRO_MARK (| #* (lmap pp.Literal ["~@" "~" "'" "`"])))
    (setv UNPACKER     (| (pp.Literal "#**") (pp.Literal "#*")))
    (setv WORD         (| (pp.Word (+ ALPHAS WSYMBOLS) (+ ALPHAS NUMS WSYMBOLS ":"))))
    (setv KEYWORD      (pp.Combine (+ ":" WORD)))
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
                           SKY_MARKER
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

    (defn #^ str
        replace_indentmarks_if_qstrings
        [#^ str elem]
        "if is NOT a qstring, return same"
        (if (and (>= (len elem) 3)
                 (= (first elem) "\"")
                 (= (last  elem) "\""))
            (->> elem (re.sub (+ r"" $BASE_INDENT r"(" $INDENT_MARK "*)") (fm (%1.group 1)))    ; remove 4 artificial indent-marks from the start
                      (re.sub (+ r"" $INDENT_MARK) " "))        ; replace remaining with spaces
            elem))

; _____________________________________________________________________________/ }}}1
; pyparse run ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of List Token)
        run_pyparse
        [ #^ FullCode code
        ]
        (setv result (-> code CONTENT.scanString
                              list           ; generator to list
                              flatten
                              (cut None -2)  ; remove column info
                              ))
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
        [ #^ FullCode code
        ]
        (-> code run_pyparse
                 split_parsed_to_tlines))

; _____________________________________________________________________________/ }}}1

    ; Part 2: TokenizedLine -> DeconstructedLine

; TMP: COPYPASTE helper checks if token is bracket ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; inserts extra spaces when needed, and inserts nothing when not needed

    (defn #^ bool
        is_opening_bracket
        [ #^ Token token
        ]
        (when (zeroQ (len token)) (return False))   ; just in case emtpy token "" slips in (but it shouldn't)
        (if (or (= (last token) "(")
                (= (last token) "[")
                (= (last token) (py "'{'")))
            True
            False))

    (defn #^ bool
        is_closing_bracket
        [ #^ Token token
        ]
        (when (zeroQ (len token)) (return False))   ; just in case emtpy token "" slips in (but it shouldn't)
        (if (or (= (first token) ")")
                (= (first token) "]")
                (= (first token) (py "'}'")))
            True
            False))

    (defn #^ bool
        is_bracket
        [ #^ Token token
        ]
        (when (zeroQ (len token)) (return False))   ; just in case emtpy token "" slips in (but it shouldn't)
        (if (or (is_opening_bracket token)
                (is_closing_bracket token))
            True
            False))

; _____________________________________________________________________________/ }}}1

; token type testers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ bool
        regarded_as_continuatorQ
        [ #^ Token token
        ]
        (or (digitQ             token)   
            (qstringQ           token)
            (annotation_markerQ token)
            (unpacker_markerQ   token)
            (is_bracket         token))) 

    (defn #^ bool
        linestarter_markerQ
        [ #^ Token token
        ]
        (if (in token $MARKERS) True False))

    (defn #^ bool
        continuator_markerQ
        [ #^ Token token
        ]
        (if (in token $CONTINUATORS) True False))

    (defn #^ bool
        annotation_markerQ
        [ #^ Token token
        ]
        (= token "#^"))

    (defn #^ bool
        unpacker_markerQ
        [ #^ Token token
        ]
        (or (= token "#*")
            (= token "#**")))

    (defn #^ bool
        digitQ
        [ #^ Token token
        ]
        (re_test r"^\.?\d" token))

    (defn #^ bool
        ocommentQ
        [ #^ Token token
        ]
        "ocomment is Outer Comment starting with ; symbol"
        (re_test "^;" token))

    (defn #^ bool
        qstringQ
        [ #^ Token token
        ]
        (re_test "^[rbf]?\"" token))

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
                   (ocommentQ (second tline)))
              OnlyOCommentDL
              ;
              ; ["✠✠✠✠" "~@:"]
              (and (= (len tline) 2)
                   (linestarter_markerQ (second tline)))
              LinestarterDL
              ;
              ; ["✠✠✠✠" "\\" ...] 
              ; ["✠✠✠✠" "1" ...] 
              (and (>= (len tline) 2)
                   (or (continuator_markerQ (second tline))
                       (regarded_as_continuatorQ (second tline))))
              ContinuatorDL
              ; 
              True
              ImpliedOpenerDL))

; _____________________________________________________________________________/ }}}1
; DL constructors ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ bool
        construct_LinestarterDL
        [ #^ TokenizedLine tline
        ]
        (DeconstructedLine :kind_spec      (LinestarterDL :linestarter_token (second tline))
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
        (if (ocommentQ (last tline))
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
        (if (ocommentQ (last tline))
            (setv _bodyWithNoComment (cut tline 1 -1)
                  _comment           (last tline))
            (setv _bodyWithNoComment (cut tline 1 None)
                  _comment           None))
        (if (continuator_markerQ (second tline))
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
        (DeconstructedLine :kind_spec      (ContinuatorDL :continuator_token _ctoken)
                           :equiv_indent   _indent
                           :body_tokens    _bodyFinal
                           :ending_comment _comment))

; _____________________________________________________________________________/ }}}1
; tline to dline ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ DeconstructedLine
        tline_to_dline
        [ #^ TokenizedLine tline
        ]
        (case (decide_structural_kind tline)
              LinestarterDL   (construct_LinestarterDL   tline)
              ContinuatorDL   (construct_ContinuatorDL   tline)
              ImpliedOpenerDL (construct_ImpliedOpenerDL tline)
              OnlyOCommentDL  (construct_OnlyOCommentDL  tline)
              EmptyLineDL     (construct_EmptyLineDL     tline)))

; _____________________________________________________________________________/ }}}1

