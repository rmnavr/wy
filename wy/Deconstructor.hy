
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import Classes *)
    (import Expander [first_indent_profile])

    (import  _fptk_local *)
    (require _fptk_local *)

; _____________________________________________________________________________/ }}}1

; Deconstructor
; [F] decide SKind :: NTLine -> SKind ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; |■:  groupstarter
    ; |■1  continuator
    ; |■\\ continuator
    ; |■;  comment
    ; |■x  implied opener

    (defn [validateF] #^ SKind
        decide_structural_kind
        [ #^ NTLine ntline
        ]
        (when (zerolenQ ntline.tokens) (return SKind.EmptyLine))
        ; first 2 tokens are always enough to decide on SKind:
        (setv _tokens (cut_ ntline.tokens 1 2))
        (setv _decider_token
              (first
                     (lreject (fm (eq_any it.kind [TKind.Indent TKind.NegIndent]))
                              _tokens)))
        ;
        (cond (eq     _decider_token.kind TKind.OComment)
              SKind.OnlyOComment
              ;
              (eq_any _decider_token.kind [TKind.RACont TKind.CMarker])
              SKind.Continuator
              ;
              (eq     _decider_token.kind TKind.OMarker )
              SKind.GroupStarter
              ;
              True
              SKind.ImpliedOpener))

; _____________________________________________________________________________/ }}}1
; [F] ntl2ndl :: NTLine -> NDLine ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ (of list NDLine)
        deconstruct_ntlines
        [ #^ (of list NTLine) ntlines
        ]
        (lmap ntl2ndl ntlines))

    (defn [validateF] #^ NDLine
        ntl2ndl
        [ #^ NTLine ntline
        ]
        (case (decide_structural_kind ntline)
              SKind.EmptyLine     (build_ndl_EL ntline)
              SKind.GroupStarter  (build_ndl_GS ntline)
              SKind.OnlyOComment  (build_ndl_OC ntline)
              SKind.ImpliedOpener (build_ndl_IO ntline)
              SKind.Continuator   (build_ndl_C  ntline)))

; ■ build_ndl_EL ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (defn [validateF] #^ NDLine
        build_ndl_EL
        [ #^ NTLine ntline
        ]
        (NDLine :kind        SKind.EmptyLine
                :indent      0
                :body_tokens []
                :rowN        #(ntline.rowN ntline.realRowN_start ntline.realRowN_end)
                :t_smarker   None
                :t_ocomment  None))


; ________________________________________________________________________/ }}}2
; ■ build_ndl_GS ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (defn [validateF] #^ NDLine
        build_ndl_GS
        [ #^ NTLine ntline
        ]
        "can only have: indent/negindent + smarker (even ocomment is expanded on another line, so GS can't have it)"
        (setv _smarker (fltr1st (fm (eq it.kind TKind.OMarker)) ntline.tokens))  ; must be found
        (NDLine :kind        SKind.GroupStarter
                :indent      (sum (first_indent_profile ntline.tokens))
                :body_tokens []
                :rowN        #(ntline.rowN ntline.realRowN_start ntline.realRowN_end)
                :t_smarker   _smarker
                :t_ocomment  None))

; ________________________________________________________________________/ }}}2
; ■ build_ndl_OC ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (defn [validateF] #^ NDLine
        build_ndl_OC
        [ #^ NTLine ntline
        ]
        "can only have: indent/negindent + ocomment"
        (setv _ocomment (fltr1st (fm (eq it.kind TKind.OComment)) ntline.tokens))  ; must be found
        (NDLine :kind        SKind.OnlyOComment
                :indent      (sum (first_indent_profile ntline.tokens))
                :body_tokens []
                :rowN        #(ntline.rowN ntline.realRowN_start ntline.realRowN_end)
                :t_smarker   None
                :t_ocomment  _ocomment))

; ________________________________________________________________________/ }}}2
; ■ build_ndl_IO ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (defn [validateF] #^ NDLine
        build_ndl_IO
        [ #^ NTLine ntline
        ]
        (->> ntline.tokens
             (dropwhile  (fm (eq_any it.kind [TKind.Indent TKind.NegIndent])))
             (lbisect_by (fm (neq    it.kind TKind.OComment)))
             (setv [_body_list _ocomment_list]))
        (NDLine :kind        SKind.ImpliedOpener
                :indent      (sum (first_indent_profile ntline.tokens))
                :body_tokens _body_list
                :rowN        #(ntline.rowN ntline.realRowN_start ntline.realRowN_end)
                :t_smarker   None
                :t_ocomment  (first _ocomment_list))) ; can be None

; ________________________________________________________________________/ }}}2
; ■ build_ndl_C  ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (defn [validateF] #^ NDLine
        build_ndl_C
        [ #^ NTLine ntline
        ]
        (->> ntline.tokens
             (dropwhile  (fm (eq_any it.kind [TKind.Indent TKind.NegIndent TKind.CMarker])))
             (lbisect_by (fm (neq    it.kind TKind.OComment)))
             (setv [_body_list _ocomment_list]))
        (NDLine :kind        SKind.Continuator
                :indent      (sum (first_indent_profile ntline.tokens))
                :body_tokens _body_list
                :rowN        #(ntline.rowN ntline.realRowN_start ntline.realRowN_end)
                :t_smarker   None
                :t_ocomment  (first _ocomment_list))) ; can be None

; ________________________________________________________________________/ }}}2

; _____________________________________________________________________________/ }}}1

; ======= ↓ refactor from here ↓ =======

; Bracketer
; Info ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

; at this stage:
; - GroupStarters are having OMarkers acting as SMarkers
; - only ImpliedOpener and Continuator can have OMarkers, and there they can be only MMarkers
;   - only possible TKind here : RACont, RAOpener, DMarker, OMarker

; _____________________________________________________________________________/ }}}1
; [util] indent level processing ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; «indent» is symbols count, «indent_level» is index in list
    (defn #^ StrictInt
        get_indent_level
        [ #^ (of List StrictInt) indents      #_ "[0 4 8 20]"
          #^ StrictInt           cur_indent
        ]
        (for [&idx (range 0 (len indents))]
             (when (= cur_indent (get indents &idx))
                   (setv outp &idx)))
        (try (return outp)
             (except [e Exception] (raise (Exception "can't calculate indent at some line")))))

    (defn #^ (of Tuple (of List Atom) (of List Atom)) #_ "[taken_brackets new_stack]"
        take_brackets_from_stack
        [ #^ (of List Atom) brckt_stack
          #^ int            n
        ]
        (setv taken_brackets (cut brckt_stack 0 n))
        (setv new_stack (cut brckt_stack n None))
        (return [taken_brackets new_stack]))

; _____________________________________________________________________________/ }}}1
; [util] omarker to hy tokens ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ (of Tuple StrictStr StrictStr) #_ "[HY_OPENER CLOSER_BRACKET]"
        omarker_to_hy_brackets
        [ #^ Atom atom
        ]
        (cond (re_test ":" atom) #((re_sub ":" "("        atom) ")")
              (re_test "L" atom) #((re_sub "L" "["        atom) "]")
              (re_test "C" atom) #((re_sub "C" (py "'{'") atom) "}")
              True               (print "used not on omarker atom! how?")))

; _____________________________________________________________________________/ }}}1
; [F] ndlines2blines ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1
  

    (defn [validateF] #^ (of Tuple NDLineInfo BLine)
        process_one_ndline
        [ #^ NDLineInfo pcard  ; info on previous ndline
          #^ NDLine     ndline
        ]
        (cond (eq ndline.kind SKind.GroupStarter)  (process_GS pcard ndline)
              (eq ndline.kind SKind.Continuator)   (process_C  pcard ndline)
              (eq ndline.kind SKind.ImpliedOpener) (process_IO pcard ndline)
              (eq ndline.kind SKind.OnlyOComment)  (process_OC pcard ndline)
              (eq ndline.kind SKind.EmptyLine)     (process_EL pcard ndline)))

; ■ EL ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (defn [validateF] #^ (of Tuple NDLineInfo BLine)
        process_EL
        [ #^ NDLineInfo pcard
          #^ NDLine     ndline
        ]
        #( (NDLineInfo :indents      [0]
                       :brckt_stack  []
                       :kind         SKind.EmptyLine)
           ;
           (BLine      :ndline       ndline
                       :prev_closers pcard.brckt_stack ; close full stack
                       :this_openers []    )))

; ________________________________________________________________________/ }}}2
; ■ OC ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (defn [validateF] #^ (of Tuple NDLineInfo BLine)
        process_OC
        [ #^ NDLineInfo pcard
          #^ NDLine     ndline
        ]
        #( pcard ; pass through previous cars as is
           ;
           (BLine      :ndline       ndline
                       :prev_closers [] 
                       :this_openers []    )))

; ________________________________________________________________________/ }}}2
; ■ IO ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (defn [validateF] #^ (of Tuple NDLineInfo BLine)
        process_IO
        [ #^ NDLineInfo pcard
          #^ NDLine     ndline
        ]
        (setv cur_indent   ndline.indent)
        (setv prev_indents pcard.indents)
        (setv prev_indent  (last prev_indents))
        (setv prev_accum   pcard.brckt_stack)
        (setv prev_kind    pcard.kind)
        ;
        (cond (> cur_indent prev_indent)
              (setv _levels_to_close 0
                    _new_indents (lconcat prev_indents [cur_indent]))
              (= cur_indent prev_indent)
              (setv _levels_to_close (case prev_kind
                                           SKind.Continuator     0
                                           SKind.ImpliedOpener   1
                                           SKind.GroupStarter    1
                                           SKind.EmptyLine       0)
                    _new_indents     prev_indents)
              (< cur_indent prev_indent)
              (setv _deltaIndents    (- (dec (len prev_indents))
                                        (get_indent_level prev_indents cur_indent))
                    _levels_to_close (+ _deltaIndents
                                        (if (= prev_kind SKind.Continuator) 0 1))
                    _new_indents     (drop (neg _deltaIndents) prev_indents)))
        ;
        (setv _new_openers ["("])
        (setv [_new_closers _stack2] (take_brackets_from_stack prev_accum _levels_to_close))
        (setv _new_stack (lconcat [")"] _stack2))
        ;
        (return #( (NDLineInfo    :indents      _new_indents
                                  :brckt_stack  _new_stack
                                  :kind         SKind.ImpliedOpener)
                                  ;
                   (BLine         :ndline       ndline
                                  :prev_closers _new_closers
                                  :this_openers _new_openers))))

; ________________________________________________________________________/ }}}2
; ■ GS ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (defn [validateF] #^ (of Tuple NDLineInfo BLine)
        process_GS
        [ #^ NDLineInfo pcard
          #^ NDLine     ndline
        ]
        (setv cur_indent   ndline.indent)
        (setv [opener_brckt closer_brckt]
              (omarker_to_hy_brackets ndline.t_smarker.atom)) 
        (setv prev_indents pcard.indents)
        (setv prev_indent  (last prev_indents))
        (setv prev_accum   pcard.brckt_stack)
        (setv prev_kind    pcard.kind)
        ;
        (cond (> cur_indent prev_indent)
              (setv _levels_to_close 0
                    _new_indents     (lconcat prev_indents [cur_indent]))
              (= cur_indent prev_indent)
              (setv _levels_to_close (case prev_kind
                                           SKind.Continuator     0
                                           SKind.ImpliedOpener   1
                                           SKind.GroupStarter    1
                                           SKind.EmptyLine       0)
                    _new_indents     prev_indents)
              (< cur_indent prev_indent)
              (setv _deltaIndents    (- (dec (len prev_indents))
                                        (get_indent_level prev_indents cur_indent))
                    _levels_to_close (+ _deltaIndents
                                        (if (= prev_kind SKind.Continuator) 0 1))
                    _new_indents     (drop (neg _deltaIndents) prev_indents)))
        ;
        (setv _new_openers [opener_brckt])
        (setv [_new_closers _stack2] (take_brackets_from_stack prev_accum _levels_to_close))
        (setv _new_stack (lconcat [closer_brckt] _stack2))
        ;
        (return #( (NDLineInfo    :indents      _new_indents
                                  :brckt_stack  _new_stack
                                  :kind         SKind.GroupStarter)
                                  ;
                   (BLine         :ndline       ndline
                                  :prev_closers _new_closers
                                  :this_openers _new_openers))))

; ________________________________________________________________________/ }}}2
; ■ C ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (defn [validateF] #^ (of Tuple NDLineInfo BLine)
        process_C
        [ #^ NDLineInfo pcard  ; info on previous ndline
          #^ NDLine     ndline
        ]
        (setv cur_indent   ndline.indent)
        (setv prev_indents pcard.indents)
        (setv prev_indent  (last prev_indents))
        (setv prev_accum   pcard.brckt_stack)
        (setv prev_kind    pcard.kind)
        ;
        (cond (> cur_indent prev_indent)
              (setv _levels_to_close 0
                    _new_indents (if (= prev_kind SKind.Continuator)
                                     prev_indents
                                     (lconcat prev_indents [cur_indent])))
              (= cur_indent prev_indent)
              (setv _levels_to_close (if (= prev_kind SKind.Continuator) 0 1)
                    _new_indents prev_indents)
              (< cur_indent prev_indent)
              (setv _deltaIndents    (- (dec (len prev_indents))
                                        (get_indent_level prev_indents cur_indent))
                    _levels_to_close (+ _deltaIndents
                                        (if (= prev_kind SKind.Continuator) 0 1))
                    _new_indents     (drop (neg _deltaIndents) prev_indents)))
        ;
        (setv [_new_closers _new_stack] (take_brackets_from_stack prev_accum _levels_to_close))
        ;
        (return #( (NDLineInfo    :indents      _new_indents
                                  :brckt_stack  _new_stack
                                  :kind         SKind.Continuator)
                                  ;
                   (BLine         :ndline       ndline
                                  :prev_closers _new_closers
                                  :this_openers [] #_ "no new openers are created for continuator"))))

; ________________________________________________________________________/ }}}2

; _____________________________________________________________________________/ }}}1
; [F] assm ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv $LINE0INFO (NDLineInfo :indents      [0]
                                 :brckt_stack  []
                                 :kind         SKind.EmptyLine)) 

    (setv $BLANK_DL (NDLine :kind                 SKind.EmptyLine
                            :indent               0
                            :body_tokens          []
                            :rowN                 #(0 0 0)
                            ;
                            :t_smarker            None
                            :t_ocomment           None))

    ; TODO: last extra BLANK_DL has to have correct rowN
    (defn #^ (of List BLine)
        bracktify_ndlines
        [ #^ (of List NDLine) ndlines
        ]
        (setv _result [])
        ;
        (setv extraN (if (zerolenQ ndlines)
                         0
                         (l> (last ndlines) .rowN [0] (get))))
        (setv $BLANK_DL (NDLine :kind                 SKind.EmptyLine
                                :indent               0
                                :body_tokens          []
                                :rowN                 #((inc extraN) 0 0)
                                ;
                                :t_smarker            None
                                :t_ocomment           None))
        ;
        (setv _cur_card $LINE0INFO)
        (for [&ndl (lconcat ndlines [$BLANK_DL])] ; extra ndline is added for processor to always properly close
            (setv step_result (process_one_ndline _cur_card &ndl))
            (setv _cur_card (first step_result))
            (_result.append (second step_result)))
        (return _result))

; _____________________________________________________________________________/ }}}1

; Writer
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

; run ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import Preparator [wycode_to_prepared_code])
    (import Parser     [prepared_code_to_ntlines])
    (import Expander   [expand_ntlines])

    (setv _wy_code (read_file "..\\tests\\_test6_TT.wy"))

    (dt_print)
    (->> _wy_code
         wycode_to_prepared_code
         prepared_code_to_ntlines
         expand_ntlines
         deconstruct_ntlines
         bracktify_ndlines
         blines_to_hcode
         print)
    (dt_print)

; _____________________________________________________________________________/ }}}1

