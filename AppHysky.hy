
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

    (setv $INDENT_MARK  "✠")
    (setv $EMPTY_LINE   "✠✠✠✠")
    (setv $ELN          4)

; prepare code for parsing ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of List IndentMarkedLine)
        infiltrate_with_indent
        [ #^ HCode hcode
        ]
        (setv outp (->> hcode
                        .splitlines
                        (lmap split_linestarters)
                        (str_join :sep "\n")
                        .splitlines
                        (lmap add_indent)
                        (str_join :sep "\n")
                        ))
        ; also always add last empty line (to avoid special case for line processor)
        (return (sconcat outp $EMPTY_LINE)))


    (defn #^ str
        split_linestarters
        [ #^ HCodeLine code
        ]
        (re.sub r"^(\s+):(\s+)"
                (fm (sconcat (%1.group 1) ":" "\n"
                    (%1.group 1) " " (%1.group 2)
                    ))
                code))

    (defn #^ str
        add_indent
        [ #^ HCodeLine line
        ]
        (setv without_indent (line.lstrip))
        (setv indent_len (- (len line) (len without_indent)))
        (setv indent (* $INDENT_MARK indent_len))
        (sconcat $EMPTY_LINE indent without_indent) 
        )

; _____________________________________________________________________________/ }}}1
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
    (setv OCOMMENT  (pp.Combine (+  (pp.Literal ";")
                                    (pp.SkipTo (pp.lineEnd)))))

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
                        SKYMARK    
                        NUMBER     
                        WORD       
                        INDENT))

    (setv EXPR      (| QEXPR SEXPR CEXPR))

    (setv CONTENT   (pp.Group (pp.ZeroOrMore (| EXPR ATOM))))
    (<<   QEXPR     (pp.Group (+ LBRCKT CONTENT RBRCKT)))
    (<<   SEXPR     (pp.Group (+ LPAR CONTENT RPAR)))
    (<<   CEXPR     (pp.Group (+ LCRB CONTENT RCRB)))

    (<<   ICOMMENT   (pp.Group (+ (pp.Literal "#_") CONTENT)))
    (<<   ANNOTATION (pp.Group (+ (pp.Literal "#^") CONTENT)))

; _____________________________________________________________________________/ }}}1
; [pp] parse ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of List str)
        parse_hysky_code
        [#^ HCode code]
        (setv result (-> code infiltrate_with_indent
                              CONTENT.scanString
                              list           ; generator to list
                              flatten
                              (cut None -2)  ; remove column info
                              ))
        (lmap str result))

; _____________________________________________________________________________/ }}}1
; work on parsed data ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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

    (setv $CARD0 (ProcessorCard :indents     [$ELN]
                                :brkt_count  0
                                :dline_kind  DLineKind.EMPTY))

    ; work on dlines with structure: ["✠✠✠✠" "func" ...], ["✠✠" ":"], ["✠✠" "\\"]
; work on dlines ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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
        (return outp)
        )

    (defn #^ DeconstructedLine
        insert_starter_brackets
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
; line processor ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of Tuple ProcessorCard DeconstructedLine)
        process_dline
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
                  (insert_starter_brackets dline
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
                                 :dline_kind DLineKind.OPENER)
                  (insert_starter_brackets dline _levels_to_close _levels_to_open)]))

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
                  (insert_starter_brackets dline
                                           _levels_to_close
                                           _levels_to_open
                                           :remove_continuation_mark True)]))

; _____________________________________________________________________________/ }}}1
; full processor ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of List DeconstructedLine)
        process_dlines_list
        [ #^ ProcessorCard init_card
          #^ (of List DeconstructedLine) dlines
        ]
        (setv cur_card init_card)
        (setv _result (* ["blank"] (len dlines)))
        (for [[&idx &dl] (enumerate dlines)]
             (setv outp (process_dline cur_card &dl))
             (setv (get _result &idx) (second outp))
             (setv cur_card (first outp)))
        (return _result))

; _____________________________________________________________________________/ }}}1

    ; work on dlines with structure: ["✠✠✠✠✠✠✠✠", "))", "((("...]
; replace inline : and :: ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ DeconstructedLine
        add_inline_openers
        [ #^ DeconstructedLine dline
        ]
        (setv new_dline dline)
        (for [[&idx &elem] (enumerate new_dline)]
             (when (= &elem ":")
                   (assoc new_dline &idx "(")
                   (setv new_last_elem (sconcat (last new_dline) ")"))
                   (assoc new_dline -1 new_last_elem))
             (when (= &elem "::")
                   (assoc new_dline &idx ")(")))
        (return new_dline))

; _____________________________________________________________________________/ }}}1
; assembly_dlines ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ str
        assembly_dlines
        [ #^ (of List DeconstructedLine) dlines
        ]
        (setv _with_newLines (lmap (p> add_inline_openers
                                       prepare_dline_for_assembly)
                                   dlines))
        (-> _with_newLines
            flatten
            (str_join :sep " ")))


    (defn #^ DeconstructedLine
        prepare_dline_for_assembly
        [ #^ DeconstructedLine dline
        ]
        (setv _ident (* " " (- (len (nth 0 dline)) $ELN)))
        (setv _closers (nth 1 dline))
        (setv _openers (nth 2 dline))
        (setv _rest (cut dline 3 None))
        (lconcat [_closers] ["\n"] [_ident] [_openers] _rest))


; _____________________________________________________________________________/ }}}1

    ; final assembly:
; transpile hysky ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ str
        transpile_hysky
        [ #^ HCode code
        ]
        (setv _parsed (parse_hysky_code code))
        (setv _dlines (split_parsed_to_dlines _parsed))
        (setv _result (process_dlines_list $CARD0 _dlines))
        (assembly_dlines _result))

; _____________________________________________________________________________/ }}}1

    (setv _hysky (-> "parser_docs\\_test.hy" file_to_code))
    (setv _hy (transpile_hysky _hysky))

    (print _hy)
    (print "=========================")
    ;(hy.eval (hy.read_many _hy))

