
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import wy.Backend.Classes *)
    (import wy.Backend.Expander [first_indent_profile])
    (import wy.Backend.Expander [decide_structural_kind])

    (require wy.utils.fptk_local.loader [load_fptk])
    (load_fptk "core")

; _____________________________________________________________________________/ }}}1

; [F] ntl2ndl :: NTLine -> NDLine ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1


    (defn [] #^ NDLine
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

    (defn [] #^ NDLine
        build_ndl_EL
        [ #^ NTLine ntline
        ]
        (NDLine :kind        SKind.EmptyLine
                :indent      0
                :body_tokens []
                :rowN        ntline.lineNs
                :t_smarker   None
                :t_ocomment  None))


; ________________________________________________________________________/ }}}2
; ■ build_ndl_GS ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (defn [] #^ NDLine
        build_ndl_GS
        [ #^ NTLine ntline
        ]
        "can only have: indent/negindent + smarker (even ocomment is expanded on another line, so GS can't have it)"
        (setv _smarker
              (fltr1st (fm (eq it.tkind TKind.SMarker))
                       ntline.tokens))  ; must be found
        (NDLine :kind        SKind.GroupStarter
                :indent      (sum (first_indent_profile ntline.tokens))
                :body_tokens []
                :rowN        ntline.lineNs
                :t_smarker   _smarker
                :t_ocomment  None))

; ________________________________________________________________________/ }}}2
; ■ build_ndl_OC ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (defn [] #^ NDLine
        build_ndl_OC
        [ #^ NTLine ntline
        ]
        "can only have: indent/negindent + ocomment"
        (setv _ocomment
              (fltr1st (fm (eq it.tkind TKind.OComment))
                       ntline.tokens))  ; must be found
        (NDLine :kind        SKind.OnlyOComment
                :indent      (sum (first_indent_profile ntline.tokens))
                :body_tokens []
                :rowN        ntline.lineNs
                :t_smarker   None
                :t_ocomment  _ocomment))

; ________________________________________________________________________/ }}}2
; ■ build_ndl_IO ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (defn [] #^ NDLine
        build_ndl_IO
        [ #^ NTLine ntline
        ]
        (->> ntline.tokens
             (dropwhile  (fm (eq_any it.tkind [TKind.Indent TKind.NegIndent])))
             (lbisect_by (fm (neq    it.tkind TKind.OComment)))
             (setv [_body_list _ocomment_list])) ; this list is expected to be of 0 or 1 elem
        (NDLine :kind        SKind.ImpliedOpener
                :indent      (sum (first_indent_profile ntline.tokens))
                :body_tokens _body_list
                :rowN        ntline.lineNs
                :t_smarker   None
                :t_ocomment  (first _ocomment_list))) ; can be None

; ________________________________________________________________________/ }}}2
; ■ build_ndl_C  ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (defn [] #^ NDLine
        build_ndl_C
        [ #^ NTLine ntline
        ]
        (->> ntline.tokens
             (dropwhile  (fm (eq_any it.tkind [TKind.Indent TKind.NegIndent TKind.CMarker])))
             (lbisect_by (fm (neq    it.tkind TKind.OComment)))
             (setv [_body_list _ocomment_list]))
        (NDLine :kind        SKind.Continuator
                :indent      (sum (first_indent_profile ntline.tokens))
                :body_tokens _body_list
                :rowN        ntline.lineNs
                :t_smarker   None
                :t_ocomment  (first _ocomment_list))) ; can be None

; ________________________________________________________________________/ }}}2

; _____________________________________________________________________________/ }}}1
; [F] check_ndlines (error-thrower) ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [] #^ None
        check_ndlines
        [ #^ (of List NDLine) ndlines
        ]
        "checks if there is no indent increase after continuator,
         which can happen in 2 cases:
         - \\x \n    y
         - \\x $ y
         ;
         throws errors when bad indent found; returns None when no errors found
         "
        (for [[&l1 &l2] (pairwise (reject (fm (eq it.kind SKind.OnlyOComment)) ndlines))]
             (when (and (eq &l1.kind SKind.Continuator)
                        (eq_any &l2.kind [SKind.Continuator SKind.GroupStarter SKind.ImpliedOpener])
                        (> &l2.indent &l1.indent))
                   (setv isOnOneliner (eq &l1.rowN &l2.rowN))
                   (setv msg (if isOnOneliner
                                 (PBMsg.f_bad_oneL_appl
                                     (str_join (lconcat (if (eq (. (first &l1.body_tokens) tkind) TKind.RAOpener)
                                                            ["\\"]
                                                            [])
                                                        (lmapm (getattrm it .atom) &l1.body_tokens))
                                               :sep " "))
                                 PBMsg.bad_cont_indent))
                   (raise (WyDeconstructorError :ndline1 &l1
                                                :ndline2 &l2
                                                :msg     msg)))))

; _____________________________________________________________________________/ }}}1
; [F] assembly: deconstruct ntlines ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [] #^ (of List NDLine)
        deconstruct_ntlines
        [ #^ (of List NTLine) ntlines
        ]
        (setv ndlines (lmap ntl2ndl ntlines))
        (check_ndlines ndlines) ; throws error when problem found
        ndlines)

; _____________________________________________________________________________/ }}}1

