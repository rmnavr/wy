
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import pyparsing :as pp)

    (import Classes *)

    (import sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))

    (require hyrule [of as-> -> ->> doto case branch unless lif do_n list_n ncut])
    (import  _hyext *)
    (require _hyext [f:: fm p> pluckm lns &+ &+> l> l>=] :readers [L])

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

    ; parse — returns 1st found?, takes list of str
    ; scan  — returns all found , takes list of str
    (defn t_orn [token name] (-> token pp.originalTextFor (.setResultsName name)))

; prepare code for parsing ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of List IndentMarkedLine)
        infiltrate_with_indent
        [ #^ HCode hcode
        ]
        (->> hcode
             split_to_lines
             (lmap add_indent)
             (str_join :sep "\n")
             ))

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
        (sconcat (* $INDENT_MARK 4) indent without_indent) ; always add at least 4 indent
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
        split_parsed_to_lines    
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

    (setv _code (-> "demo.hy" file_to_code))
    (setv _parsed (parse_hysky_code _code))

    (lmap print (split_parsed_to_lines _parsed))
    ;(lprint (split_parsed_to_lines _parsed))


