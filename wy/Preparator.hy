
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import wy.Classes *)

    (import  wy._fptk_local *)
    (require wy._fptk_local *)

; _____________________________________________________________________________/ }}}1

    ; indent marks will be inserted like so (not further):
    ; ☇¦■■:■:■■\■■: pups $ riba <$
    ; ☇¦■■:■:■■\■■pups
    ; ☇¦■■:■:■■:■■pups
    ; ☇¦■■:■:■■:

; [step] many ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ StrictStr tabs_to_spaces [#^ StrictStr line] (line.expandtabs :tabsize 4))

    (defn #^ StrictStr remove_trailing_spaces [#^ StrictStr line] (line.rstrip " "))

    (defn #^ StrictStr prepend_newline_mark [#^ StrictStr line] (sconcat $NEWLINE_MARK line))

    (defn #^ StrictStr insert_indent_marks [#^ WyCodeLine line]
        ; requires rstrip to be already done to work correctly
        (re_sub (sconcat r"^\s*(" $OMARKERS_REGEX r"\s+)*" $CMARKER_REGEX r"*\s*")
                (fm (re_sub r"\s" $INDENT_MARK (%1.group 0)))
                line))

; _____________________________________________________________________________/ }}}1
; [assm] Wycode to PreparedCode ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ PreparedCode
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
    


