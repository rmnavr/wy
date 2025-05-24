
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import pyparsing :as pp)

    (import Classes *)

    (import sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))

    (require hyrule [of as-> -> ->> doto case branch unless lif do_n list_n ncut])
    (import  _hyext *)
    (require _hyext [f:: fm p> pluckm lns &+ &+> l> l>=] :readers [L])

; _____________________________________________________________________________/ }}}1

    (setv $FILE "demo.hy")
    (setv $INDENT_MARK "✠")
    (setv $EMPTY_LINE_MARK "■")

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

    (defn #^ (of List DecoratedHCodeLine)
        split_code_to_decorated_lines
        [ #^ HCode hcode
        ]
        (->> hcode
             split_to_lines
             (lmap (p> empty_line_to_marker add_indent))))

    (defn #^ (of List HCodeLine)
        split_to_lines
        [ #^ HCode code
        ]
        (code.splitlines)
        )

    (defn #^ str
        empty_line_to_marker
        [ #^ HCodeLine line
        ]
        (if (re_test "^[ \t]*$" line)
            $EMPTY_LINE_MARK
            line))

    (defn #^ str
        add_indent
        [ #^ HCodeLine line
        ]
        (setv without_indent (line.lstrip))
        (setv indent_len (- (len line) (len without_indent)))
        (setv indent (* $INDENT_MARK indent_len))
        (sconcat indent without_indent)
        )

; _____________________________________________________________________________/ }}}1
; [pp] atoms ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv ALPHAS "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
    (setv NUMS   "0123456789")
    (setv INDENT (pp.Optional (pp.Word $INDENT_MARK)))
    (setv EMPTY_LINE (+ (pp.Word $EMPTY_LINE_MARK) (pp.LineEnd)))

    (setv MARK_BRACKET   (pp.Word ":"))
    (setv MARK_NOBRACKET (pp.Word "\\"))
    (setv MARK_LIST      (pp.Word "L"))
    (setv WORD           (pp.Word ALPHAS (+ pp.alphanums "_"))) 
    (setv OPERATOR       (pp.oneOf ": - + * / . = > < | ! &"))
    (setv NUMBER         (pp.Combine (+ (pp.Word NUMS)
                                        (pp.ZeroOrMore ".")
                                        (pp.ZeroOrMore (pp.Word NUMS))))) 
    ;
    (setv ENTITY (| MARK_BRACKET MARK_NOBRACKET MARK_LIST
                    WORD OPERATOR NUMBER))
    (setv FULL_LINE (+ INDENT (pp.OneOrMore ENTITY)))
    (setv LINE (| FULL_LINE EMPTY_LINE))

; _____________________________________________________________________________/ }}}1
; [pp] deconstruct decorated lines ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of List DeconstructedLine)
        parse_decoratedLines 
        [ #^ (of List DecoratedHCodeLine) lines
        ]
        (setv parsedResults (lmap LINE.parseString lines))  ; class: ParsedResult
        (lfor &pr parsedResults (lfor &elem &pr &elem))     ; convertion to list of lists of strings
        )

; _____________________________________________________________________________/ }}}1
; work on DLines ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ DLineKind
        get_dline_kind
        [ #^ DeconstructedLine dline
        ]
        (when (re_test "^✠*$" (first dline))
              (setv dline (cut dline 1 None)))
        (cond (= (first dline) $EMPTY_LINE_MARK)
              (return DLineKind.EMPTY)
              (= (first dline) ":")
              (return DLineKind.BRACKET_OPEN)
              (= (first dline) "L")
              (return DLineKind.LIST_OPEN)
              (= (first dline) "\\")
              (return DLineKind.CONTINUATION)
              True
              (return DLineKind.FUNCTION_OPEN)))

    (defn #^ (of Optional int)
        get_indent
        [ #^ DeconstructedLine dline
        ]
        (cond (= (get_dline_kind dline) DLineKind.EMPTY)
              (return None)
              (re_test "^✠*$" (first dline))
              (return (len (first dline)))
              True
              (return 0)))

; _____________________________________________________________________________/ }}}1

    (setv _code               (-> "demo.hy" file_to_code))
    (setv _decoratedLines     (split_code_to_decorated_lines _code))
    (setv _deconstructedLines (parse_decoratedLines _decoratedLines))
    (lprint _deconstructedLines)
    (lprint (lmap get_indent _deconstructedLines))

    (setv $PARSERSTART (ParserFlow :prev_indent    None
                                   :accum_brackets 0
                                   :accum_lists    0))

    (defn #^ ParserFlow
        process_one_dstring
        [ #^ ParserFlow        pflow
          #^ DeconstructedLine cur_dstring
          #^ DeconstructedLine next_dstring
        ]
        ;
        (setv _cur_indent (get_indent cur_dstring))
        ; empty string -> ...
        (when (isnone pflow.prev_indent)
              (cond ; ... -> empty string
                    (= (get_dline_kind cur_dstring) DLineKind.EMPTY)
                    (return (ParserFlow None 0 0))
                    ; ... -> partial
                    (= (get_dline_kind cur_dstring) DLineKind.FUNCTION_OPEN)
                    (return (ParserFlow _cur_indent (inc pflow.accum_brackts)
                                                    pflow.accum_lists))
                    ; ... -> 
                    (= (get_dline_kind cur_dstring) DLineKind.FUNCTION_OPEN)
                    (return (ParserFlow _cur_indent (inc pflow.accum_brackts)
                                                    pflow.accum_lists))
              )))


