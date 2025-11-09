
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import pyparsing :as pp)
    (import funcy)

    (import wy.Backend.Classes *)

    (import  wy.utils.fptk_local *)
    (require wy.utils.fptk_local *)

; _____________________________________________________________________________/ }}}1

; === operations on not-yet expanded ntlines: ===

; [F] omarkers to s/m-markers :: NTLine -> NTLine ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; SMARKERs can be only at:
    ; - line start (after NEWLINE and INDENT)
    ; - immediately after SMARKER
    ; - immediately after AMARKER/RMARKER/JMARKER
    ; // OMARKER at every other position is MMARKER

    (defn [validateF] #^ NTLine
        classify_omarkers
        [ #^ NTLine ntline
        ]
        (setv _tokens ntline.tokens)
        ;
        (setv _forbid_smarker False)
        (for [[&n &t] (enumerate _tokens)]
            (if (eq &t.tkind TKind.OMarker)
                (if (falseQ _forbid_smarker)
                    (setv (. (get _tokens &n) tkind) TKind.SMarker)
                    (setv (. (get _tokens &n) tkind) TKind.MMarker))
                (if (eq_any &t.tkind [TKind.SMarker TKind.AMarker TKind.RMarker TKind.JMarker])
                    (setv _forbid_smarker False)
                    (unless (eq &t.tkind TKind.Indent)
                            (setv _forbid_smarker True))))) ; NegIndent is not existing at this moment
        (return (NTLine :lineNs ntline.lineNs
                        :tokens _tokens)))

; _____________________________________________________________________________/ }}}1
; [F] check correct syntax ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; CMARKER can be only at:
    ; - line start
    ; - immediately after SMARKER/AMARKER/RMARKER/JMARKER

    ; Other checks:
    ; - Forbid solo elem on line:  [\ $ <$ ,]
    ; - Forbid line starting with: [  $ <$ ,]
    ; - Forbid line ending with:   [\ $    ,]
    ; - [\ $ ,] cannot be right before [$ <$ ,]
    ; - <$      cannot be right before [$ ,] 

    (defn [validateF] #^ (of List Token)
        remove_non_check_relevant_tokens
        [ #^ (of List Token) tokens
        ]
        "does nothing if no comment found"
        (lreject (fm (eq_any it.tkind
                             [TKind.OComment TKind.Indent])) ; NewLine is already removed at this stage
                 tokens)) ; NegIndent is not existing at this moment


    (defn [validateF] #^ None
        check_syntax
        [ #^ NTLine ntline
        ]
        "throws errors when bad syntax found;
         returns None when no errors found;
         /this function should be done after SMARKERs and MMARKERs are classified/
         "
        (setv _tokens (remove_non_check_relevant_tokens ntline.tokens))
        (when (oflenQ 0 _tokens) (return None))
        ; forbid solo [\ $ <$ , DMARKER] on line
        (when (oflenQ 1 _tokens)
              (if (eq_any (. (first _tokens) tkind)
                          [TKind.CMarker TKind.AMarker TKind.RMarker TKind.JMarker TKind.DMarker])
                  (raise (WyExpanderError :ntline ntline :msg (PBMsg.f_bad_solo (. (first _tokens) atom))))
                  (return None)))
        ; forbid lines starting with [$ <$ , DMARKER]
        (when (eq_any (. (first _tokens) tkind) [TKind.AMarker TKind.RMarker TKind.JMarker TKind.DMarker])
              (raise (WyExpanderError :ntline ntline :msg (PBMsg.f_bad_start (. (first _tokens) atom)) )))
        ; forbid lines ending with [\ $ , DMARKER]
        (when (eq_any (. (last _tokens) tkind) [TKind.CMarker TKind.AMarker TKind.JMarker TKind.DMarker])
              (raise (WyExpanderError :ntline ntline :msg (PBMsg.f_bad_end (. (last _tokens) atom)))))
        ;
        (for [[&fst &snd] (pairwise _tokens)]
             ; forbid SMARKER (but not MMARKER) right before [$ <$ ,] 
             (when (and (eq     &fst.tkind TKind.SMarker)
                        (eq_any &snd.tkind [TKind.AMarker TKind.RMarker TKind.JMarker]))
                   (raise (WyExpanderError :ntline ntline :msg (PBMsg.f_bad_2s &fst.atom &snd.atom))))
             ; forbid [\ $ ,] before [$ <$ ,]
             (when (and (eq_any &fst.tkind [TKind.CMarker TKind.AMarker TKind.JMarker])
                        (eq_any &snd.tkind [TKind.AMarker TKind.RMarker TKind.JMarker]))
                   (raise (WyExpanderError :ntline ntline :msg (PBMsg.f_bad_2 &fst.atom &snd.atom))))
             ; forbid <$ before [$ ,] 
             (when (and (eq &fst.tkind TKind.RMarker)
                        (eq_any &snd.tkind [TKind.AMarker TKind.JMarker]))
                   (raise (WyExpanderError :ntline ntline :msg (PBMsg.f_bad_2 &fst.atom &snd.atom))))
             ; forbid \ after anything except [SMARKER $ <$ ,]
             (when (and (eq &snd.tkind TKind.CMarker)
                        (fnot eq_any &fst.tkind [TKind.SMarker TKind.AMarker TKind.RMarker TKind.JMarker]))
                   (raise (WyExpanderError :ntline ntline :msg (PBMsg.f_bad_cont &fst.atom)))))
        ;
        (return None))

; _____________________________________________________________________________/ }}}1

; === expansion: ===

; info: what S/A/R/J-markers do ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; SMARKER:
    ; : : x   | :
    ;         |   :
    ;         |     x   ; indents length: infer indents of top line

    ; AMARKER:
    ; x $ y $ z | x
    ;           |   y   
    ;           |     z ; indents length: see guaranteed_excessive_len_of_line and $A_INDENT_LEN

    ; RMARKERS:
    ; f <$ x <$ y         | : : f
    ;                     |     x
    ;                     |   y  
    ;
    ;\f <$\x <$\y         | : :\f
    ;                     |    \x
    ;                     |  \y  

; _____________________________________________________________________________/ }}}1

; Utils used by all expanding steps:
; [util] APL ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn transfer_to_left
        [list1 list2]
        "[1 2 3] [a b c] -> [1 2 3 a] [b c]"
        (return [ (lconcat list1 [(get list2 0)])
                  (cut_ list2 2 -1)
                ]))

; _____________________________________________________________________________/ }}}1
; [util] for Token ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ StrictInt
        tlen
        [#^ Token token]
        (when (eq token.tkind TKind.NegIndent) (return -1))
        (return (len token.atom)))

    (defn [validateF] #^ Token
        indent_token
        [#^ StrictInt indent_len]
        "converts number 3 to Token with atom '■■■'"
        (Token (smul $INDENT_MARK indent_len) PKind.INDENT TKind.Indent))

    (defn [validateF] #^ Token
        tokens_to_indent_token
        [#^ (of List Token) tokens]
        "converts tokens with atoms ['■', '~:'] to Token with atom '■■■'"
        (indent_token (sum (lmap tlen tokens))))

    (defn [validateF] #^ (of List Token)
        prepend_indent_token
        [ #^ StrictInt       indent_len
          #^ (of List Token) tokens
        ]
        " 1 + ['■', ...] will give ['■■', ...] ;
          1 + ['smth'] will give ['■', 'smth']
        "
        (when (zerolenQ tokens)
              (return [(indent_token indent_len)]))
        ;
        (setv token1 (first tokens))
        (if (= token1.tkind TKind.Indent)
            (lconcat [(indent_token (plus (tlen token1) indent_len))]
                     (cut_ tokens 2 -1))
            (lconcat [(indent_token indent_len)]
                     tokens)))

    (defn [validateF] #^ (of Tuple StrictInt StrictInt StrictInt)
        first_indent_profile
        [ #^ (of List Token) tokens
        ]
        " returns 3 numbers:
          - indent token len (>0 if present) (-1 for NegIndent)
          - continuator (0 if not present, 1 if present)
          - indent token len (>0 if present)
          ;
          possible cases:
          |         0 0 0
          |x        0 0 0
          |■■       2 0 0
          |⎤x       0 1 0   ; ⎤ is continuator in this notation
          |■■x      2 0 0
          |⎤■■x     0 1 2
          |■■⎤x     2 1 0
          |■■⎤■■x   2 1 2
          ;
          - x may be anything except indent, even smarkers
        "
        (setv indent_tokens (list (takewhile (fm (or (= it.tkind TKind.Indent)
                                                     (= it.tkind TKind.CMarker)))
                                             tokens)))
        (when (gt (len indent_tokens) 3)
              (raise (SyntaxError "this error should be impossible by code flow logic lol")))
        (case (len indent_tokens)
              0
              #(0 0 0)
              ;
              1
              (do (setv token1 (first tokens))
                  (if (eq_any token1.tkind [TKind.Indent TKind.NegIndent])
                      #((tlen token1) 0 0)
                      #(0 1 0)))
              ;
              2
              (do (setv token1 (first  tokens))
                  (setv token2 (second tokens))
                  (if (eq_any token1.tkind [TKind.Indent TKind.NegIndent])
                      #((tlen token1) 1 0)
                      #(0 1 (tlen token2))))
              ;
              3
              (do (setv token1 (first  tokens))
                  (setv token2 (second tokens))
                  (setv token3 (third  tokens))
                  #((tlen token1) 1 (tlen token3)))))

; _____________________________________________________________________________/ }}}1

; SMARKERs:
; [F] expand smarkers :: NTLine -> [NTLine ...] ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ (of List NTLine)
        expand_smarkers
        [ #^ NTLine ntline
        ]
        (setv _new_lines [ntline])
        ;
        (while (ntline_has_smarker_for_expandingQ (last _new_lines))
               (setv _new_lines
                     (lconcat (butlast _new_lines)
                              (expand_one_smarker (last _new_lines)))))
        (return _new_lines))

    (defn [validateF] #^ (of List NTLine)
        expand_one_smarker
        [#^ NTLine ntline]
        "when no smarker is found, return source [ntline],
         otherwise return [ntline1, ntline2]"
        (unless (ntline_has_smarker_for_expandingQ ntline) (return [ntline]))
        ;
        (setv [ntline1_tokens ntline2_tokens]
              (transfer_to_left #*
                    (lbisect_by (fm (neq it.tkind TKind.SMarker))
                                ntline.tokens)))
        (setv ntline2_tokens
              (prepend_indent_token (tlen (tokens_to_indent_token ntline1_tokens))
                                    ntline2_tokens))
        ;
        (lmapm (NTLine :lineNs ntline.lineNs
                       :tokens it)
               [ntline1_tokens ntline2_tokens]))

    (defn [validateF] #^ bool
        ntline_has_smarker_for_expandingQ
        [#^ NTLine ntline]
        "True for ['■', ':', ...] and [':', ...] ntlines;
         checks only head of the tokens list
         ;
         by this logic [':'] has smarker, but expansion is not required for it"
        (when (<= (len ntline.tokens) 2) (return False))
        (setv token1 (first  ntline.tokens))
        (setv token2 (second ntline.tokens))
        ;
        (cond (and (eq token1.tkind TKind.Indent)
                   (eq token2.tkind TKind.SMarker))
              True
              ;
              (eq token1.tkind TKind.SMarker)
              True
              ;
              True
              False))

; _____________________________________________________________________________/ }}}1

; check on smarker-expanded lines:
; [F] check indent after oneliners ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ None
        check_indent_after_oneliners
        [ #^ (of List NTLine) ntlines
        ]
        "should be done immediately after smarkers expansion;
         will raise error when found and return None otherwise;
         ;
         forbids things like
         | x <$ y
         |  3
         but allows for
         | : x <$ y
         |   3
         "
         (setv blocks ; blocks of ntlines without comments
             (lmulticut_by (fm
                               (eq (decide_structural_kind it)
                                   SKind.EmptyLine))
                           (lreject
                               (fm
                                   (eq (decide_structural_kind it)
                                       SKind.OnlyOComment))
                               ntlines)
                           :keep_border  False
                           :merge_border True))
        ;
        (for [&block blocks]
            (for [[&fst &snd] (pairwise &block)]
                 (when (and (not (eq (decide_structural_kind &fst) SKind.GroupStarter))
                            (or (in t_amarker &fst.tokens)
                                (in t_rmarker &fst.tokens)
                                (in t_jmarker &fst.tokens))
                            (lt (sum (first_indent_profile &fst.tokens))
                                (sum (first_indent_profile &snd.tokens))))
                       (raise (WyExpanderError :ntline &snd :msg PBMsg.oneL_bad_indent))))))

; _____________________________________________________________________________/ }}}1
; [F] decide SKind :: NTLine -> SKind (further used by Deconstructor.hy) ‾‾‾‾‾‾\ {{{1

    ; |■:  groupstarter
    ; |■1  continuator
    ; |■\\ continuator
    ; |■;  comment
    ; |■x  implied opener
    ; |    empty line (always has 0 tokens, since trailing spaces are removed at Preparator stage)

    ; this function is used in Expander.hy only for checking indent after oneliners;
    ; main usage is in Deconstructor.hy
    (defn [validateF] #^ SKind
        decide_structural_kind
        [ #^ NTLine ntline
        ]
        (when (zerolenQ ntline.tokens) (return SKind.EmptyLine))
        ; first 2 tokens are always enough to decide on SKind:
        (setv _tokens (cut_ ntline.tokens 1 2))
        (setv _decider_token
              (first
                     (lreject (fm (eq_any it.tkind [TKind.Indent TKind.NegIndent]))
                              _tokens)))
        ;
        (cond (eq     _decider_token.tkind TKind.OComment)
              SKind.OnlyOComment
              ;
              (eq_any _decider_token.tkind [TKind.RACont TKind.CMarker])
              SKind.Continuator
              ;
              (eq     _decider_token.tkind TKind.SMarker)
              SKind.GroupStarter
              ;
              True
              SKind.ImpliedOpener))

; _____________________________________________________________________________/ }}}1

; RMARKERs (no OMarker is supposed to be at NTLine start at this stage):
; helpers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ (of List (of List Token))
        split_tokens_by_rmarker_tokens
        [ #^ (of List Token) tokens
        ]
        "rmarker tokens themselves are removed"
        (lmulticut_by (fm (eq it.tkind TKind.RMarker))
                      tokens
                      :keep_border  False
                      :merge_border False))

    (defn [validateF] #^ (of List Token)
        prepend_rmarker_openers
        [ #^ (of List Token) tokens
          #^ StrictInt       n
        ]
        " 
        | ⎤  f      < this input        ; ⎤ is continuator in this notation
        |   ⎤f      < or this input
        |    : :⎤f  < produce this output
        |
        |  f    < this input
        |  : f  < produces this output
        "
        (setv [ind1 cont ind2] (first_indent_profile tokens)) ; n 0/1 n
        ; tokens with profile tokens dropped:
        (setv main_tokens (list (dropwhile (fm (or (= it.tkind TKind.Indent)
                                                   (= it.tkind TKind.CMarker)))
                                           tokens)))
        (lconcat [(indent_token (plus ind1 cont ind2))]
                 (lmul [(Token ":" PKind.OMARKER TKind.SMarker) (indent_token 1)]
                       (minus n cont))
                 (lmul [(Token ":" PKind.OMARKER TKind.SMarker) t_cmarker]
                       cont)
                 main_tokens))

; _____________________________________________________________________________/ }}}1
; [F] expand rmarkers :: NTLine -> [NTLine ...] ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

   (defn [validateF] #^ (of List NTLine)
        expand_rmarkers
        [ #^ NTLine ntline
        ]
        (->> ntline.tokens
             expand_rmarkers_on_tokens
             (lmapm (NTLine :lineNs ntline.lineNs
                            :tokens it))
             (lmapcat expand_smarkers)))

    (defn [validateF] #^ (of List (of List Token))
        expand_rmarkers_on_tokens
        [ #^ (of List Token) tokens
        ]
        "|this line:
         |■⎤■■f <$ ⎤ x <$ y
         |
         |will be transpiled to this:
         |            ; ⎤ is continuator in this notation
         |■■■■:■:■⎤f  ; _head_line
         |■■■■■■■■⎤x  ; _expd_line1 (expanded)
         |■■■■■■4     ; _expd_line2
        "
        (unless (in t_rmarker tokens) (return [tokens]))
        ;
        (setv _chunks (split_tokens_by_rmarker_tokens tokens))
        ;
        (setv _head_line  (first _chunks))
        (setv _expd_lines (drop 1 _chunks))
        (setv _head_line_updated
            (prepend_rmarker_openers _head_line (len _expd_lines)))
        ;
        ; building indents for expd lines:
        (setv indent_profile (first_indent_profile _head_line)) 
        (setv _nPre  (sum indent_profile))
        (setv _indents (lmapm (plus _nPre (double it))
                              (lreversed (range_ 1 (len _expd_lines)))))
        ;
        (setv _expd_lines_updated
              (lmapm (lconcat [(indent_token (+ (minus1_when_cmarker_1st %1) %2))]
                              %1)
                     _expd_lines
                     _indents))
        ;
        (setv _expd_lines_updated                   ; [HACK_REV] because case "x <$" and such generate lines consisting only of indent
              (lreject (fm (and (oflenQ 1 it)
                                (= (. (first it) tkind) TKind.Indent)))
                       _expd_lines_updated))       
        ;
        (return (lconcat [_head_line_updated] _expd_lines_updated)))

    (defn [validateF] #^ StrictInt
        minus1_when_cmarker_1st
        [#^ (of List Token) tokens]
        (when (zerolenQ tokens) (return 0))         ; [HACK_REV] case of "x <$" and such (empty arg after <$)
        (if (= (. (first tokens) tkind) TKind.CMarker)
            -1
             0))

; _____________________________________________________________________________/ }}}1

; AMARKERs (no OMarker is supposed to be at NTLine start at this stage):
; helpers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ (of List (of List Token))
        split_tokens_by_amarker_tokens
        [ #^ (of List Token) tokens
        ]
        "amarker tokens themselves are removed"
        (lmulticut_by (fm (eq it.tkind TKind.AMarker))
                      tokens
                      :keep_border  False
                      :merge_border False))

    (defn [validateF] #^ StrictInt
        guaranteed_excessive_len_of_line
        [ #^ (of List Token) tokens
        ]
        " this is intended for expanded lines after $ symbol;
          for [':', 'x'] will return 3
        "
        (sum (lmap tlen (funcy.interpose (indent_token 1) tokens))))

; _____________________________________________________________________________/ }}}1
; [F] expand amarkers :: NTLine -> [NTLine ...] ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

   (setv $A_INDENT_LEN 4) ; extra indent generated by AMarkers

   (defn [validateF] #^ (of List NTLine)
        expand_amarkers
        [ #^ NTLine ntline
        ]
        " this is just wrapping of 'expand_amarkers_on_tokens' into ntline
          + smarker expanding afterwards"
        (->> ntline.tokens
             expand_amarkers_on_tokens
             (lmapm (NTLine :lineNs ntline.lineNs
                            :tokens it))
             (lmapcat expand_smarkers)))

    (defn [validateF] #^ (of List (of List Token))
        expand_amarkers_on_tokens
        [ #^ (of List Token) tokens
        ]
        "| ⎤  f $ : ⎤ x $ : y
         |
         |                      ; ⎤ is continuator in this notation
         | ⎤  f                 ; line 1
         |    →→→→: ⎤ x $ : y   ; line 2
        "
        (unless (in t_amarker tokens) (return [tokens]))
        ;
        (setv _lines (split_tokens_by_amarker_tokens tokens))
        (setv _line1 (first _lines))
        (setv _rest_lines (list (rest _lines)))
        ;
        ; indents 2+ :
        (setv _lines_lens (lmap guaranteed_excessive_len_of_line _lines))
        (setv _rest_indents
              (lsums (lmapm (plus it $A_INDENT_LEN) _lines_lens)))
        ;
        (setv _rest_lines_updated
              (lmapm (lconcat [(indent_token %1)]
                              %2)
                     _rest_indents
                     _rest_lines))
        (return (lconcat [_line1] _rest_lines_updated)))

; _____________________________________________________________________________/ }}}1

; <NegIndent token is created here>
; JMARKERs (no OMarker is supposed to be at NTLine start at this stage):
; [F] expand jmarkers :: NTLine -> [NTLine ...] ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ (of List NTLine)
        expand_jmarkers
        [ #^ NTLine ntline
        ]
        "all the smarker expansion logic is inside expand_one_jmarker"
        (setv _new_lines [ntline])
        ;
        (while (in t_jmarker
                   (getattrm (last _new_lines) .tokens))
               (setv _new_lines
                     (lconcat (butlast _new_lines)
                              (expand_one_jmarker (last _new_lines)))))
        ;
        (return _new_lines))


    (defn [validateF] #^ (of List NTLine)
        expand_one_jmarker
        [ #^ NTLine ntline
        ]
        "Processes first found smarker, also immediately smarker-expands line 2:
         | ⎤  f , : ⎤ x , : y
         |
         |                ; ⎤ is continuator in this notation
         | ⎤  f           ; line 1
         |    :           ; / line 2, smarker-expanded
         |      x , : y   ; \\ 
        "
        ; work on Tokens:
        (setv tokens ntline.tokens)
        (unless (in t_jmarker tokens) (return [ntline]))
        ;
        (setv [_line1 _line2]
              (lbisect_by (fm (neq it.tkind TKind.JMarker))
                          tokens))
        (setv _line2 (list (rest _line2))) ; remove JMarker itself
        ;
        (setv _indent (sum (first_indent_profile tokens)))
        (setv _dedent (if (and (fnot zerolenQ _line2)
                               (= (getattrm (first _line2) .tkind) TKind.CMarker))
                          -1
                          0))
        (setv _final_indent (plus _indent _dedent))
        (setv _line2_updated 
              (cond (= _final_indent  0) _line2
                    (= _final_indent -1) (lconcat [t_negindent] _line2)   ; This is the only place in the codebase where NegIndent can be created
                    True                 (lconcat [(indent_token _final_indent)] _line2)))
        ; work on NTLines:
        (setv ntlines (lmapm (NTLine :lineNs ntline.lineNs
                                     :tokens it)
                            [_line1 _line2_updated]))
        (return (lconcat [(first ntlines)]
                         (expand_smarkers (second ntlines)))))

; _____________________________________________________________________________/ }}}1

; Assembly all:
; [I] check and expand ntlines :: [NTLine ...] -> [NTLine ...] ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ (of List NTLine)
        expand_ntlines
        [ #^ (of List NTLine) ntlines
        ]
        (setv _clsfd_ntlines (lmap classify_omarkers ntlines))
        (lmap check_syntax _clsfd_ntlines)            ; raises error when problems found
        ;
        (setv _expd_ntlines (lmapcat expand_smarkers _clsfd_ntlines)) ; expands only leading smarkers of the line since no r/a/j-markers are processed yet
        (check_indent_after_oneliners _expd_ntlines)   ; raises error when problems found
        ;
        (->> _expd_ntlines
             (mapcat  expand_rmarkers)
             (mapcat  expand_amarkers)
             (lmapcat expand_jmarkers)))

; _____________________________________________________________________________/ }}}1



