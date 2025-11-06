
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import  wy.Backend.Classes *)

    (import  wy.utils.fptk_local *)
    (require wy.utils.fptk_local *)

; _____________________________________________________________________________/ }}}1

    ; UPD THIS INFO:
    ; 
    ; at this stage:
    ; - GroupStarters are having OMarkers acting as SMarkers
    ; - only ImpliedOpener and Continuator can have OMarkers, and there they can be only MMarkers
    ;   - only possible TKind here : RACont, RAOpener, DMarker, OMarker

; [util] indent level processing ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; «indent» is symbols count, «indent_level» is index in list
    (defn #^ StrictInt
        get_indent_level
        [ #^ (of List StrictInt) indents      #_ "[0 4 8 20]"
          #^ StrictInt           cur_indent
        ]
        "when can't calculate indent, will throw error
         (I don't care of what kind, i catch all of them)"
        (for [&idx (range 0 (len indents))]
             (when (= cur_indent (get indents &idx))
                   (setv outp &idx)))
        (return outp))

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
        (cond (re_test ":" atom) #((re_sub ":" "(" atom) ")")
              (re_test "L" atom) #((re_sub "L" "[" atom) "]")
              (re_test "C" atom) #((re_sub "C" "{" atom) "}")
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
                                        (try (get_indent_level prev_indents cur_indent)
                                             (except [e Exception]
                                                     (raise (WyBracketerError ndline PBMsg.bad_indent)))))
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
                                        (try (get_indent_level prev_indents cur_indent)
                                             (except [e Exception]
                                                     (raise (WyBracketerError ndline PBMsg.bad_indent)))))
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
                                        (try (get_indent_level prev_indents cur_indent)
                                             (except [e Exception]
                                                     (raise (WyBracketerError ndline PBMsg.bad_indent)))))
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
    
    (defn #^ (of List BLine)
        bracktify_ndlines
        [ #^ (of List NDLine) ndlines
        ]
        (setv _result [])
        ;
        (setv [n _ rne] (if (zerolenQ ndlines) ; rowN realrowstart realrowend
                            [0 0 0] ; case for wy2hy-ing string with 0 chars lol
                            (l> (last ndlines) .rowN (get))))
        (setv $BLANK_DL (NDLine :kind                 SKind.EmptyLine
                                :indent               0
                                :body_tokens          []
                                :rowN                 #((inc n) (inc rne) (inc rne)) 
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


