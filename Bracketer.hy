
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import Classes *)

    (import sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))

    (require hyrule [of as-> -> ->> doto case branch unless lif do_n list_n ncut])
    (import  _hyextlink *)
    (require _hyextlink [f:: fm p> pluckm lns &+ &+> l> l>=] :readers [L])

; _____________________________________________________________________________/ }}}1

    (setv $CARD0 (SBP_Card :indents     [$ELIN]
                           :brckt_stack []
                           :skind       EmptyLineDL)) 

; Part 1 — generate structural brackets

    ; utils:
; linestarter token to hy bracket ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of Tuple str str) #_ "opener closer"
        linestarter_marker_to_hybrackets
        [ #^ Token token
        ]
        ; TODO: make more efficient
        (setv opener (->> token (re.sub ":" "(")
                                (re.sub "L" "[")
                                (re.sub "C" (py "\"{\""))))
        (setv closer (cond (re_test ":" token) ")"
                           (re_test "L" token) "]"
                           (re_test "C" token) "}"))
        [opener closer])

; _____________________________________________________________________________/ }}}1
; take brackets from stack ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of Tuple (of List str) (of List str)) #_ "[taken_brackets new_stack]"
        take_brackets_from_stack
        [ #^ (of List str) brckt_stack
          #^ int           n
        ]
        (setv taken_brackets (cut brckt_stack 0 n))
        (setv new_stack (cut brckt_stack n None))
        (return [taken_brackets new_stack])
        )

; _____________________________________________________________________________/ }}}1
; get indent level ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; «indent» is symbols count, «indent_level» is index in list
    (defn #^ int
        get_indent_level
        [ #^ (of List int) indents      #_ "[4 8 20]"
          #^ int           cur_indent
        ]
        (for [&idx (range 0 (len indents))]
             (when (= cur_indent (get indents &idx))
                   (setv outp &idx)))
        (return outp))

; _____________________________________________________________________________/ }}}1

    ; convertion from "~@:" to "~@:" is done in these functions:
; process empty dline ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of Tuple SBP_Card BracketedLine)
        process_EmptyLineDL
        [ #^ SBP_Card          pcard
          #^ DeconstructedLine dline
        ]
        (setv _card $CARD0)
        (setv _bline (BracketedLine :dline   dline
                                    :closers pcard.brckt_stack ; closes full stack
                                    :openers []))
        (return [_card _bline]))

; _____________________________________________________________________________/ }}}1
; process ocomment dline ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of Tuple SBP_Card BracketedLine)
        process_OnlyOCommentDL
        [ #^ SBP_Card          pcard
          #^ DeconstructedLine dline
        ]
        (setv _card pcard) ; pass through previous card as is, so ocommentDL can be ignored
        (setv _bline (BracketedLine :dline   dline
                                    :closers []
                                    :openers []))
        (return [_card _bline]))

; _____________________________________________________________________________/ }}}1
; process implied opener dline ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1
    
    (defn #^ (of Tuple SBP_Card BracketedLine)
        process_ImpliedOpenerDL
        [ #^ SBP_Card          pcard
          #^ DeconstructedLine dline
        ]
        (setv cur_indent   dline.equiv_indent)
        (setv prev_indents pcard.indents)
        (setv prev_indent  (last prev_indents))
        (setv prev_accum   pcard.brckt_stack)
        (setv prev_kind    pcard.skind)
        ;
        (cond (> cur_indent prev_indent)
              (setv _levels_to_close 0
                    _new_indents     (lconcat prev_indents [cur_indent]))
              (= cur_indent prev_indent)
              (setv _levels_to_close (case prev_kind
                                           ContinuatorDL     0
                                           ImpliedOpenerDL   1
                                           LinestarterDL     1
                                           EmptyLineDL       0)
                    _new_indents     prev_indents)
              (< cur_indent prev_indent)
              (setv _deltaIndents    (- (dec (len prev_indents))
                                        (get_indent_level prev_indents cur_indent))
                    _levels_to_close (+ _deltaIndents
                                        (if (= prev_kind ContinuatorDL) 0 1))
                    _new_indents     (list (drop_last _deltaIndents prev_indents))))
        ;
        (setv _new_openers ["("])
        (setv [_new_closers _stack2] (take_brackets_from_stack prev_accum _levels_to_close))
        (setv _new_stack (lconcat [")"] _stack2))
        ;
        (return [ (SBP_Card      :indents     _new_indents
                                 :brckt_stack _new_stack
                                 :skind       ImpliedOpenerDL)
                  (BracketedLine dline
                                 _new_closers
                                 _new_openers)]))

    ; (print (process_ImpliedOpenerDL $CARD0 (DeconstructedLine (ImpliedOpenerDL) 8 ["pups"] None)))

; _____________________________________________________________________________/ }}}1
; process linestarter dline ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1
    
    (defn #^ (of Tuple SBP_Card BracketedLine)
        process_LinestarterDL
        [ #^ SBP_Card          pcard
          #^ DeconstructedLine dline
        ]
        (setv cur_indent   dline.equiv_indent)
        (setv [opener_brckt closer_brckt]
              (linestarter_marker_to_hybrackets dline.kind_spec.linestarter_token)) ; like ["~@(" ")"]
        (setv prev_indents pcard.indents)
        (setv prev_indent  (last prev_indents))
        (setv prev_accum   pcard.brckt_stack)
        (setv prev_kind    pcard.skind)
        ;
        (cond (> cur_indent prev_indent)
              (setv _levels_to_close 0
                    _new_indents     (lconcat prev_indents [cur_indent]))
              (= cur_indent prev_indent)
              (setv _levels_to_close (case prev_kind
                                           ContinuatorDL     0
                                           ImpliedOpenerDL   1
                                           LinestarterDL     1
                                           EmptyLineDL       0)
                    _new_indents     prev_indents)
              (< cur_indent prev_indent)
              (setv _deltaIndents    (- (dec (len prev_indents))
                                        (get_indent_level prev_indents cur_indent))
                    _levels_to_close (+ _deltaIndents
                                        (if (= prev_kind ContinuatorDL) 0 1))
                    _new_indents     (list (drop_last _deltaIndents prev_indents))))
        ;
        (setv _new_openers [opener_brckt])
        (setv [_new_closers _stack2] (take_brackets_from_stack prev_accum _levels_to_close))
        (setv _new_stack (lconcat [closer_brckt] _stack2))
        ;
        (return [ (SBP_Card      :indents     _new_indents
                                 :brckt_stack _new_stack
                                 :skind       LinestarterDL)
                  (BracketedLine dline
                                 _new_closers
                                 _new_openers)]))


; _____________________________________________________________________________/ }}}1
; process continuator dline ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of Tuple SBP_Card BracketedLine)
        process_ContinuatorDL
        [ #^ SBP_Card          pcard
          #^ DeconstructedLine dline
        ]
        (setv cur_indent   dline.equiv_indent)
        (setv prev_indents pcard.indents)
        (setv prev_indent  (last prev_indents))
        (setv prev_accum   pcard.brckt_stack)
        (setv prev_kind    pcard.skind)
        ;
        (cond (> cur_indent prev_indent)
              (setv _levels_to_close 0
                    _new_indents (lconcat prev_indents [cur_indent]))
              (= cur_indent prev_indent)
              (setv _levels_to_close (if (= prev_kind ContinuatorDL) 0 1)
                    _new_indents prev_indents)
              (< cur_indent prev_indent)
              (setv _deltaIndents    (- (dec (len prev_indents))
                                        (get_indent_level prev_indents cur_indent))
                    _levels_to_close (+ _deltaIndents
                                        (if (= prev_kind ContinuatorDL) 0 1))
                    _new_indents     (list (drop_last _deltaIndents prev_indents))))
        ;
        (setv [_new_closers _new_stack] (take_brackets_from_stack prev_accum _levels_to_close))
        ;
        (return [ (SBP_Card      :indents     _new_indents
                                 :brckt_stack _new_stack
                                 :skind       ContinuatorDL)
                  (BracketedLine dline
                                 _new_closers
                                 [] #_ "no new openers are created for continuator")]))

; _____________________________________________________________________________/ }}}1

; assembly: process single dline ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of Tuple SBP_Card BracketedLine)
        process_single_dline
        [ #^ SBP_Card          pcard
          #^ DeconstructedLine dline
        ]
        (case (type dline.kind_spec)
              LinestarterDL   (process_LinestarterDL   pcard dline)
              ContinuatorDL   (process_ContinuatorDL   pcard dline)
              ImpliedOpenerDL (process_ImpliedOpenerDL pcard dline)
              OnlyOCommentDL  (process_OnlyOCommentDL  pcard dline)
              EmptyLineDL     (process_EmptyLineDL     pcard dline)))

; _____________________________________________________________________________/ }}}1
; run processor ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1


    (defn #^ (of List BracketedLine)
        run_processor
        [ #^ SBP_Card                    starting_card
          #^ (of List DeconstructedLine) dlines
        ]
        (setv _result [])
        (setv _cur_card starting_card)
        (for [&dl dlines]
            (setv step_result (process_single_dline _cur_card &dl))
            (setv _cur_card (first step_result))
            (_result.append (second step_result)))
        (return _result))

; _____________________________________________________________________________/ }}}1

; Part 3 — concatenate all into final HyCode

; work on inner bracket markers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1


; _____________________________________________________________________________/ }}}1
; bline to hycodeline ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ HyCodeLine
        bline_to_hcodeline
        [ #^ BracketedLine bline
        ]
        (setv dline bline.dline)
        ;
        (setv _indent  (* " " dline.equiv_indent))
        (setv _openers (str_join bline.openers     :sep ""))
        (setv _closers (str_join bline.closers     :sep ""))
        (setv _body    (str_join dline.body_tokens :sep " "))
        (setv _comment (if (isnone dline.ending_comment) "" dline.ending_comment))
        (sconcat _indent _openers _body _closers _comment)
        )

; _____________________________________________________________________________/ }}}1
