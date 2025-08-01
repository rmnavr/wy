
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import Classes *)

    (import sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))

    (import  _fptk_local *)
    (require _fptk_local *)

; _____________________________________________________________________________/ }}}1

    (setv $CARD0 (SBP_Card :indents     [0]
                           :brckt_stack []
                           :skind       EmptyLineDL)) 

; Part 1 — generate structural brackets

    ; utils:
; omarker to hy bracket ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of Tuple str str) #_ "[HY_OPENER   CLOSER_BRACKET]"
        omarker_to_hy_tokens
        [ #^ Token token
        ]
        ; TODO: make more efficient
        (setv opener (->> token (re.sub ":" "(")
                                (re.sub "L" "[")
                                (re.sub "C" (py "'{'"))))
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
        [ #^ (of List int) indents      #_ "[0 4 8 20]"
          #^ int           cur_indent
        ]
        (for [&idx (range 0 (len indents))]
             (when (= cur_indent (get indents &idx))
                   (setv outp &idx)))
        (try (return outp)
             (except [e Exception] (raise (Exception "can't calculate indent at some line")))))

; _____________________________________________________________________________/ }}}1

    ; for SMARKERS convertion to HYMARKERS is done here:
; process empty dline ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of Tuple SBP_Card BracketedLine)
        process_EmptyLineDL
        [ #^ SBP_Card          pcard
          #^ DeconstructedLine dline
        ]
        (setv _card  $CARD0)
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
                                           GroupStarterDL    1
                                           EmptyLineDL       0)
                    _new_indents     prev_indents)
              (< cur_indent prev_indent)
              (setv _deltaIndents    (- (dec (len prev_indents))
                                        (get_indent_level prev_indents cur_indent))
                    _levels_to_close (+ _deltaIndents
                                        (if (= prev_kind ContinuatorDL) 0 1))
                    _new_indents     (drop (neg _deltaIndents) prev_indents)))
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
; process groupstarter dline ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1
    
    (defn #^ (of Tuple SBP_Card BracketedLine)
        process_GroupStarterDL
        [ #^ SBP_Card          pcard
          #^ DeconstructedLine dline
        ]
        (setv cur_indent   dline.equiv_indent)
        (setv [opener_brckt closer_brckt]
              (omarker_to_hy_tokens dline.kind_spec.smarker)) 
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
                                           GroupStarterDL    1
                                           EmptyLineDL       0)
                    _new_indents     prev_indents)
              (< cur_indent prev_indent)
              (setv _deltaIndents    (- (dec (len prev_indents))
                                        (get_indent_level prev_indents cur_indent))
                    _levels_to_close (+ _deltaIndents
                                        (if (= prev_kind ContinuatorDL) 0 1))
                    _new_indents     (drop (neg _deltaIndents) prev_indents)))
        ;
        (setv _new_openers [opener_brckt])
        (setv [_new_closers _stack2] (take_brackets_from_stack prev_accum _levels_to_close))
        (setv _new_stack (lconcat [closer_brckt] _stack2))
        ;
        (return [ (SBP_Card      :indents     _new_indents
                                 :brckt_stack _new_stack
                                 :skind       GroupStarterDL)
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
                    _new_indents (if (= prev_kind ContinuatorDL)
                                     prev_indents
                                     (lconcat prev_indents [cur_indent])))
              (= cur_indent prev_indent)
              (setv _levels_to_close (if (= prev_kind ContinuatorDL) 0 1)
                    _new_indents prev_indents)
              (< cur_indent prev_indent)
              (setv _deltaIndents    (- (dec (len prev_indents))
                                        (get_indent_level prev_indents cur_indent))
                    _levels_to_close (+ _deltaIndents
                                        (if (= prev_kind ContinuatorDL) 0 1))
                    _new_indents     (drop (neg _deltaIndents) prev_indents)))
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
; -> process single dline ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of Tuple SBP_Card BracketedLine)
        process_single_dline
        [ #^ SBP_Card          pcard
          #^ DeconstructedLine dline
        ]
        (case (type dline.kind_spec)
              GroupStarterDL  (process_GroupStarterDL  pcard dline)
              ContinuatorDL   (process_ContinuatorDL   pcard dline)
              ImpliedOpenerDL (process_ImpliedOpenerDL pcard dline)
              OnlyOCommentDL  (process_OnlyOCommentDL  pcard dline)
              EmptyLineDL     (process_EmptyLineDL     pcard dline)))

; _____________________________________________________________________________/ }}}1
; run processor (on all lines) ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of List BracketedLine)
        run_processor
        [ #^ SBP_Card                    starting_card
          #^ (of List DeconstructedLine) dlines
        ]
        (setv _result [])
        (setv _cur_card starting_card)
        (for [&dl (lconcat dlines [$BLANK_DL])] ; extra line is added for processor to always properly close
            (setv step_result (process_single_dline _cur_card &dl))
            (setv _cur_card (first step_result))
            (_result.append (second step_result)))
        (return _result))

; _____________________________________________________________________________/ }}}1

; Part 3 — concatenate all into final HyCode

    ; for MMARKERS and DMARKDERS convertion to HYMARKERS is done here:
; insert inner bracket markers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of List Token)
        process_wymarkers_inside_body
        [ #^ (of List Token) body_tokens
        ]
        "processes mid-markers and double-markers"
        (setv _new_body [])
        (setv _postfix  "")
        (for [&t body_tokens]
             (cond (omarker_tokenQ &t)
                   (do (setv [_opener _closer] (omarker_to_hy_tokens &t))
                       (+= _new_body [_opener])
                       (setv _postfix (+ _closer _postfix)))
                   (= &t "::")
                   (+= _new_body [")" "("])
                   (= &t "LL")
                   (+= _new_body ["]" "["])
                   True
                   (+= _new_body [&t])))
        (if (= _postfix "")
            _new_body
            (lconcat _new_body [_postfix])))

; _____________________________________________________________________________/ }}}1
    ; below there are no OMARKERS left:
; smart sconcat body tokens ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ HyCodeLine
        smart_concat_body_hy_tokens
        [ #^ (of List Token) body_tokens
        ]
        "should be applied to body with wymarkers already converted to hymarkers: like '@~:' to '@~(' and 'LL' to ']' + '['"
        (when (zeroQ (len body_tokens)) (return ""))   
        ; find insert positions:
        (setv _new_body [(first body_tokens)])
        (for [[&idx &token] (enumerate (cut body_tokens 1 None))]
            (setv idx (inc &idx))
            (setv token_cur  (get body_tokens idx))
            (setv token_prev (get body_tokens (dec idx)))
            ;
            (cond ; (x
                  (and (fnot hy_bracket_tokenQ      token_cur)      ; TODO: condense
                       (     hy_opener_tokenQ       token_prev))
                  (_new_body.append &token)
                  ; ()
                  (and (     closing_bracket_tokenQ token_cur)
                       (     hy_opener_tokenQ       token_prev))
                  (_new_body.append &token)
                  ; ((
                  (and (     hy_opener_tokenQ       token_cur)
                       (     hy_opener_tokenQ       token_prev))
                  (_new_body.append &token)
                  ; )) 
                  (and (     closing_bracket_tokenQ token_cur)
                       (     closing_bracket_tokenQ token_prev))
                  (_new_body.append &token)
                  ; x)
                  (and (     closing_bracket_tokenQ token_cur)
                       (fnot hy_bracket_tokenQ      token_prev))
                  (_new_body.append &token)
                  ; all other
                  True
                  (_new_body.extend [" " &token])))
        (return (str_join _new_body :sep "")))

; _____________________________________________________________________________/ }}}1
; bline to hycodeline ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of Tuple str str str str)
        bline_to_hcodeline
        [ #^ BracketedLine bline
        ]
        (setv dline bline.dline)
        ;
        (setv _indent  (* " " dline.equiv_indent))
        (setv _openers (str_join bline.openers :sep ""))
        (setv _closers (str_join bline.closers :sep ""))
        (setv _comment (if (isnone dline.ending_comment) "" dline.ending_comment))
        (setv _body (-> dline.body_tokens process_wymarkers_inside_body
                                          smart_concat_body_hy_tokens))
        ;
        [_closers _indent (sconcat _openers _body) _comment])

; _____________________________________________________________________________/ }}}1
; assembly: blines_to_hcode ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ HyCodeFull 
        blines_to_hcode
        [ #^ (of List BracketedLine) blines
          #^ (of List int) positions #_ "should be of len-1 of blines, due to processor producing +1 extra line at the end"
        ]
        (setv _positions (lconcat positions [(last positions)]))
        (setv _hy_code "")
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


