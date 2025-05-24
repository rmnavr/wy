
    (setv $INDENT_MARK  "✠")
    (setv $EMPTY_LINE   "✠✠✠✠")
    (setv $ELN          4)

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

; prepare code for parsing ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of List IndentMarkedLine)
        infiltrate_with_indent
        [ #^ HCode hcode
        ]
        (setv outp (->> hcode
                        split_to_lines
                        (lmap add_indent)
                        (str_join :sep "\n")
                        ))
        ; also always add last empty line (to avoid special case for line processor)
        (return (sconcat outp $EMPTY_LINE)))

    (defn #^ (of List HCodeLine)
        split_to_lines
        [ #^ HCode code
        ]
        (code.splitlines)
        )

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
    (setv QEXPR     (pp.Forward))           ; [ ... ]
    (setv SEXPR     (pp.Forward))           ; ( ... ) #( ... )
    (setv CEXPR     (pp.Forward))           ; { ... } #{ ... }

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

; work on dlines ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ DLineKind
        get_dline_kind
        [ #^ DeconstructedLine dline
        ]
        (when (= (len dline) 1)
              (return DLineKind.EMPTY))
        (setv _elem (second dline))
        (cond (= ":" _elem)
              (return DLineKind.OPENER)
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
        (for [&idx (range 0 (len indents))] (when (= cur_indent (get indents &idx)) (setv outp &idx)))
        (return outp)
        )

    (defn #^ DeconstructedLine
        insert_starter_brackets
        [ #^ DeconstructedLine dline
          #^ int closers
          #^ int openers
          #^ bool [remove_continuation_mark False ]
        ]

        (lconcat [(get dline 0)]
                 [(sconcat (* ")" closers) (* "(" openers))]
                 (if remove_continuation_mark
                     (cut dline 2 None)
                     (cut dline 1 None))))

; _____________________________________________________________________________/ }}}1
; line processor ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv $CARD0 (ProcessorCard :indents     [$ELN]
                                :brkt_count  0))

    (defn #^ (of Tuple ProcessorCard DeconstructedLine)
        process_dline
        [ #^ ProcessorCard     pcard
          #^ DeconstructedLine dline
        ]
        (setv dline_kind (get_dline_kind dline))
        (cond (= dline_kind DLineKind.OPENER) 
              (process_opener_dline pcard dline)
              (= dline_kind DLineKind.EMPTY)
              (process_empty_dline pcard dline)
              (= dline_kind DLineKind.CONTINUATOR)
              (process_continuator_dline pcard dline)
              True
              [pcard dline]))

    (defn #^ (of Tuple ProcessorCard DeconstructedLine)
        process_empty_dline
        [ #^ ProcessorCard     pcard
          #^ DeconstructedLine dline
        ]
        (setv prev_accum   pcard.brkt_count)
        ;
        (return [ $CARD0
                  (insert_starter_brackets dline
                                           prev_accum
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
        ;
        (setv _levels_to_open 1)
        (cond (> cur_indent prev_indent)
              (setv _levels_to_close 0
                    _new_indents (lconcat prev_indents [cur_indent]))
              (= cur_indent prev_indent)
              (setv _levels_to_close 1
                    _new_indents prev_indents)
              (< cur_indent prev_indent)
              (setv _levels_to_close (- (len prev_indents)
                                        (get_indent_level prev_indents cur_indent))
                    _new_indents (list (drop_last (dec _levels_to_close) prev_indents))))
        (return [ (ProcessorCard :indents    _new_indents
                                 :brkt_count (+ prev_accum
                                                _levels_to_open
                                                (neg _levels_to_close)))
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
        ;
        (setv _levels_to_open 0)
        (cond (> cur_indent prev_indent)
              (setv _levels_to_close 0
                    _new_indents (lconcat prev_indents [cur_indent]))
              (= cur_indent prev_indent)
              (setv _levels_to_close 0
                    _new_indents prev_indents)
              (< cur_indent prev_indent)
              (setv _levels_to_close (- (len prev_indents)
                                        (get_indent_level prev_indents cur_indent)
                                        1)
                    _new_indents (list (drop_last _levels_to_close prev_indents))))
        (return [ (ProcessorCard :indents    _new_indents
                                 :brkt_count (+ prev_accum
                                                _levels_to_open
                                                (neg _levels_to_close)))
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

; assembly_dlines ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ str
        assembly_dlines
        [ #^ (of List DeconstructedLine) dlines
        ]
        (setv _with_newLines (lfor &dl dlines (lconcat ["\n" (* " " (- (len (first &dl)) 4))]
                                                       (list (rest &dl)))))
        (-> _with_newLines
            flatten
            (str_join :sep " "))
        )

; _____________________________________________________________________________/ }}}1

    (setv _code (-> "parser_demo.hy" file_to_code))
    (setv _parsed (parse_hysky_code _code))
    (setv _dlines (split_parsed_to_dlines _parsed))
    (setv _result (process_dlines_list $CARD0 _dlines))
    (print (assembly_dlines _result))


    ;(lprint (lfor &dl _dlines (process_dline $CARD0 &dl)))
    ;(lprint (split_parsed_to_lines _parsed))


    
