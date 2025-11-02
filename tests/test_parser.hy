
    (import  _fptk_local *)
    (require _fptk_local *)

    (import wy.Classes *)
    (import wy.Preparator [wycode_to_prepared_code])
    (import wy.Parser     [prepared_code_to_patoms])

    ; be aware that wy_code snippets are "prepared" first (so ■ and ☇¦ are added)

; [F] testing machinery ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn print_patoms [wy_code]
        (-> wy_code
            wycode_to_prepared_code
            prepared_code_to_patoms
            lprint))

    (defmacro check_patoms [test_string atoms_list]
       `(assertm eq (lpluckm .pkind (prepared_code_to_patoms (wycode_to_prepared_code ~test_string)))
                    ~atoms_list))

    (defn newline_and
        [ #^ int n
          #^ (of Union Atom (of List Atom)) atoms]
        [PKind.NEW_LINE #* (flatten (lmul n [atoms]))])

; _____________________________________________________________________________/ }}}1

; basic atoms ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; NEW_LINE, INDENT
    (check_patoms "" [])
    (check_patoms " " [PKind.NEW_LINE])
    (check_patoms " s" [PKind.NEW_LINE PKind.INDENT PKind.WORD])

    ; NUMBER
    (check_patoms "+1_00.2_3E-7 2 2." (newline_and 3 PKind.NUMBER))

    ; HYMACRO_MARK
    (check_patoms "~ ' ~@ ~" (newline_and 4 PKind.HYMACRO_MARK))

    ; HYEXPR
    (check_patoms (sconcat "~@#() ~#() ~@() '#() `#() #() `() '() ~() () "
                           "~@#{} ~#{} ~@{} '#{} `#{} #{} `{} '{} ~{} {} "         
                           "~@#[] ~#[] ~@[] '#[] `#[] #[] `[] '[] ~[] [] ")
                  (newline_and 30 PKind.HYEXPR))

    ; QSTRING, OCOMMENT
    (check_patoms "\"pups\nriba\" ; bubr" [PKind.NEW_LINE PKind.QSTRING PKind.OCOMMENT])
    (check_patoms "f\"frmt\" r\"rgx\" b\"byte\" \"normal\"" (newline_and 4 PKind.QSTRING))
    (check_patoms "z\"frmt\"" [PKind.NEW_LINE PKind.WORD PKind.QSTRING])

    ; WORD, KEYWORD
    (check_patoms ":x p: f:: ->" [PKind.NEW_LINE PKind.KEYWORD PKind.WORD PKind.WORD PKind.WORD])

    ; SUGAR
    (check_patoms "#* #** #_ #^" (newline_and 4 PKind.SUGAR))

    ; OMARKER
    (check_patoms (str_join [  " :"   "L"    "C"   "#:"   "#C"
                               "':"  "'L"   "'C"  "'#:"  "'#C"
                               "`:"  "`L"   "`C"  "`#:"  "`#C"
                               "~:"  "~L"   "~C"  "~#:"  "~#C"
                              "~@:" "~@L"  "~@C" "~@#:" "~@#C" ]
                             :sep " ")
                  (newline_and 25 [PKind.INDENT PKind.OMARKER]))

    ; DMARKER
    (check_patoms ":: LL CC :#: C#C" (newline_and 5 PKind.DMARKER))

    ; CMARKER
    (check_patoms "\\ \\" [PKind.NEW_LINE PKind.CMARKER PKind.INDENT PKind.CMARKER])

    ; AMARKER, RMARKER, JMARKER
    (check_patoms "$ <$ ," [PKind.NEW_LINE PKind.AMARKER PKind.RMARKER PKind.JMARKER])

    ; RMACRO
    (check_patoms "#pups #riba" (newline_and 2 PKind.RMACRO))

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

    (check_patoms random_str1 random_str_result)

; _____________________________________________________________________________/ }}}1

