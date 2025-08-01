
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import wy.Classes *)
    (import wy.Expander [first_indent_profile])

    (import  wy._fptk_local *)
    (require wy._fptk_local *)

; _____________________________________________________________________________/ }}}1

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

