
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import Classes *)
    (import Bracketer [omarker_to_hy_brackets])

    (import  _fptk_local *)
    (require _fptk_local *)

; _____________________________________________________________________________/ }}}1

; insert inner bracket markers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of List Atom)
        process_wymarkers_inside_body
        [ #^ (of List Atom) body_atoms
        ]
        "processes mid-markers and double-markers"
        (setv _new_body [])
        (setv _postfix  "")
        (for [&a body_atoms]
             (cond (omarker_atomQ &a)
                   (do (setv [_opener _closer] (omarker_to_hy_brackets &a))
                       (+= _new_body [_opener])
                       (setv _postfix (+ _closer _postfix))) ; inline «:» is accumulated to be added in line ending
                   (= &a "::")
                   (+= _new_body [")" "("])
                   (= &a "LL")
                   (+= _new_body ["]" "["])
                   (= &a "CC")
                   (+= _new_body ["}" "{"])
                   True
                   (+= _new_body [&a])))
        (if (= _postfix "")
            _new_body
            (lconcat _new_body [_postfix])))

; _____________________________________________________________________________/ }}}1
; smart sconcat body atoms ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ HyCodeLine
        smart_concat_body_hy_atoms
        [ #^ (of List Atom) body_atoms
        ]
        "should be applied to body with wymarkers already converted to hymarkers: like '@~:' to '@~(' and 'LL' to ']' + '['"
        (when (zeroQ (len body_atoms)) (return ""))   
        ; find insert positions:
        (setv _new_body [(first body_atoms)])
        (for [[&idx &atom] (enumerate (cut body_atoms 1 None))]
            (setv idx (inc &idx))
            (setv atom_cur  (get body_atoms idx))
            (setv atom_prev (get body_atoms (dec idx)))
            ;
            (cond ; (x
                  (and (fnot hy_bracket_atomQ       atom_cur)      ; TODO: condense
                       (     hy_opener_atomQ        atom_prev))
                  (_new_body.append &atom)
                  ; ()
                  (and (     closing_bracket_atomQ  atom_cur)
                       (     hy_opener_atomQ        atom_prev))
                  (_new_body.append &atom)
                  ; ((
                  (and (     hy_opener_atomQ        atom_cur)
                       (     hy_opener_atomQ        atom_prev))
                  (_new_body.append &atom)
                  ; )) 
                  (and (     closing_bracket_atomQ  atom_cur)
                       (     closing_bracket_atomQ  atom_prev))
                  (_new_body.append &atom)
                  ; x)
                  (and (     closing_bracket_atomQ  atom_cur)
                       (fnot hy_bracket_atomQ       atom_prev))
                  (_new_body.append &atom)
                  ; all other
                  True
                  (_new_body.extend [" " &atom])))
        (return (str_join _new_body :sep "")))

; _____________________________________________________________________________/ }}}1
; bline to hycodeline ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of Tuple str str str str)
        bline_to_hcodeline
        [ #^ BLine bline
        ]
        (setv ndline bline.ndline)
        ;
        (setv _indent  (* " " ndline.indent))
        (setv _openers (str_join bline.this_openers :sep ""))
        (setv _closers (str_join bline.prev_closers :sep ""))
        (setv _comment (if (noneQ ndline.t_ocomment) "" ndline.t_ocomment.atom))
        (setv _body    (->> ndline.body_tokens
                            (lpluckm .atom)
                            process_wymarkers_inside_body
                            smart_concat_body_hy_atoms))
        ;
        [_closers _indent (sconcat _openers _body) _comment])

; _____________________________________________________________________________/ }}}1
; assembly: blines_to_hcode ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ HyCode
        blines_to_hcode
        [ #^ (of List BLine) blines
        ]
        (setv positions (l> blines (Each) .ndline .rowN [0] (collect)))
        (setv _positions (lconcat positions [(last positions)]))
        ;
        (setv _hy_code      "")
        (setv _prev_comment "")
        (for [[&idx &bl] (enumerate blines)]
             (setv _prev_pos (if (zeroQ &idx) None (get positions (dec &idx))))
             (setv _cur_pos  (get _positions &idx))
             (setv _currently_on_same_origRowN (= _cur_pos _prev_pos)) 
             ;
             (setv [_closers _indent _openers_and_body _comment] (bline_to_hcodeline &bl))
             (if _currently_on_same_origRowN ; for &idx=0 will give False
                 (+= _hy_code _closers " " _openers_and_body)
                 (+= _hy_code _closers _prev_comment "\n" _indent _openers_and_body))   ; for &idx=0 extra «\n» is added unwantedly
             (setv _prev_comment _comment))
        (return ((p: rest str_join) _hy_code)))                                         ; this "\n" is removed here

; _____________________________________________________________________________/ }}}1

