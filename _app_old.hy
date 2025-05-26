
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import pyparsing :as pp)

    (import Classes *)

    (import sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))

    (require hyrule [of as-> -> ->> doto case branch unless lif do_n list_n ncut])
    (import  _hyextlink *)
    (require _hyextlink [f:: fm p> pluckm lns &+ &+> l> l>=] :readers [L])

; _____________________________________________________________________________/ }}}1

; IO ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ str
        file_to_code #_ IO
        [#^ str file_name]
        (with [file (open file_name
                          "r"
                          :encoding "utf-8")]
              (setv outp (file.read)))
        (return outp))

; _____________________________________________________________________________/ }}}1
; [Dev doc] Stages Info ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; stage 1: PREPARE
    ; :: HyCode -> PreparedCode // with ✠ marks
    ;
    ; + rstrips every line
    ; + splits «   : pups» to 2 lines
    ; + adds indent marks to every line
    ; + add empty line at the end ( for PROCESSOR to be working at the end
    ;                               without extra cases)

    ; stage 2: DECONSTRUCT
    ; :: PreparedCode -> (of List DeconstructedLine)
    ;
    ; + supresses «;»-comments
    ; + replaces ✠-indents in qstrings

    ; stage 3: PROCESS DLines
    ; - inserts indent-induced brackets
    ; - removes \ symbol
    ;
    ; :: ProcessorCard -> (of List DeconstructedLine)  // ["✠✠" "setv" ...]
    ;                  => (of List ProcessedLine)      // ["✠✠" ")" "(" "setv" ...]

    ; stage 4: POSTPROCESSOR
    ; :: (of List ProcessedLine) -> HyCode
    ;
    ; - unpacks inline «:» and «::»
    ; - nicely place "(" and ")" on appropriate lines

; _____________________________________________________________________________/ }}}1

    ; stage 1: PREPARE
; prepare code for pyparsing ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ PreparedCode
        prepare_code_for_pyparsing
        [ #^ HyskyCode hcode
        ]
        (setv outp (->> hcode
                        .splitlines                     ;
                        (lmap (p> split_linestarters    ;
                                  rstrip))              ;
                        (str_join :sep "\n")            ;
                        .splitlines                     ;
                        (lmap add_indent)               ; very ineffective
                        (str_join :sep "\n")            ;
                        ))
        ; add empty line at the end
        (return (sconcat outp "\n" $EMPTY_LINE)))

    (defn #^ str
        rstrip
        [ #^ str string
        ]
        (return (string.rstrip))
        )

    (defn #^ HyskyCodeLine
        split_linestarters
        [ #^ HyskyCodeLine line
        ]
        (re.sub r"^(\s+):(\s+)"
                (fm (sconcat (%1.group 1) ":" "\n"
                    (%1.group 1) " " (%1.group 2)
                    ))
                line))

    (defn #^ HyskyCodeLine
        add_indent
        [ #^ HyskyCodeLine line
        ]
        (setv without_indent (line.lstrip))
        (setv indent_len (- (len line) (len without_indent)))
        (setv indent (* $INDENT_MARK indent_len))
        (sconcat $EMPTY_LINE indent without_indent)
        )

; _____________________________________________________________________________/ }}}1

    ; stage 2: DECONSTRUCT
; [pp] atoms ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv ALPHAS    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
    (setv WSYMBOLS  (+ "_" "$.-=+&*<>!/|" "%^?"))  ; no: `~@'":;\#
    (setv NUMS      "0123456789")

    (setv LPAR      (| (pp.Literal "(") (pp.Literal "#(")))
    (setv RPAR      (pp.Literal ")"))
    (setv LCRB      (| (pp.Literal (py "\"{\"")) (pp.Literal (py "\"#{\""))))
    (setv RBRCKT    (pp.Literal "]"))
    (setv LBRCKT    (pp.Literal "["))
    (setv RCRB      (pp.Literal "}"))

    ; =========================================================

    (setv INDENT     (pp.Word $INDENT_MARK))

    (setv NUMBER    (| (pp.Combine (+ (pp.Optional "-")
                                      (pp.Word NUMS)
                                      (pp.Optional ".")
                                      (pp.Optional (pp.Word NUMS))
                                      (pp.Optional (+ (pp.oneOf "e E")
                                                      (pp.Optional (pp.oneOf "- +"))
                                                      (pp.Word NUMS)))))
                       (pp.Combine (+ (pp.Word ".") (pp.Word NUMS)))))

    (setv SKY_BRKT1 (pp.Literal ":"))
    (setv SKY_BRKT2 (pp.Literal "::"))
    (setv SKY_CONT  (pp.Literal "\\"))
    (setv SKY_LIST  (pp.Literal "L"))
    (setv SKYMARK   (| SKY_BRKT2 SKY_BRKT1 SKY_CONT SKY_LIST))

    (setv WORD      (| (pp.Word (+ ALPHAS WSYMBOLS) (+ ALPHAS NUMS WSYMBOLS ":"))
                       (pp.Literal "#**")
                       (pp.Literal "#*")))

    (setv KEYWORD   (pp.Combine (+ ":" WORD)))

    (setv QSTRING   (pp.Combine (+  (pp.Optional (pp.oneOf "r f b"))
                                    (pp.QuotedString   :quoteChar "\""
                                                       :escChar "\\"
                                                       :multiline True
                                                       :unquoteResults False))))
    (setv OCOMMENT  (pp.Suppress (pp.Combine (+  (pp.Literal ";")
                                                 (pp.SkipTo (pp.lineEnd))))))

    (setv ICOMMENT   (pp.Forward))
    (setv ANNOTATION (pp.Forward))
    (setv QEXPR      (pp.Forward))           ; [ ... ]
    (setv SEXPR      (pp.Forward))           ; ( ... ) #( ... )
    (setv CEXPR      (pp.Forward))           ; { ... } #{ ... }

    ; ATOM    = words and similar
    ; EXPR    = bracketed
    ; CONTENT = 0+ words or bracketed

    (setv ATOM      (|  OCOMMENT
                        ICOMMENT
                        ANNOTATION
                        QSTRING
                        KEYWORD
                        WORD
                        SKYMARK
                        NUMBER
                        INDENT))

    (setv EXPR      (| QEXPR SEXPR CEXPR))

    (setv CONTENT   (pp.Group (pp.ZeroOrMore (| EXPR ATOM))))
    (<<   QEXPR     (pp.Group (+ LBRCKT CONTENT RBRCKT)))
    (<<   SEXPR     (pp.Group (+ LPAR CONTENT RPAR)))
    (<<   CEXPR     (pp.Group (+ LCRB CONTENT RCRB)))

    (<<   ICOMMENT   (pp.Group (+ (pp.Literal "#_") CONTENT)))
    (<<   ANNOTATION (pp.Group (+ (pp.Literal "#^") CONTENT)))

; _____________________________________________________________________________/ }}}1
; [pp] pyparse run ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of List DeconstructedLine)
        deconstruct_prepared_code
        [ #^ PreparedCode code
        ]
        (-> code run_pyparse
                 split_parsed_to_dlines))

    (defn #^ (of List str)
        run_pyparse
        [ #^ PreparedCode code
        ]
        (setv result (-> code CONTENT.scanString
                              list           ; generator to list
                              flatten
                              (cut None -2)  ; remove column info
                              ))
        (lmap (p> str replace_indents_in_qstrings)
              result))

    (defn #^ str
        replace_indents_in_qstrings
        [#^ str elem]
        (if (and (>= (len elem) 3)
                 (= (first elem) "\"")
                 (= (last  elem) "\""))
            (re.sub (+ r"" $INDENT_MARK) " " elem)
            elem))

    (defn #^ (of List DeconstructedLine)
        split_parsed_to_dlines
        [ #^ (of List str) parsed
        ]
        (when (= parsed []) (return []))
        (setv dlines [])
        ;
        (for [&elem parsed]
            (if (re_test (sconcat "^" $INDENT_MARK) &elem)
                (dlines.append [&elem])
                (. (get dlines -1) (append &elem))))
        (return dlines))

; _____________________________________________________________________________/ }}}1

    ; stage 3: PROCESS INDEN-INDUCED BRACKETS
; utils (work on dlines) ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ DLineKind
        get_dline_kind
        [ #^ DeconstructedLine dline
        ]
        (when (= (len dline) 1)
              (return DLineKind.EMPTY))
        (setv _elem (second dline))
        (cond (= ":" _elem)
              (return DLineKind.LINESTARTER)
              ;
              (re_test r"^\\" _elem)
              (return DLineKind.CONTINUATOR)
              True
              (return DLineKind.OPENER)))

    (defn #^ int
        get_indent
        [ #^ DeconstructedLine dline
        ]
        (len (first dline)))

    ; indent is symbols count, indent_level is index in list
    (defn #^ int
        get_indent_level
        [ #^ (of List int) indents      #_ "[4 8 20]"
          #^ int           cur_indent
        ]
        (for [&idx (range 0 (len indents))]
             (when (= cur_indent (get indents &idx))
                   (setv outp &idx)))
        (return outp))

    (defn #^ DeconstructedLine
        add_and_remove_markers
        [ #^ DeconstructedLine dline
          #^ int closers
          #^ int openers
          #^ bool [remove_continuation_mark False]
        ]
        (lconcat [(get dline 0)]
                 [(* ")" closers)]
                 [(* "(" openers)]
                 (if remove_continuation_mark
                     (cut dline 2 None)
                     (cut dline 1 None))))

; _____________________________________________________________________________/ }}}1
; process one dline ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of Tuple ProcessorCard ProcessedLine)
        process_single_dline
        [ #^ ProcessorCard     pcard
          #^ DeconstructedLine dline
        ]
        (setv dline_kind (get_dline_kind dline))
        (case dline_kind
              DLineKind.OPENER      (process_opener_dline pcard dline)
              DLineKind.EMPTY       (process_empty_dline pcard dline)
              DLineKind.CONTINUATOR (process_continuator_dline pcard dline)
              DLineKind.LINESTARTER (process_opener_dline pcard [(get dline 0)])))

    (defn #^ (of Tuple ProcessorCard DeconstructedLine)
        process_empty_dline
        [ #^ ProcessorCard     pcard
          #^ DeconstructedLine dline
        ]
        ;
        (return [ $CARD0
                  (add_and_remove_markers dline
                                          pcard.brkt_count
                                          0)]))

    (defn #^ (of Tuple ProcessorCard DeconstructedLine)
        process_opener_dline
        [ #^ ProcessorCard     pcard
          #^ DeconstructedLine dline
        ]
        (setv cur_indent   (get_indent dline))
        (setv prev_indents pcard.indents)
        (setv prev_indent  (last prev_indents))
        (setv prev_accum   pcard.brkt_count)
        (setv prev_kind    pcard.dline_kind)
        ;
        (setv _levels_to_open 1)
        (cond (> cur_indent prev_indent)
              (setv _levels_to_close 0
                    _new_indents     (lconcat prev_indents [cur_indent]))
              (= cur_indent prev_indent)
              (setv _levels_to_close (case prev_kind
                                           DLineKind.CONTINUATOR 0
                                           DLineKind.OPENER      1
                                           DLineKind.EMPTY       0)
                    _new_indents     prev_indents)
              (< cur_indent prev_indent)
              (setv _deltaIndents    (- (dec (len prev_indents))
                                        (get_indent_level prev_indents cur_indent))
                    _levels_to_close (+ _deltaIndents
                                        (if (= prev_kind DLineKind.CONTINUATOR) 0 1))
                    _new_indents     (list (drop_last _deltaIndents prev_indents))))
        ;(print dline f"| br:{_levels_to_close} inds:{_new_indents}")
        (return [ (ProcessorCard :indents    _new_indents
                                 :brkt_count (+ prev_accum
                                                _levels_to_open
                                                (neg _levels_to_close))
                                 :dline_kind DLineKind.OPENER)
                  (add_and_remove_markers dline
                                          _levels_to_close
                                          _levels_to_open)]))

    (defn #^ (of Tuple ProcessorCard DeconstructedLine)
        process_continuator_dline
        [ #^ ProcessorCard     pcard
          #^ DeconstructedLine dline
        ]
        (setv cur_indent   (get_indent dline))
        (setv prev_indents pcard.indents)
        (setv prev_indent  (last prev_indents))
        (setv prev_accum   pcard.brkt_count)
        (setv prev_kind    pcard.dline_kind)
        ;
        (setv prev_kind    pcard.dline_kind)
        (setv _levels_to_open 0)
        (cond (> cur_indent prev_indent)
              (setv _levels_to_close 0
                    _new_indents (lconcat prev_indents [cur_indent]))
              (= cur_indent prev_indent)
              (setv _levels_to_close (if (= prev_kind DLineKind.CONTINUATOR) 0 1)
                    _new_indents prev_indents)
              (< cur_indent prev_indent)
              (setv _deltaIndents    (- (dec (len prev_indents))
                                        (get_indent_level prev_indents cur_indent))
                    _levels_to_close (+ _deltaIndents
                                        (if (= prev_kind DLineKind.CONTINUATOR) 0 1))
                    _new_indents     (list (drop_last _deltaIndents prev_indents))))
        ;(print dline f"| br:{_levels_to_close} inds:{_new_indents}")
        (return [ (ProcessorCard :indents    _new_indents
                                 :brkt_count (+ prev_accum
                                                _levels_to_open
                                                (neg _levels_to_close))
                                 :dline_kind DLineKind.CONTINUATOR)
                  (add_and_remove_markers dline
                                          _levels_to_close
                                          _levels_to_open
                                          :remove_continuation_mark True)]))

; _____________________________________________________________________________/ }}}1
; full indents processor ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv $CARD0 (ProcessorCard :indents     [$ELN]
                                :brkt_count  0
                                :dline_kind  DLineKind.EMPTY))

    (defn #^ (of List ProcessedLine)
        process_dlines
        [ #^ ProcessorCard init_card
          #^ (of List DeconstructedLine) dlines
        ]
        (setv cur_card init_card)
        (setv _result (* ["blank"] (len dlines)))
        (for [[&idx &dl] (enumerate dlines)]
             (setv outp (process_single_dline cur_card &dl))
             (setv (get _result &idx) (second outp))
             (setv cur_card (first outp)))
        (return _result))

; _____________________________________________________________________________/ }}}1

    ; stage 4: POSTPROCESS
; postprocessor ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ HyCode
        assembly_plines
        [ #^ (of List ProcessedLine) plines
        ]
        (setv _with_newLines (lmap (p> postprocess_inline_openers
                                       prepare_pline_for_assembly)
                                   plines))
        (-> _with_newLines
            flatten
            (str_join :sep " ")))

    (defn #^ ProcessedLine
        postprocess_inline_openers
        [ #^ ProcessedLine pline
        ]
        (setv new_pline pline)
        (for [[&idx &elem] (enumerate new_pline)]
             (when (= &elem ":")
                   (assoc new_pline &idx "(")
                   (setv new_last_elem (sconcat (last new_pline) ")"))
                   (assoc new_pline -1 new_last_elem))
             (when (= &elem "::")
                   (assoc new_pline &idx ")(")))
        (return new_pline))

    (defn #^ ProcessedLine
        prepare_pline_for_assembly
        [ #^ ProcessedLine pline
        ]
        (setv _ident (* " " (- (len (nth 0 pline)) $ELN)))
        (setv _closers (nth 1 pline))
        (setv _openers (nth 2 pline))
        (setv _rest (cut pline 3 None))
        (lconcat [_closers] ["\n"] [_ident] [_openers] _rest))

; _____________________________________________________________________________/ }}}1

    ; assembly all:
; hysky to hy ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ HyCode
        hysky_to_hy
        [ #^ HyskyCode code
        ]
        (->> code prepare_code_for_pyparsing
                  deconstruct_prepared_code
                  (process_dlines $CARD0)
                  rest ; removes first always-empty line
                  assembly_plines))

; _____________________________________________________________________________/ }}}1

    (setv _hysky (-> "parser_docs\\_test.hy" file_to_code))
    (setv _hy (hysky_to_hy _hysky))
    (print _hy)



