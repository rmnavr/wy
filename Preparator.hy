
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import pyparsing :as pp)

    (import Classes *)

    (import sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))

    (require hyrule [of as-> -> ->> doto case branch unless lif do_n list_n ncut])
    (import  _hyextlink *)
    (require _hyextlink [f:: fm p> pluckm lns &+ &+> l> l>=] :readers [L])

; _____________________________________________________________________________/ }}}1

; helper funcs ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ WyCodeLine
        line_starts_with_keywordQ
        [ #^ WyCodeLine line
        ]
        (re_test r"^\s*:\w+" line))

    (defn #^ WyCodeLine
        line_consists_only_of_smarkerQ
        [ #^ WyCodeLine line
        ]
        (re_test (+ r"^(\s*)" $OMARKERS_REGEX r"(\s*)$") line))

    (defn #^ WyCodeLine
        line_starts_with_smarkerQ
        [ #^ WyCodeLine line
        ]
        (re_test (+ r"^(\s*)" $OMARKERS_REGEX r"(\s*)") line))

    (defn #^ WyCodeLine
        line_has_amarker
        [ #^ WyCodeLine line
        ]
        (re_test r"\s\$\s" line))

; _____________________________________________________________________________/ }}}1
; split at amarkers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; + splits «lmap func $ x»
    ;       to «lmap func
    ;            \x»
    ; + splits «: lmap func $ x»
    ;       to «: lmap func
    ;            \x»

    (defn #^ WyCodeLine
        split_at_amarkers
        [ #^ WyCodeLine line
        ]
        (when (or (line_starts_with_keywordQ line)
                  (not_ line_has_amarker line))
              (return line))
        (if (line_starts_with_smarkerQ line)
            ;             (gr1)  (group 2      )   (gr3)(g4)(gr5    )(g6 )(g7)
            ;example:     «___               @~:    ____|str  ___$___  data
            (re.sub (+ r"^(\s*)" $OMARKERS_REGEX r"(\s*)(.*)(\s\$\s+)(\\?)(.*)")
                    (fm 
                        (sconcat (%1.group 1) (%1.group 2) (%1.group 3) (%1.group 4) "\n"
                                 (-> (sconcat (%1.group 1) (%1.group 2) (%1.group 3))
                                     len
                                     (- (len (%1.group 6)))
                                     (* " "))
                                 (%1.group 6) (%1.group 7)))
                    line)
            ;       (gr1)(g2)(group 3)(g4)
            (re.sub r"^(\s*)(.*)(\s\$\s+)(.*)"
                    (fm 
                        (sconcat (%1.group 1) (%1.group 2) "\n"
                                 (%1.group 1) (* " " 4) (%1.group 4)))
                    line))
            )

; _____________________________________________________________________________/ }}}1
; split at smarkers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; + splits «   : pups»
    ;       to «   :
    ;                pups»
    ; (this will keep both indent levels)

    (defn #^ WyCodeLine
        split_at_smarkers
        [ #^ WyCodeLine line
        ]
        (when (or (line_consists_only_of_smarkerQ line)
                  (line_starts_with_keywordQ      line))
              (return line))
        ;             (gr1)  (group 2      )   (gr3)
        (re.sub (+ r"^(\s*)" $OMARKERS_REGEX r"(\s*)")
                (fm 
                    (sconcat (%1.group 1) (%1.group 2) "\n"
                             (%1.group 1) (* " " (len (%1.group 2))) (%1.group 3)))
                line))

; _____________________________________________________________________________/ }}}1
; insert indent marks ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; - adds at least ✠✠✠✠ to every string (requires for pyparser newline recognition)
    ; - replaces indent tabs/spaces with ✠... (performs smart indent-tabs-symbols recognition)

; ■ doc ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    ; % 4
    ;
    ; 1234 5678 9
    ; 1230 1230 1230 1230 1230
    ; TTTT|ssTT|sssT|TTTT|sTTT

    ; tab_calced_len  0 1 2 3 4 5 6 7 8 9 ...
    ; % 4             0 1 2 3 0 1 2 3 0 1 ...
    ; add_chars       4 3 2 1 4 3 2 1 4 3 ...

; ________________________________________________________________________/ }}}2

    (defn #^ WyCodeLine
        insert_indent_marks
        [ #^ WyCodeLine line
        ]
        (setv _TABL 4)
        (setv new_line [""])
        (setv tab_calced_len 0)
        (for [[&idx &char] (enumerate line)]
             (cond (= &char " ")
                   (do (+= tab_calced_len 1)
                       (new_line.append $INDENT_MARK))
                   (= &char "\t")
                   (do (setv to_add_chars (py "_TABL - (tab_calced_len % _TABL)"))
                       (+= tab_calced_len to_add_chars)
                       (new_line.append (* $INDENT_MARK to_add_chars)))
                   True
                   (do (new_line.append (cut line &idx None))
                       (break))))
        (+ $BASE_INDENT (str_join new_line :sep "")))
                        
    ; test:
    ; (insert_indent_marks   " start")
    ; (insert_indent_marks   "\tstart")
    ; (insert_indent_marks   "   \tstart")

; _____________________________________________________________________________/ }}}1

; assembly ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; TODO: make more efficient

    (defn #^ PreparedCodeFull
        prepare_code_for_pyparsing
        [ #^ WyCodeLine code
        ]
        (->> code
             ;
             .splitlines                     
             (lmap (p> split_at_amarkers (.rstrip)))        
             (str_join :sep "\n")         
             ;
             .splitlines                  
             (lmap (p> split_at_smarkers (.rstrip)))        
             (str_join :sep "\n")         
             ;
             .splitlines                  
             (lmap insert_indent_marks)   
             (str_join :sep "\n")))

; _____________________________________________________________________________/ }}}1

    

