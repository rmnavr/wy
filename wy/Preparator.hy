
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import pyparsing :as pp)

    (import wy.Classes *)

    (import sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))

    (import  wy._fptk_local *)
    (require wy._fptk_local *)

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

    (defn #^ WyCodeLine
        insert_midspace_marks
        [ #^ WyCodeLine line
        ]
        ;                 (gr1                ) (gr2          )   (gr3)
        (re_sub (sconcat "(" $INDENT_MARK r"+)" $OMARKERS_REGEX r"(\s*)")
                (fm (sconcat (%1.group 1) (%1.group 2) (* $MIDSPACE_MARK (len (%1.group 3)))))
                line))

; _____________________________________________________________________________/ }}}1

; assembly ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; TODO: make more efficient

    (defn #^ PreparedCodeFull
        prepare_code_for_pyparsing
        [ #^ WyCodeLine code
        ]
        (->> code
             ;
             .splitlines ; this will NOT split at literal "\n" found in source code, because it is replaced with \"\\n\"
             (lmap insert_indent_marks)   
             (str_join :sep "\n")
             ;
             .splitlines ; this will NOT split at literal "\n" found in source code, because it is replaced with \"\\n\"
             (lmap insert_midspace_marks)   
             (str_join :sep "\n")))

; _____________________________________________________________________________/ }}}1

    
