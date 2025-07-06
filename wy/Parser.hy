
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import pyparsing :as pp)

    (import wy.Classes *)

    (import sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))

    (import  fptk *)
    (require fptk *)

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
    (setv MIDSPACE     (pp.Word $MIDSPACE_MARK))
    (setv WY_MARKER    (| #* (lmap pp.Literal $WY_MARKERS)))    ; <- OMarkers DMarkers CMarker AMarker JMarker
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
                           INDENT
                           MIDSPACE))

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
; raw pyparse run ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of List Token)
        run_pyparse
        [ #^ PreparedCodeFull code
        ]
        (->> code CONTENT.scanString
                  list                                ; generator to list
                  (map (fm (cut %1 None -2)) #_ here) ; remove column info
                  flatten))

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
; assembly to ntlines ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of List TokenizedLine)
        prepared_code_to_ntlines_in_condensed_grammar
        [ #^ PreparedCodeFull code
        ]
        (setv tlines (->> code run_pyparse
                               (lmap replace_indentmarks_if_qstrings)
                               split_parsed_to_tlines))
        (lmap (fm (NumberedTLine :origRow %1 :tline %2))
              (range 0 (len tlines))
              tlines))

; _____________________________________________________________________________/ }}}1

; apl utils ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of List list)
        split_at_elem
        [ #^ Any elem
          #^ list container
        ]
        (->> container
             (funcy.partition_by (partial eq elem))
             (lmap list)
             (lfilter (partial neq [elem]))))

; _____________________________________________________________________________/ }}}1
; process jmarkers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of List NumberedTLine)
        process_jmarkers
        [ #^ NumberedTLine ntline
        ]
        (setv _orig_tline ntline.tline)
        (setv _indent (first ntline.tline))
        (when (= (second _orig_tline) $CMARKER) (+= _indent $INDENT_MARK))
        ;
        (setv _new_tlines (split_at_elem $JMARKER _orig_tline))
        (for [&tl (rest _new_tlines)]
             (setv cur_indent (if (= (first &tl) $CMARKER) (cut _indent 1 None) _indent))
             (&tl.insert 0 cur_indent))
        ;
        (lmap (fm (NumberedTLine :origRow ntline.origRow :tline %1)) _new_tlines))

; _____________________________________________________________________________/ }}}1
; process amarkers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; ✠✠✠~@:■■func
    ; ✠✠✠~@:■■\func
    ; ✠✠✠func
    ; ✠✠✠\func

    (defn #^ (of List NumberedTLine)
        process_amarkers
        [ #^ NumberedTLine ntline
        ]
        (setv _orig_tline ntline.tline)
        ;
        (setv nMarkers (count_occurrences $AMARKER _orig_tline))
        (cond (or (=  nMarkers 0)
                  (<= (len _orig_tline) 2)) ; true for eather empty line or group-starter
              (return [ntline])
              (>= nMarkers 2) (raise (Exception f"Line {ntline.origRow} has too many AMarkers")))
        ;
        (setv _indent (first _orig_tline)) 
        (if (in (second _orig_tline) $OMARKERS) 
            (do (+= _indent (* $INDENT_MARK (len (second _orig_tline))))
                (when (re_test (sconcat "^" $MIDSPACE_MARK) (third _orig_tline))
                      (+= _indent (* $INDENT_MARK (len (third _orig_tline)))))
                (when (or (= (third _orig_tline)  $CMARKER)
                          (= (fourth _orig_tline) $CMARKER))
                      (+= _indent $INDENT_MARK)))
            (+= _indent (* $INDENT_MARK 4))) 
        (when (= (second _orig_tline) $CMARKER)
              (+= _indent $INDENT_MARK))
        ;
        (setv [_new_tline1 _new_tline2] (split_at_elem $AMARKER _orig_tline))
        (when (= (first _new_tline2) $CMARKER)
              (setv _indent (cut _indent 1 None)))
        ; 
        [ (NumberedTLine :origRow ntline.origRow
                         :tline   _new_tline1)
          (NumberedTLine :origRow ntline.origRow
                         :tline   (lconcat [_indent] _new_tline2)) ])

; _____________________________________________________________________________/ }}}1
; process smarkers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; ✠✠✠~@:■■func
    ; ✠✠✠~@:■■\func

    ; ✠✠✠✠✠✠✠✠:\pups
    ; ✠✠✠✠✠✠✠✠✠\pups

    (defn #^ (of List NumberedTLine)
        process_smarkers
        [ #^ NumberedTLine ntline
        ]
        (setv _orig_tline ntline.tline)
        ;
        (setv nMarkers (count_occurrences $AMARKER _orig_tline))
        (when (or (not (in (second _orig_tline) $OMARKERS))
                  (<= (len _orig_tline) 2))
              (return [ntline]))
        ;
        (setv _indent (first _orig_tline)) 
        (+= _indent (* $INDENT_MARK (len (second _orig_tline))))
        (setv _third_is_msmark (re_test (sconcat "^" $MIDSPACE_MARK) (third _orig_tline)))
        (when _third_is_msmark
              (+= _indent (* $INDENT_MARK (len (third _orig_tline)))))
        ;
        (if _third_is_msmark 
            (setv [_new_tline1 _new_tline2] [(cut _orig_tline 0 2) (cut _orig_tline 3 None)])
            (setv [_new_tline1 _new_tline2] [(cut _orig_tline 0 2) (cut _orig_tline 2 None)]))
        ; 
        [ (NumberedTLine :origRow ntline.origRow
                         :tline   _new_tline1)
          (NumberedTLine :origRow ntline.origRow
                         :tline   (lconcat [_indent] _new_tline2)) ])

; _____________________________________________________________________________/ }}}1
; assembly ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of List NumberedTLine)
        ntlines_to_extended_grammar
        [ #^ (of List NumberedTLine) ntlines
        ]
        (setv stage_j (lconcat #* (lmap process_jmarkers ntlines)))
        (setv stage_a (lconcat #* (lmap process_amarkers stage_j)))
        (setv stage_s (lconcat #* (lmap process_smarkers stage_a)))
        stage_s)

; _____________________________________________________________________________/ }}}1

; assembly to tlines ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of Tuple (of List TokenizedLine) (of List int))
        prepared_code_to_tlines_and_positions
        [ #^ PreparedCodeFull code
        ]
        (setv _ntlines (->> code prepared_code_to_ntlines_in_condensed_grammar
                                ntlines_to_extended_grammar))
        (setv tlines    (pluckm .tline   _ntlines))
        (setv positions (pluckm .origRow _ntlines))
        (return [tlines positions]))

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
        (= token $CMARKER))

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

