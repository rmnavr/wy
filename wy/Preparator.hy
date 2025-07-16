
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import pyparsing :as pp)

    (import Classes *)

    (import sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))

    (import  _fptk_local *)
    (require _fptk_local *)

; _____________________________________________________________________________/ }}}1

; [steps] ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ str tabs_to_spaces [#^ str line] (line.expandtabs :tabsize 4))

    (defn #^ str remove_trailing_spaces [#^ str line] (line.rstrip " "))

    (defn #^ str replace_leading_spaces_with_indent_marks [#^ str line]
        (re_sub r"^(\s+)"
                (fm (* $INDENT_MARK (len (%1.group 1))))
                line))

    (defn #^ str prepend_base_indent [#^ str line] (sconcat $BASE_INDENT line))

    (defn #^ WyCodeLine
        insert_midspace_marks
        [ #^ WyCodeLine line
        ]
        ; requires rstrip to be already done to work correctly
        ;                 (gr1                ) (gr2          )   (gr3)
        (re_sub (sconcat "(" $INDENT_MARK r"+)" $OMARKERS_REGEX r"(\s*)")
                (fm (sconcat (%1.group 1) (%1.group 2) (* $MIDSPACE_MARK (len (%1.group 3)))))
                line))

; _____________________________________________________________________________/ }}}1

    (defn #^ PreparedCodeFull
        prepare_code_for_pyparsing
        [ #^ WyCodeFull code
        ]
        (->> code
             .splitlines ; btw, this will NOT split at literal "\n" found in source code, because it is replaced with \"\\n\"
             (lmap (p: tabs_to_spaces
                       remove_trailing_spaces
                       replace_leading_spaces_with_indent_marks
                       insert_midspace_marks
                       prepend_base_indent))
             (str_join :sep "\n")))

    (print (prepare_code_for_pyparsing " #: : lmap : 3 4 $ 7"))


