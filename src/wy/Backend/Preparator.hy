
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import  wy.Backend.Classes *)

    (import  wy.utils.fptk_local *)
    (require wy.utils.fptk_local *)

; _____________________________________________________________________________/ }}}1

    ; indent marks will be inserted like so (not further):
    ; ☇¦■■:■:■■:■■pups
    ; ☇¦■■:■:■■\■■: pups $ riba <$
    ; ☇¦■■:■:■■\■■pups
    ; 
    ; ☇¦■■:■:■■\: pups $ riba <$
    ; ☇¦■■:■:■■\pups $ riba <$
    ; ☇¦■■:■:■■:\■pups $ riba <$
    ; ☇¦■■:■:■■:\pups $ riba <$

; [F] substeps ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ str tabs_to_spaces [#^ str line] (line.expandtabs :tabsize 4))

    (defn #^ str remove_trailing_spaces [#^ str line] (line.rstrip " "))

    (defn #^ str prepend_newline_mark [#^ str line] (sconcat $NEWLINE_MARK line))

    (defn #^ str insert_indent_marks [#^ WyCodeLine line]
        ; requires rstrip to be already done to work correctly
        ;                                                  [------------------] last omarker is not required to have space before \
        (re_sub (sconcat r"^\s*(" $OMARKERS_REGEX r"\s+)*" $OMARKERS_REGEX r"?" $CMARKER_REGEX r"*\s*")
                ; group 0 is whole found string
                (fm (re_sub r"\s" $INDENT_MARK (%1.group 0)))
                line))

; _____________________________________________________________________________/ }}}1
; [I] Wycode to PreparedCode ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [] #^ PreparedCode
        wycode_to_prepared_code
        [#^ WyCode raw_wy_code]
        (->> raw_wy_code
             .splitlines ; btw, this will NOT split at literal "\n" found in source code, because it is replaced with \"\\n\"
             (lmap (p: tabs_to_spaces
                       remove_trailing_spaces
                       insert_indent_marks
                       prepend_newline_mark))
             (str_join :sep "\n")))

; _____________________________________________________________________________/ }}}1
    
