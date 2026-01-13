
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (require wy.utils.fptk_local.loader [load_fptk])
    (load_fptk "core")

    (import  sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))

; _____________________________________________________________________________/ }}}1

    (setv WyCode       str)
    (setv WyCodeLine   str)
    (setv PreparedCode str)
    (setv Atom         str)
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
                                  (re_sub r"\`" "\\`"))
                             ")"))

    (setv $DMARKERS ["::" "LL" "CC" ":#:" "C#C"])  ; double markers

    (setv $CMARKER  "\\")           ; continuation marker
    (setv $CMARKER_REGEX  r"\\")

    (setv $AMARKER  "$")            ; application marker
    (setv $RMARKER  "<$")           ; reverse application marker
    (setv $JMARKER  ",")            ; joiner marker


; _____________________________________________________________________________/ }}}1
; [=] hy syntax elements ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; note on bracketed strings:
    ; - omarkers and dmarkers do NOT include #L, ~@#L, L#L and such
    ;   (parser will see #L as RMACRO, L#L as WORD )
    ; - but hy_openers DO INCLUDE ~@#[ and others as a valid hy opener,
    ;   so parser recognizes them as hy exprs
    ;   (by the way '#[] is syntax error in hy, and '#[[smth]] is correct br-string)

    ; used in pyparser, so order is important: (upd not really used now?)
    (setv $HY_MACROMARKS       [ "~@" "~" "`" "'"])
    (setv $HY_MACROMARKS_REGEX r"(~@|~|`|\')")

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
; [C] Token: kinds ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defclass [] PKind [Enum]
        "clasifies token by as what entity it was parsed;
         mostly used for debugging parser, since after Parser —
         token checks are tone on TKind"
        ; raw parser kinds:
        (setv HYEXPR       01)
        (setv QSTRING      02)
        (setv OCOMMENT     03)
        (setv NEW_LINE     05)
        (setv INDENT       06)
        (setv CMARKER      14)
        (setv ORPHANB      07) ; PAtoms of this pkind are not really created, because WyParserError is thrown instead
        ; kinds created by deconstructing SEMIWORD:
        (setv KEYWORD      08)
        (setv NUMBER       09)
        (setv WORD         10)
        (setv SUGAR        11)
        (setv OMARKER      12)
        (setv DMARKER      13)
        (setv AMARKER      15)
        (setv RMARKER      16)
        (setv JMARKER      17)
        (setv HYMACRO_MARK 18)
        (setv RMACRO       19)
        ; This is what TKind.NegIndent uses (it is created by hand, not by Parser):
        (setv NOT_FROM_PP  20)
        ;
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
; [C] Token: main ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defclass [dataclass] Token []
        (#^ Atom  atom)
        (#^ PKind pkind)
        (#^ TKind tkind)
        ;
        (defn __repr__ [self] (return (sconcat "<" self.tkind.name "(" self.pkind.name "): '" self.atom "'>")))
        (defn __str__  [self] (return (self.__repr__))))

    ; tokens with always the same atom:
    (setv t_negindent (Token "←"           PKind.NOT_FROM_PP TKind.NegIndent))
    (setv t_newline   (Token $NEWLINE_MARK PKind.NEW_LINE    TKind.NewLine))
    (setv t_cmarker   (Token $CMARKER      PKind.CMARKER     TKind.CMarker))
    (setv t_amarker   (Token $AMARKER      PKind.AMARKER     TKind.AMarker))
    (setv t_rmarker   (Token $RMARKER      PKind.RMARKER     TKind.RMarker))
    (setv t_jmarker   (Token $JMARKER      PKind.JMARKER     TKind.JMarker))
    ; also NDLine has .t_smarker attribute, but please do not connect it logically to the list above


; _____________________________________________________________________________/ }}}1
; [F] semiword2token (used only by Parser) ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv $HMMR_TEST (sconcat r"^" $HY_MACROMARKS_REGEX))

    ; used only in Parser:
    (defn [] #^ Token
        semiword_to_token
        [ #^ Atom atom
        ]
        "SEMIWORD is parser item, which is then deconstructed to var PKind"
        ; order of testing matters (due to some regexes working loosly — they check only atom's first chars)
        (cond (=  atom $AMARKER )              t_amarker
              (=  atom $RMARKER )              t_rmarker
              (=  atom $JMARKER )              t_jmarker
              (in atom $OMARKERS)              (Token atom PKind.OMARKER      TKind.OMarker)
              (in atom $DMARKERS)              (Token atom PKind.DMARKER      TKind.DMarker)
              (in atom ["#*" "#**" "#_" "#^"]) (Token atom PKind.SUGAR        TKind.RACont)
              (re_test r"^:." atom)            (Token atom PKind.KEYWORD      TKind.RACont)
              (re_test r"^#." atom)            (Token atom PKind.RMACRO       TKind.RACont)
              (re_test r"^(\+|-)?\.?\d" atom)  (Token atom PKind.NUMBER       TKind.RACont)
              (re_test $HMMR_TEST atom)        (Token atom PKind.HYMACRO_MARK TKind.RACont)
              True                             (Token atom PKind.WORD         TKind.RAOpener)))


; _____________________________________________________________________________/ }}}1
; [F] atom checks (used only by Writer) ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [] #^ bool omarker_atomQ [#^ Atom atom] (in atom $OMARKERS)) 
    (defn [] #^ bool hy_opener_atomQ       [#^ Atom atom] (in atom $HY_OPENERS))
    (defn [] #^ bool closing_bracket_atomQ [#^ Atom atom] (in atom $CLOSER_BRACKETS))

    (defn [] #^ bool
        hy_bracket_atomQ
        [ #^ Atom atom
        ]
        (or (hy_opener_atomQ       atom)
            (closing_bracket_atomQ atom)))

; _____________________________________________________________________________/ }}}1

; [C] NTLine (numbered line of tokens) ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv _tripleInt (of Tuple int int int))
    ; 1 - ordered NTLine number; multiline qstrings do not increase this number
    ; 2 - raw wy-code line number (start); multiline qstrings are taken into account here
    ; 3 - raw wy-code line number (end)

    (defclass [dataclass] NTLine []
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

    (defclass [dataclass] NDLine []
        (#^ SKind           kind)
        (#^ _tripleInt      rowN)                 ; lineNs from source NTLine
        (#^ int             indent)               ; <- " \ x" is 3, " #:" is 1, "" (empty line) is 0, "x" is 0
        (#^ (of List Token) body_tokens)          ; <- other tokens, info on which is NOT dubbed (in some way) in other fields
        ; below None is used for kinds where field not applicable:
        (#^ (of Optional Token)  t_smarker)            ; <- used only by SKind.GroupStarter
        (#^ (of Optional Token)  t_ocomment))          ; <- used by 3 SKinds: ImpliedOpener/Continuator/OnlyOComment

; _____________________________________________________________________________/ }}}1
; [C] BLine (bracketed line), NDLineInfo ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; structural bracket processor
    (defclass [dataclass] NDLineInfo []
        "gives info on previously processed line"
        (#^ (of List int) indents)
        (#^ (of List str) brckt_stack #_ "elems of CLOSER_BRACKETS: like [')' '}' ']'] where ')' is the first one to be closed")
        (#^ SKind         kind))

    ; Bracketed line
    (defclass [dataclass] BLine []
        "calcs structural opener brackets for current line"
        (#^ NDLine         ndline)
        (#^ (of List Atom) prev_closers #_ "elems of CLOSER_BRACKETS; closers are closing previous line - but this info is stored in cur line")
        (#^ (of List Atom) this_openers #_ "elems of HY_OPENERS; openers are at the start for current line"))

; _____________________________________________________________________________/ }}}1

; [C] Exceptions/ErrorMessages ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defclass [dataclass] PBMsg []
        "predefined backend message"
        ; parser1 msgs:
        (setv unmatched_opener "Unmatched opener hy-bracket found")
        ; parser2 msgs:
        (setv unmatched_closer (sconcat "bad syntax encountered by parser;"
                                      "\nknown cases of it happening — is when one of those starts indented line:"
                                      "\n- unmatched closer hy bracket"
                                      "\n- unmatched double-quote"
                                      "\n- unicode symbol outside strings/comments"))
        ; expander msgs:
        (setv f_bad_solo      (fn [atom] f"solo '{atom}' on one line is not allowed"))
        (setv f_bad_start     (fn [atom] f"line cannot start with '{atom}'"))
        (setv f_bad_end       (fn [atom] f"line cannot end with '{atom}'"))
        (setv f_bad_2         (fn [atom1 atom2] f"'{atom1}' cannot be followed by '{atom2}'"))
        (setv f_bad_2s        (fn [atom1 atom2] f"condensed opener '{atom1}' cannot be followed by '{atom2}'"))
        (setv f_bad_cont      (fn [atom] f"'\\' after '{atom}' is forbidden here"))
        (setv oneL_bad_indent f"bad indent after one-liner:\nincreasing indent after one-liner is allowed no further than\nto indents of openers at the one-liner start")
        ; deconstructor msgs:
        (setv bad_cont_indent f"increasing indent after continuation line is not allowed")
        (setv f_bad_oneL_appl (fn [string] f"continuator expression '{string}'\nis forbidden to be placed to the left of applicator '$'"))
        ; bracketer msgs:
        (setv bad_indent (sconcat "indent level of de-dented line"
                                "\nshould be of the same exact indent level as one of previous indents")))

    ; Parser:

        (defclass [] WyParserError [Exception]
            "for unmatched open brackets"
            (defn __init__
                [ self
                  #^ int startpos  ; char pos in overall prepared-wy-code (because Parser runs on Prepared code)
                  #^ int endpos    ; char pos in overall prepared-wy-code
                  #^ int char      ; like '~@('
                  #^ str msg
                ]
                (. (super) (__init__ f"{msg}\npos={startpos}-{endpos} char='{char}'"))
                (setv self.startpos startpos)
                (setv self.endpos   endpos)
                (setv self.char     char)
                (setv self.msg      msg)))

        (defclass [] WyParserError2 [Exception]
            "for unmatched closer brackets, double-quote and unicode outside strings/comments"
            (defn __init__
                [ self
                  #^ NTLine ntline
                  #^ str    msg
                ]
                (. (super) (__init__ f"{msg}\nntline: {ntline}"))
                (setv self.ntline ntline)
                (setv self.msg    msg)))

    ; Expander

        (defclass [] WyExpanderError [Exception]
            (defn __init__
                [ self
                  #^ NTLine ntline 
                  #^ str    msg]
                (. (super) (__init__ f"{msg}\nntline:\n{ntline}"))
                (setv self.ntline ntline)
                (setv self.msg    msg)))

    ; Deconstructor

        (defclass [] WyDeconstructorError [Exception]
            (defn __init__
                [ self
                  #^ NDLine ndline1 ; 1   line with parent indent 
                  #^ NDLine ndline2 ;  2  line that was tried to be indented
                  #^ str    msg]
                (. (super) (__init__ f"{msg}\nndline1:\n{ndline1}\nndline2:\n{ndline2}"))
                (setv self.ndline1 ndline1)
                (setv self.ndline2 ndline2)
                (setv self.msg    msg)))

    ; Bracketer:

        (defclass [] WyBracketerError [Exception]
            (defn __init__
                [ self
                  #^ NDLine ndline 
                  #^ str    msg]
                (. (super) (__init__ f"{msg}\nndline:\n{ndline}"))
                (setv self.ndline ndline)
                (setv self.msg    msg)))

; _____________________________________________________________________________/ }}}1

