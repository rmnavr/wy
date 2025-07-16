
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import pyparsing :as pp)

    (import Classes *)

    (import  _fptk_local *)
    (require _fptk_local *)

; _____________________________________________________________________________/ }}}1

    ; Step 1 : Atomization

; pp atoms ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv ALPHAS    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
    (setv WSYMBOLS  (+ "_" "$.-=+&*<>!/|" "%^?"))  ; excluded :#`'~@"\;,
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
    (setv NEW_LINE     (pp.Literal $NEWLINE_MARK))
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
                           NEW_LINE
                           INDENT))

    (setv EXPR         (| QEXPR SEXPR CEXPR))

    (setv CONTENT      (pp.Group (pp.ZeroOrMore (| EXPR ATOM))))
    (<<   QEXPR        (pp.Group (+ LBRCKT CONTENT RBRCKT)))
    (<<   SEXPR        (pp.Group (+ LPAR   CONTENT RPAR)))
    (<<   CEXPR        (pp.Group (+ LCRB   CONTENT RCRB)))

    (<<   ICOMMENT     (pp.Group (+ (pp.Literal "#_") CONTENT)))
    (<<   ANNOTATION   (pp.Group (+ (pp.Literal "#^") CONTENT)))

; _____________________________________________________________________________/ }}}1
; [step] run py parse               :: Prepared Code -> [Atom ...] ‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ (of List Atom)
        prepared_code_to_atoms
        [ #^ PreparedCode prepared_code
        ]
        (->> prepared_code
             CONTENT.scanString
             list                                ; generator to list
             (map (fm (cut %1 None -2)) #_ here) ; remove column info
             flatten))

; _____________________________________________________________________________/ }}}1
; [step] remove garbage from atoms  :: Atom -> Atom ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ Token
        remove_garbage_from_token
        [#^ Token token]
        "de facto removes indent/newline marks from qstring, for other tokens returns themselves"
        (if (qstring_tokenQ token)
            (->> token (re.sub (+ r"" $BASE_INDENT r"(" $INDENT_MARK "*)") (fm (%1.group 1)))    ; remove 4 artificial indent-marks from the start
                       (re.sub (+ r"" $INDENT_MARK) " "))        ; replace remaining with spaces
            token))

; _____________________________________________________________________________/ }}}1
; [step] split list of tokens into tlines :: [Token ...] -> [TLine ...] ‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of List TokenizedLine)
        split_tokens_to_tlines
        [ #^ (of List Token) tokens 
        ]
        (when (= tokens []) (return []))
        (setv _tlines [])
        ;
        (for [&elem tokens]
            (if (re_test (sconcat "^" $INDENT_MARK) &elem)
                (_tlines.append [&elem])
                (. (last _tlines) (append &elem))))
        (return _tlines))

; _____________________________________________________________________________/ }}}1

    (import Preparator [prepare_code_for_pyparsing])

    (setv _code " L x #: : ~@#:   : \\ 3 4 $ 7\n : riba\n1 2 \"\n\n  : L 2\"\n ; 123")

    (setv _prepared_code (prepare_code_for_pyparsing _code))
    (print _prepared_code)

    (setv _atoms (prepared_code_to_atoms _prepared_code))
    (lprint (lmap atom_to_token _atoms))

