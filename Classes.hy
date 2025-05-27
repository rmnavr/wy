
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))

    (require hyrule [of as-> -> ->> doto case branch unless lif do_n list_n ncut])
    (import  _hyextlink *)
    (require _hyextlink [f:: fm p> pluckm lns &+ &+> l> l>=] :readers [L])

; _____________________________________________________________________________/ }}}1

; constants ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv $INDENT_MARK  "✠")
    (setv $BASE_INDENT  "✠✠✠✠")
    (setv $ELIN         (len $BASE_INDENT)) ; empty line indents N

    ; used at : 1) StartOfLine          — work as LINESTARTERS
    ;           2) MidOfLine/EndOfLine  — work as MIDOPENERS
    (setv $MARKERS [ ":"   "L"    "C"   "#:"   "#C"
                     "':"  "'L"   "'C"  "'#:"  "'#C"
                     "`:"  "`L"   "`C"  "`#:"  "`#C"
                     "~:"  "~L"   "~C"  "~#:"  "~#C"
                     "~@:" "~@L"  "~@C" "~@#:" "~@#C" ])

    ; «double markders» used only in MiddleOfLine   — work as MIDDOUBLEOPENERS
    (setv $DMARKERS [ "::" "LL" ])

    (setv $CONTINUATORS [ "\\" "'" "`" "~" "~@"])

    ; ===================

    ; for usage in regex «`» should be escaped (but in normal string it shouldn't be escaped)
    ; regex will try to take max possible chars, so no special ordering inside $MARKERS_REGEX is required
    (setv $MARKERS_REGEX (+ r"("
                            (->> $MARKERS
                                 (str_join :sep "|")
                                 (re.sub r"\`" "\\`"))
                            ")"))

    ; "L:" should be before "L" — otherwise pyparser will interpret "L:" as "L" + ":"
    (setv $SKY_MARKERS (sorted (lconcat $MARKERS $DMARKERS $CONTINUATORS)
                               :key len
                               :reverse True))

; _____________________________________________________________________________/ }}}1

; preparator ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; PREPARATOR:
    ; - splits «   : func» to 2-lines (required to preserve 2nd indent)
    ; - inserts $INDENT_MARKs (with extra $BASE_INDENT at every line)

        ; Source code, Prepared code:
        (setv #_ DC FullCode        str)                ; "abs \n 3\n print y ..."
        (setv #_ DC CodeLine        str)                ; "partial flip 3"

; _____________________________________________________________________________/ }}}1
; parser: tokenizer ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv #_ DC Token           str)                ; ":" | "(" | ";text" | ...

    ; has extra $BASE_INDENT indents marks
    (setv #_ DC TokenizedLine   (of List Token))    ; ["✠✠✠✠" ":" "func" "x" "x" "; text"]  

; _____________________________________________________________________________/ }}}1
; parser: DLines builder ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defclass [dataclass] LinestarterDL []
        (#^ Token linestarter_token    #_ "like «:» and «#L» at beginning of the line"))

    (defclass [dataclass] ContinuatorDL []
        (#^ (of Optional Token) continuator_token   #_ "None is for digits and qstrings"))

    (defclass [dataclass] ImpliedOpenerDL [])

    (defclass [dataclass] OnlyOCommentDL [])

    (defclass [dataclass] EmptyLineDL [])

    (setv #_ DC StructuralKind (of Union LinestarterDL ContinuatorDL OnlyOCommentDL EmptyLineDL ImpliedOpenerDL))

    (defclass [dataclass] DeconstructedLine []
        (#^ StructuralKind      kind_spec)
        (#^ int                 equiv_indent)     ; <- extra ✠✠✠✠ are dealt with at this stage; there is only one case where equiv_indent≠real_indent - only for continuator \
        (#^ (of List Token)     body_tokens)
        (#^ (of Optional Token) ending_comment))  ; <- OnlyOCommentDL stores it's comment here

; _____________________________________________________________________________/ }}}1
; bracketer ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; to decide on closers/openers, current line needs info:
    ; - indent
    ; - opened brackets stack
    ; current line can deside how many closers/openers it needs based on itself and previous line, no more info is needed

    ; 1 — count only structural brackets

        (defclass [dataclass] BracketedLine []
            "calcs structural opener brackets for current line"
            (#^ DeconstructedLine   dline)
            (#^ str                 closers #_ "closers are placed before openers (thus closing previous line - but this info is stored in cur line)")
            (#^ str                 openers #_ "at the start for current line")) 

        ; structural bracket processor
        (defclass [dataclass] SBP_Card []
            "gives info on previously processed line"
            (#^ (of List int)   indents)
            (#^ (of List str)   brckt_stack #_ "list of closer brackets like [')' '}' ']'] where ')' is the first to be closed")
            (#^ type            skind #_ "StructuralKind"))

    ; 2 — work on inline brackets

        (setv #_ DC HyCodeFull str)
        (setv #_ DC HyCodeLine str)

; _____________________________________________________________________________/ }}}1


