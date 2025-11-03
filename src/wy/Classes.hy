
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import  wy._fptk_local *)
    (require wy._fptk_local *)

    (import  sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))

; _____________________________________________________________________________/ }}}1

    (setv WyCode       StrictStr)
    (setv WyCodeLine   StrictStr)
    (setv PreparedCode StrictStr)
    (setv Atom         StrictStr)
    (setv HyCodeLine   str)
    (setv HyCode       str)

    ; Preparator
; [=] wy marks and markers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv $INDENT_MARK    "■")   ; must be 1 symbol
    (setv $NEWLINE_MARK   "☇¦")  ; must not contain spaces and regex operators like | and such

    ; «omarkers» (opener markers) can act as «smarkers» (start markers) and «mmarkers» (mid markers):
    (setv $OMARKERS (sorted [   ":"   "L"    "C"   "#:"   "#C"
                               "':"  "'L"   "'C"  "'#:"  "'#C"
                               "`:"  "`L"   "`C"  "`#:"  "`#C"
                               "~:"  "~L"   "~C"  "~#:"  "~#C"
                              "~@:" "~@L"  "~@C" "~@#:" "~@#C" ]
                            :key len :reverse True))

    ; 1) for usage in regex «`» should be escaped (but in normal string it shouldn't be escaped) ;
    ; 2) since regex is trying to take max possible chars match, no special ordering inside $OMARKERS_REGEX is required
    (setv $OMARKERS_REGEX (+ r"("
                             (->> $OMARKERS
                                  (str_join :sep "|")
                                  (re.sub r"\`" "\\`"))
                             ")"))

    (setv $DMARKERS ["::" "LL" "CC" ":#:" "C#C"])  ; double markers

    (setv $CMARKER  "\\")           ; continuation marker
    (setv $CMARKER_REGEX  r"\\")           

    (setv $AMARKER  "$")            ; application marker
    (setv $RMARKER  "<$")           ; reverse application marker
    (setv $JMARKER  ",")            ; joiner marker


; _____________________________________________________________________________/ }}}1
; [=] hy syntax elements ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; used in pyparser, so order is important:
    (setv $HY_MACROMARKS [ "~@" "~" "`" "'"])

    ; used in pyparser, so order is important:
    (setv $HY_OPENERS1 [ "~@#(" "~#(" "~@(" "'#(" "`#(" "#(" "`(" "'(" "~(" "("])
    (setv $HY_OPENERS2 [ "~@#[" "~#[" "~@[" "'#[" "`#[" "#[" "`[" "'[" "~[" "["])
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
    
    ; Parser
; [C] Token: kinds ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defclass [] PKind [Enum]
        "clasifies token by as what entity it was parsed"
        (setv HYEXPR       01)
        (setv QSTRING      02)
        (setv OCOMMENT     03)
        (setv KEYWORD      04)
        (setv NUMBER       05)
        (setv WORD         06)
        (setv SUGAR        07)
        (setv OMARKER      08)
        (setv DMARKER      09)
        (setv CMARKER      10)
        (setv AMARKER      11)
        (setv RMARKER      12)
        (setv JMARKER      13)
        (setv HYMACRO_MARK 14)
        (setv RMACRO       15)
        (setv NEW_LINE     16)
        (setv INDENT       17)
        (setv ORPHANB      18) ; PAtoms of this pkind are not really created, because WyParserError is thrown instead
        (setv NOT_FROM_PP  19) ; This is what TKind.NegIndent uses
        (defn __repr__ [self] (return self.name))
        (defn __str__  [self] (return self.name)))

    (defclass [] TKind [Enum]
        "classifies token by functionality"
        (setv NewLine       01  #_ "¦☇"                 )
        (setv Indent        02  #_ "■■■■"               )
        (setv NegIndent     03  #_ "atom is '←', only one use case: 'x , \\ y'") ; tlen returns -1 for it; created only at jmarker expansion, and then used in Deconstructor
        ;
        (setv OMarker       04  #_ "#: smarker/mmarker" )
        (setv SMarker       05                          ) ; OMarker is updated to those types at Expander stage (just before expansion starts)
        (setv MMarker       06                          ) ; OMarker is updated to those types at Expander stage (just before expansion starts)
        (setv DMarker       07  #_ "LL ::"              )
        (setv CMarker       08  #_ "\\"                 )
        (setv AMarker       09  #_ "$"                  )
        (setv RMarker       10  #_ "<$"                 )
        (setv JMarker       11  #_ ","                  )
        ;
        (setv OComment      12  #_ ";comment"           )
        (setv RACont        13  #_ "( ) 1 #* #_ ..."    )  ; regarded as continuator
        (setv RAOpener      14  #_ "everything else"    )  ; regarded as opener
        ;
        (defn __repr__ [self] (return self.name))
        (defn __str__  [self] (return self.name))) 

; _____________________________________________________________________________/ }}}1
; [C] Token: main ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defclass [] Token [BaseModel]
        (#^ Atom  atom)
        (#^ PKind pkind)
        (#^ TKind tkind)
        ;
        (defn __init__ [self a p t] (-> (super) (.__init__ :atom a :pkind p :tkind t)))
        (defn __repr__ [self] (return (sconcat "<" self.tkind.name "(" self.pkind.name "): '" self.atom "'>")))
        (defn __str__  [self] (return (self.__repr__))))

    ; tokens with always the same atom:
    (setv t_negindent (Token "←"      PKind.NOT_FROM_PP TKind.NegIndent))
    (setv t_newline   (Token $JMARKER PKind.NEW_LINE    TKind.NewLine))
    (setv t_cmarker   (Token $CMARKER PKind.CMARKER     TKind.CMarker))
    (setv t_amarker   (Token $AMARKER PKind.AMARKER     TKind.AMarker))
    (setv t_rmarker   (Token $RMARKER PKind.RMARKER     TKind.RMarker))
    (setv t_jmarker   (Token $JMARKER PKind.JMARKER     TKind.JMarker))
    ; also NDLine has .t_smarker attribute, but please do not connect it logically to the list above

; _____________________________________________________________________________/ }}}1

    ; Parser, Expander
; [C] NTLine (numbered line of tokens) ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv _tripleInt (of Tuple StrictInt StrictInt StrictInt))
    ; 1 - ordered NTLine number; multiline qstrings do not increase this number
    ; 2 - raw wy-code line number (start); multiline qstrings are taken into account here
    ; 3 - raw wy-code line number (end)

    (defclass [] NTLine [BaseModel]
        "Numbered Line of Tokens;
         Count starts from 1 (not 0) to be consistent with python errors messages
         (where 1st line of file is line 1, not line 0)"
        (#^ _tripleInt      lineNs)
        (#^ (of List Token) tokens))

    (defn ntl_print
        [ #^ NTLine ntline ]
        (setv token_line (lpluckm .atom ntline.tokens))
        (print f"Line = {ntline.rowN} ({ntline.realRowN_start}-{ntline.realRowN_end}) | {token_line}"))

; _____________________________________________________________________________/ }}}1

    ; Deconstructor
; [C] NDLine (numbered deconstructed line) ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defclass [] SKind [Enum]
        "structural kind"
        (setv GroupStarter   1)
        (setv Continuator    2)
        (setv ImpliedOpener  3)
        (setv OnlyOComment   4)
        (setv EmptyLine      5)
        ;
        (defn __repr__ [self] (return self.name))
        (defn __str__  [self] (return self.name))) 

    (defclass [] NDLine [BaseModel]
        (#^ SKind                kind)      
        (#^ _tripleInt           rowN)                 ; lineNs from source NTLine
        (#^ StrictInt            indent)               ; <- " \ x" is 3, " #:" is 1, "" (empty line) is 0, "x" is 0
        (#^ (of List Token)      body_tokens)          ; <- other tokens, info on which is NOT dubbed (in some way) in other fields 
        ; below None is used for kinds where field not applicable:
        (#^ (of Optional Token)  t_smarker)            ; <- used only by SKind.GroupStarter
        (#^ (of Optional Token)  t_ocomment))          ; <- used by 3 SKinds: ImpliedOpener/Continuator/OnlyOComment

; _____________________________________________________________________________/ }}}1

    ; Bracketer:
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

    ; Writer:
; [F] atoms checks ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ bool omarker_atomQ         [#^ Atom atom] (in atom $OMARKERS))
    (defn [validateF] #^ bool hy_opener_atomQ       [#^ Atom atom] (in atom $HY_OPENERS))
    (defn [validateF] #^ bool closing_bracket_atomQ [#^ Atom atom] (in atom $CLOSER_BRACKETS))

    (defn [validateF] #^ bool
        hy_bracket_atomQ
        [ #^ Atom atom
        ]
        (or (hy_opener_atomQ       atom)
            (closing_bracket_atomQ atom)))

; _____________________________________________________________________________/ }}}1

    ; for all submodules:
; [C] Exceptions ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; .msg does NOT include "ERROR: " prefix or similar.
    ; This prettification is done at Assembler level instead.

    ; Parser:

        (defclass [dataclass] WyParserError [Exception]
            (#^ StrictInt startpos) ; char pos in overall wy-code
            (#^ StrictInt endpos)   ; char pos in overall wy-code
            (#^ StrictStr char)     ; like '~@('
            (#^ StrictStr msg))

    ; Expander

        (defclass [dataclass] WyExpanderError [Exception]
            (#^ NTLine    ntline)
            (#^ StrictStr msg))

    ; Bracketer:

        (defclass [dataclass] WyBracketerError [Exception]
            (#^ NDLine    ndline)
            (#^ StrictStr msg))

; _____________________________________________________________________________/ }}}1

