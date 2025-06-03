
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))

    (require hyrule [of as-> -> ->> doto case branch unless lif do_n list_n ncut])
    (import  _hyextlink *)
    (require _hyextlink [f:: fm p> pluckm lns &+ &+> l> l>=] :readers [L])

; _____________________________________________________________________________/ }}}1

; markers (constants) ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv $INDENT_MARK    "✠")
    (setv $BASE_INDENT    "✠✠✠✠")
    (setv $ELIN           (len $BASE_INDENT)) ; [E]mpty [L]ine [I]ndents [N]

    (setv $MIDSPACE_MARK  "■")

    ; ===============================================================================

    ; can act as «smarkers» and «mmarkers»
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

    (setv $DMARKERS [ "::" "LL" ])

    (setv $CMARKER  "\\")
    (setv $CMARKERS ["\\"]) ; JFK, currently both are used; remove this line please with refactor (I beg you)
    (setv $AMARKER  "$")
    (setv $JMARKER  ",")

    ; used in pyparsing, so order is important
    (setv $WY_MARKERS (sorted (lconcat $OMARKERS $DMARKERS [$CMARKER] [$AMARKER] [$JMARKER])
                              :key len
                              :reverse True))


    ; ===============================================================================

    ; used in pyparser, so order is important
    (setv $HY_MACROMARKS [ "~@" "~" "`" "'"])

    ; used in pyparser, so order is important
    (setv $HY_OPENERS1 [ "~@#(" "~#(" "~@(" "'#(" "`#(" "#(" "`(" "'(" "~(" "("])
    (setv $HY_OPENERS2 [              "~@["                  "`[" "'[" "~[" "["])
    (setv $HY_OPENERS3 [ "~@#{" "~#{" "~@{" "'#{" "`#{" "#{" "`{" "'{" "~{" "{"])

    ; used in tokenQ
    (setv $HY_OPENERS  (lconcat $HY_OPENERS1 $HY_OPENERS2 $HY_OPENERS3))

    ; ===============================================================================

    ; used in tokenQ
    (setv $CLOSER_BRACKETS [ ")" "]" "}" ])

; _____________________________________________________________________________/ }}}1
; preparator ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; used both for condensed (source) and expanded grammar:
    (setv #_ DC WyCodeLine str)
    (setv #_ DC WyCodeFull str)
    (setv #_ DC PreparedCodeFull str)

; _____________________________________________________________________________/ }}}1
; parser ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv #_ DC Token StrictStr)                      ; ":" | "(" | ";text" | ...
    (setv #_ DC TokenizedLine (of List StrictStr))    ; ["✠✠✠✠" ":" "func" "x" "x" "; text"]  

    (defclass [] NumberedTLine [BaseModel]
        (#^ StrictInt     origRow #_ "count starts from 0")
        (#^ TokenizedLine tline))

    ; ==========================================================================================================

    (defclass [dataclass] GroupStarterDL []
        (#^ Token smarker    #_ "like «:» and «#L» at beginning of the line"))

    (defclass [dataclass] ContinuatorDL []
        (#^ (of Optional Token) cmarker #_ "usually <\\>, None is for what regarded as openers (digits, strings, etc.)"))

    (defclass [dataclass] ImpliedOpenerDL [])

    (defclass [dataclass] OnlyOCommentDL [])

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
; bracketer ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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



