
    (import  _fptk_local *)
    (require _fptk_local *)

    (import wy.Backend.Classes *)
    (import wy.Backend.Preparator [wycode_to_prepared_code  :as w2pc])
    (import wy.Backend.Parser     [prepared_code_to_tokens  :as pc2t])
    (import wy.Backend.Parser     [prepared_code_to_ntlines :as pc2ntls])

    ; be aware that
    ; - wy_code snippets are "prepared" first (so ■ and ☇¦ are added)
    ; - atoms are checked only by their pkind, because tkind is connected directly to it (in Parser)

    (defn wy2tokens [wy_code] (-> wy_code w2pc pc2t))
    (defn wy2ntls   [wy_code] (-> wy_code w2pc pc2ntls))

    ; 1) WyCode -> PreparedCode -> Atoms
; [F] testing machinery setup ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn print_tokens [wy_code]
        (-> wy_code
            wy2tokens
            lprint))

    (defmacro check_pkinds [test_string pkinds]
       `(assertm eq (lpluckm .pkind (wy2tokens ~test_string))
                    ~pkinds))

    (defn newline_and
        [ #^ int n
          #^ (of Union PKind (of List PKind)) pkinds]
        [PKind.NEW_LINE #* (flatten (lmul n [pkinds]))])

; _____________________________________________________________________________/ }}}1
; basic atoms ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; NEW_LINE, INDENT
    (check_pkinds "" [])
    (check_pkinds " " [PKind.NEW_LINE])
    (check_pkinds " s" [PKind.NEW_LINE PKind.INDENT PKind.WORD])

    ; NUMBER
    (check_pkinds "+1_00.2_3E-7 2 2. .2 .2_0" (newline_and 5 PKind.NUMBER))

    ; HYMACRO_MARK
    (check_pkinds "~ ' ~@ ~" (newline_and 4 PKind.HYMACRO_MARK))

    ; HYEXPR
    (check_pkinds (sconcat "~@#() ~#() ~@() '#() `#() #() `() '() ~() () "
                           "~@#{} ~#{} ~@{} '#{} `#{} #{} `{} '{} ~{} {} "         
                           "~@#[] ~#[] ~@[] '#[] `#[] #[] `[] '[] ~[] [] ")
                  (newline_and 30 PKind.HYEXPR))

    ; QSTRING, OCOMMENT
    (check_pkinds "\"pups\nriba\" ; bubr" [PKind.NEW_LINE PKind.QSTRING PKind.OCOMMENT])
    (check_pkinds "f\"frmt\" r\"rgx\" b\"byte\" \"normal\"" (newline_and 4 PKind.QSTRING))
    (check_pkinds "z\"frmt\"" [PKind.NEW_LINE PKind.WORD PKind.QSTRING])

    ; WORD, KEYWORD
    (check_pkinds ":x p: f:: ->" [PKind.NEW_LINE PKind.KEYWORD PKind.WORD PKind.WORD PKind.WORD])
    (check_pkinds "$ $PUPS" [PKind.NEW_LINE PKind.AMARKER PKind.WORD])

    ; SUGAR
    (check_pkinds "#* #** #_ #^" (newline_and 4 PKind.SUGAR))

    ; OMARKER
    (check_pkinds (str_join [  " :"   "L"    "C"   "#:"   "#C"
                               "':"  "'L"   "'C"  "'#:"  "'#C"
                               "`:"  "`L"   "`C"  "`#:"  "`#C"
                               "~:"  "~L"   "~C"  "~#:"  "~#C"
                              "~@:" "~@L"  "~@C" "~@#:" "~@#C" ]
                             :sep " ")
                  (newline_and 25 [PKind.INDENT PKind.OMARKER]))
    (check_pkinds "Love Cucumbers" (newline_and 2 PKind.WORD))

    ; DMARKER
    (check_pkinds ":: LL CC :#: C#C" (newline_and 5 PKind.DMARKER))

    ; CMARKER
    (check_pkinds "\\ \\" [PKind.NEW_LINE PKind.CMARKER PKind.INDENT  PKind.CMARKER])
    (check_pkinds "\\$\\" [PKind.NEW_LINE PKind.CMARKER PKind.AMARKER PKind.CMARKER])
    (check_pkinds "L\\x"  [PKind.NEW_LINE PKind.OMARKER PKind.CMARKER PKind.WORD])

    ; AMARKER, RMARKER, JMARKER
    (check_pkinds "$ <$ ," [PKind.NEW_LINE PKind.AMARKER PKind.RMARKER PKind.JMARKER])
    (check_pkinds "1,0" [PKind.NEW_LINE PKind.NUMBER])

    ; RMACRO
    (check_pkinds "#pups #riba" (newline_and 2 PKind.RMACRO))

; _____________________________________________________________________________/ }}}1
; random goofy string ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv random_str1 "(expr(2
                        )) \\ #_ icomment #^ annotation \"qstring
                        line2\" ; ocomment
                        f:: -> :keyword word #* args #** kwargs : :#: L ~@L ' ~@ -12_0.E+17 #rmacro")

    (setv random_str_result 
          [ PKind.NEW_LINE PKind.HYEXPR
            PKind.CMARKER PKind.SUGAR PKind.WORD PKind.SUGAR PKind.WORD PKind.QSTRING
            PKind.OCOMMENT
            PKind.NEW_LINE PKind.INDENT PKind.WORD PKind.WORD PKind.KEYWORD PKind.WORD
            PKind.SUGAR PKind.WORD PKind.SUGAR PKind.WORD PKind.OMARKER PKind.DMARKER PKind.OMARKER PKind.OMARKER
            PKind.HYMACRO_MARK PKind.HYMACRO_MARK PKind.NUMBER PKind.RMACRO])

    (check_pkinds random_str1 random_str_result)

; _____________________________________________________________________________/ }}}1
; orphan brackets ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (assertm gives_error_typeQ (wy2tokens "#( smth") WyParserError)
    (assertm gives_error_typeQ (wy2tokens "\n \n ~@#[") WyParserError)

; _____________________________________________________________________________/ }}}1

    ; 2) ... -> Atoms -> NTLines 
; ntlines ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

                               ;---  --------  -----------------  -
    (setv ntls4 (wy2ntls "000\n +2.E+7 \n \\ : \"\n\n\"x 3\n4"))

    (assertm eq (len ntls4) 4)
    (assertm eq (. (last ntls4) lineNs) #(4 6 6)) 

    (assertm eq (len (wy2ntls "\n\n\n")) 3)

; _____________________________________________________________________________/ }}}1

