
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import  wy._fptk_local *)
    (require wy._fptk_local *)

    (import  sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))

; _____________________________________________________________________________/ }}}1

; [=] wy marks and markers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv $INDENT_MARK    "■")   ; must be 1 symbol
    (setv $NEWLINE_MARK   "☇¦")  ; must not contain spaces and regex operators like | and such

    ; =========================

    ; «omarkers» (opener markers) can act as «smarkers» (start markers) and «mmarkers» (mid markers):
    (setv $OMARKERS [   ":"   "L"    "C"   "#:"   "#C"
                       "':"  "'L"   "'C"  "'#:"  "'#C"
                       "`:"  "`L"   "`C"  "`#:"  "`#C"
                       "~:"  "~L"   "~C"  "~#:"  "~#C"
                      "~@:" "~@L"  "~@C" "~@#:" "~@#C" ])

    (setv $DMARKERS [ "::" "LL" ])  ; double markers

    (setv $CMARKER  "\\")           ; continuation marker
    (setv $CMARKER_REGEX  r"\\")           

    (setv $AMARKER  "$")            ; application marker
    (setv $RMARKER  "<$")           ; reverse application marker
    (setv $JMARKER  ",")            ; joiner marker

    ; used in pyparsing, so order is important:
    (setv $WY_MARKERS (sorted (lconcat $OMARKERS $DMARKERS [$CMARKER $RMARKER $AMARKER $JMARKER])
                              :key len
                              :reverse True))

    ; =========================

    ; 1) for usage in regex «`» should be escaped (but in normal string it shouldn't be escaped) ;
    ; 2) since regex is trying to take max possible chars match, no special ordering inside $OMARKERS_REGEX is required
    (setv $OMARKERS_REGEX (+ r"("
                             (->> $OMARKERS
                                  (str_join :sep "|")
                                  (re.sub r"\`" "\\`"))
                             ")"))

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

    (setx $HY_OPENERS_REGEX (+ r"("
                               (->> $HY_OPENERS
                                    (str_join :sep "|")
                                    (re_sub r"\`" "\\`")
                                    (re_sub r"\(" "\\(")
                                    (re_sub r"\[" "\\[")
                                    (re_sub r"\{" "\\{")
                                    )
                               ")"))

    ; ===============================================================================

    ; used in tokenQ:
    (setv $CLOSER_BRACKETS [ ")" "]" "}" ])
    (setv $CLOSER_BR_REGEX r"(\)|\]|\})")

; _____________________________________________________________________________/ }}}1

    (setv WyCode       StrictStr)
    (setv WyCodeLine   StrictStr)
    (setv PreparedCode StrictStr)
    (setv Atom         StrictStr)

; [F] atom checks ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; wy:

        (defn [validateF] #^ bool indent_atomQ  [#^ Atom atom] (re_test (sconcat r"^(" $INDENT_MARK r")+$") atom))
        (defn [validateF] #^ bool newline_atomQ [#^ Atom atom] (=  atom $NEWLINE_MARK))

        (defn [validateF] #^ bool omarker_atomQ [#^ Atom atom] (in atom $OMARKERS))
        (defn [validateF] #^ bool dmarker_atomQ [#^ Atom atom] (in atom $DMARKERS))
        (defn [validateF] #^ bool cmarker_atomQ [#^ Atom atom] (=  atom $CMARKER))
        (defn [validateF] #^ bool amarker_atomQ [#^ Atom atom] (=  atom $AMARKER))
        (defn [validateF] #^ bool rmarker_atomQ [#^ Atom atom] (=  atom $RMARKER))
        (defn [validateF] #^ bool jmarker_atomQ [#^ Atom atom] (=  atom $JMARKER))

    ; hy: 

        (defn [validateF] #^ bool hyexpr_atomQ
            [#^ Atom atom]
            (re_test (sconcat r"^" $HY_OPENERS_REGEX ".*" $CLOSER_BR_REGEX "$")
                      atom
                      re.DOTALL))

        (defn [validateF] #^ bool hy_opener_atomQ       [#^ Atom atom] (in atom $HY_OPENERS))
        (defn [validateF] #^ bool closing_bracket_atomQ [#^ Atom atom] (in atom $CLOSER_BRACKETS))

        (defn [validateF] #^ bool
            hy_bracket_atomQ
            [ #^ Atom atom
            ]
            (or (hy_opener_atomQ       atom)
                (closing_bracket_atomQ atom)))

        (defn [validateF] #^ bool hy_macromark_atomQ    [#^ Atom atom] (in atom $HY_MACROMARKS))
        (defn [validateF] #^ bool digit_atomQ           [#^ Atom atom] (re_test r"^\.?\d" atom))
        (defn [validateF] #^ bool keyword_atomQ         [#^ Atom atom] (re_test r":\w+" atom))
        (defn [validateF] #^ bool unpacker_atomQ        [#^ Atom atom] (in atom ["#*" "#**"]))
        (defn [validateF] #^ bool qstring_atomQ         [#^ Atom atom] (re_test "^[rbf]?\"" atom))
        (defn [validateF] #^ bool annotation_atomQ      [#^ Atom atom] (= atom "#^"))
        (defn [validateF] #^ bool icomment_atomQ        [#^ Atom atom] (= atom "#_"))
        (defn [validateF] #^ bool ocomment_atomQ        [#^ Atom atom] (re_test "^;" atom))

    ; unite:

        (defn [validateF] #^ bool
            atom_regarded_as_continuatorQ
            [ #^ Atom atom
            ]
            (or (hyexpr_atomQ       atom)
                (digit_atomQ        atom)
                (qstring_atomQ      atom)
                (keyword_atomQ      atom)
                (annotation_atomQ   atom)
                (icomment_atomQ     atom)
                (unpacker_atomQ     atom)
                (hy_macromark_atomQ atom)
                (hy_bracket_atomQ   atom)))

; _____________________________________________________________________________/ }}}1
; [C] Token ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defclass [] TKind [Enum]
        (setv NewLine       00  #_ "¦☇"                 )
        (setv Indent        01  #_ "■■■■"               )
        (setv NegIndent     99  #_ "atom is '←', only one use case: 'x , \\ y'") ; tlen returns -1 for it; created only at jmarker expansion, and then used in Deconstructor
        (setv OMarker       02  #_ "#: smarker/mmarker" )
        (setv DMarker       03  #_ "LL ::"              )
        (setv CMarker       04  #_ "\\"                 )
        (setv AMarker       05  #_ "$"                  )
        (setv RMarker       06  #_ "<$"                 )
        (setv JMarker       07  #_ ","                  )
        (setv OComment      08  #_ ";comment"           )
        (setv RACont        09  #_ "( ) 1 #* #_ ..."    )  ; regarded as continuator
        (setv RAOpener      10  #_ "everything else"    )  ; regarded as opener
        ;
        (defn __repr__ [self] (return self.name))
        (defn __str__  [self] (return self.name))) 

    (defclass [] Token [BaseModel]
        (#^ TKind     kind)
        (#^ StrictStr atom)
        ;
        (defn __init__ [self k a] (-> (super) (.__init__ :kind k :atom a)))
        (defn __repr__ [self] (return (sconcat "<" self.kind.name ": '" self.atom "'>")))
        (defn __str__  [self] (return (self.__repr__))))

    (defn [validateF] #^ Token atom_to_token [#^ Atom atom]
        (cond (newline_atomQ                 atom) (Token TKind.NewLine  atom)
              (indent_atomQ                  atom) (Token TKind.Indent   atom)
              (omarker_atomQ                 atom) (Token TKind.OMarker  atom)
              (dmarker_atomQ                 atom) (Token TKind.DMarker  atom)
              (cmarker_atomQ                 atom) (Token TKind.CMarker  atom)
              (amarker_atomQ                 atom) (Token TKind.AMarker  atom)
              (rmarker_atomQ                 atom) (Token TKind.RMarker  atom)
              (jmarker_atomQ                 atom) (Token TKind.JMarker  atom)
              (ocomment_atomQ                atom) (Token TKind.OComment atom)
              (atom_regarded_as_continuatorQ atom) (Token TKind.RACont   atom)
              True                                 (Token TKind.RAOpener atom)))

; _____________________________________________________________________________/ }}}1
; [C] NTLine (numbered line of tokens) ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defclass [] NTLine [BaseModel]
        "Numbered Line of Tokens; Count starts from 1 (not 0) to be consistent with python errors messages (where 1st line of file is line 1, not line 0)"
        (#^ StrictInt       rowN             #_ "ordered NTLine number; multiline qstrings do not increase this number")
        (#^ StrictInt       realRowN_start   #_ "corresponds to raw wy-code line number; multiline qstrings are taken into account here")
        (#^ StrictInt       realRowN_end)
        (#^ (of List Token) tokens))

    (defn ntl_print
        [ #^ NTLine ntline ]
        (setv token_line (lpluckm .atom ntline.tokens))
        (print f"Line = {ntline.rowN} ({ntline.realRowN_start}-{ntline.realRowN_end}) | {token_line}"))

; _____________________________________________________________________________/ }}}1
; [C] NDLine (numbered deconstructed line) ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defclass [] SKind [Enum]
        (setv GroupStarter   1)
        (setv Continuator    2)
        (setv ImpliedOpener  3)
        (setv OnlyOComment   4)
        (setv EmptyLine      5)
        ;
        (defn __repr__ [self] (return self.name))
        (defn __str__  [self] (return self.name))) 

    (setv _tripleInt (of Tuple StrictInt StrictInt StrictInt))

    (defclass [] NDLine [BaseModel]
        (#^ SKind                kind)      
        (#^ _tripleInt           rowN)                 ; #(rowN realRowN_start realRowN_end) from source NTLine
        (#^ StrictInt            indent)               ; <- " \ x" is 3, " #:" is 1, "" (empty line) is 0, "x" is 0
        (#^ (of List Token)      body_tokens)          ; <- other tokens, info on which not dubbed (in some way) in other fields 
        ; below None is used for kinds where field not applicable:
        (#^ (of Optional Token)  t_smarker)            ; <- used only by SKind.GroupStarter
        (#^ (of Optional Token)  t_ocomment))          ; <- used by 3 SKinds: ImpliedOpener/Continuator/OnlyOComment

    (setv $BLANK_DL (NDLine :kind                 SKind.EmptyLine
                            :indent               0
                            :body_tokens          []
                            :rowN                 #(0 0 0)
                            ;
                            :t_smarker            None
                            :t_ocomment           None))

; _____________________________________________________________________________/ }}}1
; [C] BLine (bracketed line), NDLineInfo ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; structural bracket processor
    (defclass NDLineInfo [BaseModel]
        "gives info on previously processed line"
        (#^ (of List StrictInt) indents)
        (#^ (of List StrictStr) brckt_stack #_ "elems of CLOSER_BRACKETS: like [')' '}' ']'] where ')' is the first one to be closed")
        (#^ SKind               kind))

    ; Bracketed line
    (defclass BLine [BaseModel]
        "calcs structural opener brackets for current line"
        (#^ NDLine         ndline)
        (#^ (of List Atom) prev_closers #_ "elems of CLOSER_BRACKETS; closers are closing previous line - but this info is stored in cur line")
        (#^ (of List Atom) this_openers #_ "elems of HY_OPENERS; openers are at the start for current line"))

; _____________________________________________________________________________/ }}}1

    (setv #_ DC HyCodeLine str)
    (setv #_ DC HyCode     str)

