
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import  _fptk_local *)
    (require _fptk_local *)

    (import  sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))

; _____________________________________________________________________________/ }}}1

; [=] wy marks and markers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; marks:

        (setv $INDENT_MARK    "✠")
        (setv $BASE_INDENT    "✠✠✠✠")
        (setv $ELIN           (strlen $BASE_INDENT)) ; [E]mpty [L]ine [I]ndents [N]

        (setv $MIDSPACE_MARK  "■")

    ; markers:

        ; «omarkers» (opener markers) can act as «smarkers» (start markers) and «mmarkers» (mid markers):
        (setv $OMARKERS [   ":"   "L"    "C"   "#:"   "#C"
                           "':"  "'L"   "'C"  "'#:"  "'#C"
                           "`:"  "`L"   "`C"  "`#:"  "`#C"
                           "~:"  "~L"   "~C"  "~#:"  "~#C"
                          "~@:" "~@L"  "~@C" "~@#:" "~@#C" ])

        ; 1) for usage in regex «`» should be escaped (but in normal string it shouldn't be escaped) ;
        ; 2) since regex is trying to take max possible chars match, no special ordering inside $OMARKERS_REGEX is required
        (setv $OMARKERS_REGEX (+ r"("
                                 (->> $OMARKERS
                                      (str_join :sep "|")
                                      (re.sub r"\`" "\\`"))
                                 ")"))

        (setv $DMARKERS [ "::" "LL" ])  ; double markers

        (setv $CMARKER  "\\")           ; continuation marker
        (setv $AMARKER  "$")            ; application marker
        (setv $RMARKER  "<$")           ; reverse application marker
        (setv $JMARKER  ",")            ; joiner marker

        ; used in pyparsing, so order is important:
        (setv $WY_MARKERS (sorted (lconcat $OMARKERS $DMARKERS [$CMARKER] [$RMARKER] [$AMARKER] [$JMARKER])
                                  :key len
                                  :reverse True))

; _____________________________________________________________________________/ }}}1
; [=] hy syntax elements ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; used in pyparser, so order is important:
    (setv $HY_MACROMARKS [ "~@" "~" "`" "'"])

    ; used in pyparser, so order is important:
    (setv $HY_OPENERS1 [ "~@#(" "~#(" "~@(" "'#(" "`#(" "#(" "`(" "'(" "~(" "("])
    (setv $HY_OPENERS2 [              "~@["                  "`[" "'[" "~[" "["])
    (setv $HY_OPENERS3 [ "~@#{" "~#{" "~@{" "'#{" "`#{" "#{" "`{" "'{" "~{" "{"])

    ; used in tokenQ:
    (setv $HY_OPENERS  (lconcat $HY_OPENERS1 $HY_OPENERS2 $HY_OPENERS3))

    ; ===============================================================================

    ; used in tokenQ:
    (setv $CLOSER_BRACKETS [ ")" "]" "}" ])

; _____________________________________________________________________________/ }}}1

; [C] Preparator ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; used both for condensed (source) and expanded syntax:
    (setv #_ DC WyCodeLine StrictStr)
    (setv #_ DC WyCodeFull StrictStr)
    (setv #_ DC PreparedCodeFull StrictStr)

; _____________________________________________________________________________/ }}}1
; [C] Parser ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; With below definitions, pydantic will:
    ; - NOT CHECK: Token, TokenizedLine
    ; - CHECK:     NumberedTLine

    (setv #_ DC Token StrictStr)                      ; ":" | "(" | ";text" | ...
    (setv #_ DC TokenizedLine (of List StrictStr))    ; ["✠✠✠✠" ":" "func" "x" "x" "; text"]  

    (defclass [] NumberedTLine [BaseModel] 
        (#^ StrictInt     origRowN #_ "count starts from 0")
        (#^ TokenizedLine tline))

    ; ==========================================================================================================
    ; Deconstructed Lines:

    (defclass [dataclass] GroupStarterDL []
        (#^ Token smarker #_ "like : and #C at beginning of the line"))

    (defclass [dataclass] ContinuatorDL []
        (#^ (of Optional Token) cmarker #_ "cmarker is \\ ; None is for what regarded as openers (digits, strings, etc.)"))

    (defclass [dataclass] ImpliedOpenerDL [])

    (defclass [dataclass] OnlyOCommentDL []) ; OComment is comment that starts with ";"

    (defclass [dataclass] EmptyLineDL [])

    (setv #_ DC StructuralKind (of Union GroupStarterDL ContinuatorDL OnlyOCommentDL EmptyLineDL ImpliedOpenerDL))

    (defclass [dataclass] DeconstructedLine []
        (#^ StructuralKind      kind_spec)
        (#^ int                 equiv_indent)     ; <- extra ✠✠✠✠ are dealt with at this stage; there is only one case where equiv_indent≠real_indent - only for continuator \
        (#^ (of List Token)     body_tokens)
        (#^ (of Optional Token) ending_comment))  ; <- OnlyOCommentDL stores it's comment here

    (setv $BLANK_DL (DeconstructedLine :kind_spec      (EmptyLineDL)
                                       :equiv_indent   0
                                       :body_tokens    []
                                       :ending_comment None))

; _____________________________________________________________________________/ }}}1
; [C] Bracketer ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defclass [dataclass] BracketedLine []
        "calcs structural opener brackets for current line"
        (#^ DeconstructedLine   dline)
        (#^ (of List Token)     closers #_ "elems of CLOSER_BRACKETS; closers are closing previous line - but this info is stored in cur line")
        (#^ (of List Token)     openers #_ "elems of HY_OPENERS; openers are at the start for current line")) 

    ; structural bracket processor
    (defclass [dataclass] SBP_Card []
        "gives info on previously processed line"
        (#^ (of List int)   indents)
        (#^ (of List str)   brckt_stack #_ "elems of CLOSER_BRACKETS: like [')' '}' ']'] where ')' is the first one to be closed")
        (#^ type            skind       #_ "StructuralKind"))

    (setv #_ DC HyCodeFull str)
    (setv #_ DC HyCodeLine str)

; _____________________________________________________________________________/ }}}1

; token testers: is continuator ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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

; _____________________________________________________________________________/ }}}1
; token testers: var ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ bool hy_opener_tokenQ       [#^ Token token] (in token $HY_OPENERS))
    (defn #^ bool closing_bracket_tokenQ [#^ Token token] (in token $CLOSER_BRACKETS))

    (defn #^ bool
        hy_bracket_tokenQ
        [ #^ Token token
        ]
        (or (hy_opener_tokenQ       token)
            (closing_bracket_tokenQ token)))

    (defn #^ bool hy_macromark_tokenQ    [#^ Token token] (in token $HY_MACROMARKS))

    (defn #^ bool digit_tokenQ           [#^ Token token] (re_test r"^\.?\d" token))
    (defn #^ bool keyword_tokenQ         [#^ Token token] (re_test r":\w+" token))
    (defn #^ bool unpacker_tokenQ        [#^ Token token] (in token ["#*" "#**"]))
    (defn #^ bool qstring_tokenQ         [#^ Token token] (re_test "^[rbf]?\"" token))
    (defn #^ bool annotation_tokenQ      [#^ Token token] (= token "#^"))
    (defn #^ bool icomment_tokenQ        [#^ Token token] (= token "#_"))

    (defn #^ bool
        ocomment_tokenQ
        [ #^ Token token
        ]
        "ocomment is Outer Comment starting with ; symbol"
        (re_test "^;" token))

; _____________________________________________________________________________/ }}}1
; token testers: wy token type ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ bool omarker_tokenQ [#^ Token token] (in token $OMARKERS))
    (defn #^ bool cmarker_tokenQ [#^ Token token] (= token $CMARKER))

; _____________________________________________________________________________/ }}}1

