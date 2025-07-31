
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import Classes *)

    (import  _fptk_local *)
    (require _fptk_local *)

; _____________________________________________________________________________/ }}}1

; [F] decide SKind ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; |■: groupstarter
    ; |■1 continuator
    ; |■\\ continuator
    ; |■; comment
    ; |■x implied opener

    (defn #^ SKind
        decide_structural_kind
        [ #^ NTLine ntline
        ]
        (when (zerolenQ ntline.tokens) (return SKind.EmptyLine))
        ; first 2 atoms are always enough to decide on SKind:
        (setv _atoms (lpluckm .atom (cut_ ntline.tokens 1 2)))
        (setv _decider_atom (first (lreject (fm (indent_atomQ it)) _atoms)))
        ;
        (cond (ocomment_atomQ                _decider_atom) SKind.OnlyOComment
              (atom_regarded_as_continuatorQ _decider_atom) SKind.Continuator
              (omarker_atomQ                 _decider_atom) SKind.GroupStarter
              True                                          SKind.ImpliedOpener))

; _____________________________________________________________________________/ }}}1


; run ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import Preparator [wycode_to_prepared_code])
    (import Parser     [prepared_code_to_ntlines])
    (import Expander   [expand_ntlines])

    (setv _code1 "1 $ ~#: (pupos) ~#: \\ : : : 3 $ 3\n  ; riba\n\npups")

    (->> _code1
         wycode_to_prepared_code
         prepared_code_to_ntlines
         expand_ntlines
         (setv _ntlines))

    (lprint _ntlines)
    (lprint (lmap decide_structural_kind _ntlines))


; _____________________________________________________________________________/ }}}1
