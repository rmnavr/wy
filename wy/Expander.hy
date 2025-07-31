
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import pyparsing :as pp)

    (import Classes *)

    (import  _fptk_local *)
    (require _fptk_local *)

; _____________________________________________________________________________/ }}}1

    ; \ \ is forbidden      // first_indent_profile
    ; <$ <$ is forbidden?   // split_tokens_by_rmarker_tokens

; Utils used by all expanding steps:
; [util] General APL ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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
        (return (len token.atom)))

    (defn [validateF] #^ Token
        indent_token
        [#^ StrictInt indent_len]
        "converts 3 to Token('■■■')"
        (Token TKind.Indent (smul $INDENT_MARK indent_len)))

    (defn [validateF] #^ Token
        tokens_to_indent_token
        [#^ (of List Token) tokens]
        "converts ['■', '~:'] to '■■■'"
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
        (if (= token1.kind TKind.Indent)
            (lconcat [(indent_token (plus (tlen token1) indent_len))]
                     (cut_ tokens 2 -1))
            (lconcat [(indent_token indent_len)]
                     tokens)))

    (defn [validateF] #^ (of Tuple StrictInt StrictInt StrictInt)
        first_indent_profile
        [ #^ (of List Token) tokens
        ]
        " returns 3 numbers:
          - indent token len (>0 if present)
          - continuator (0 if not present)
          - indent token len (>0 if present)
          ;
          there may be several options:
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
        (setv indent_tokens (list (takewhile (fm (or (= it.kind TKind.Indent)
                                                     (= it.kind TKind.CMarker)))
                                             tokens)))
        (case (len indent_tokens)
              0
              #(0 0 0)
              ;
              1
              (do (setv token1 (first tokens))
                  (if (eq token1.kind TKind.Indent)
                      #((tlen token1) 0 0)
                      #(0 1 0)))
              ;
              2
              (do (setv token1 (first  tokens))
                  (setv token2 (second tokens))
                  (if (eq token1.kind TKind.Indent)
                      #((tlen token1) 1 0)
                      #(0 1 (tlen token2))))
              ;
              3
              (do (setv token1 (first  tokens))
                  (setv token2 (second tokens))
                  (setv token3 (third  tokens))
                  #((tlen token1) 1 (tlen token3)))
              ;
              True
              (print "how")))

; _____________________________________________________________________________/ }}}1
; [util] for NTLine ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; not used:
    (defn [validateF] #^ bool
        ntline_starts_with_indentQ
        [#^ NTLine ntline]
        "will also return False for empty lines"
        (when (zerolenQ ntline.tokens) (return False))
        (setv token1 (first  ntline.tokens))
        (if (eq token1.kind TKind.Indent) True False))

; _____________________________________________________________________________/ }}}1

; 1) Expand SMarkers
; [util] ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ bool
        ntline_has_smarker_for_expandingQ
        [#^ NTLine ntline]
        "True for ['■', ':', ...] and [':', ...] ntlines"
        (when (<= (len ntline.tokens) 2) (return False))
        (setv token1 (first  ntline.tokens))
        (setv token2 (second ntline.tokens))
        ;
        (cond (and (eq token1.kind TKind.Indent) (eq token2.kind TKind.OMarker)) True
              (eq token1.kind TKind.OMarker) True
              True False))

; _____________________________________________________________________________/ }}}1
; [step] expand leading smarker        :: NTLine -> [NTLine ...] ‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1


    (defn [validateF] #^ (of List NTLine)
        expand_one_smarker
        [#^ NTLine ntline]
        "when no smarker is found, return source [ntline], otherwise return [ntline1, ntline2]"
        (unless (ntline_has_smarker_for_expandingQ ntline) (return [ntline]))
        ;
        (setv [ntline1_tokens ntline2_tokens]
              (transfer_to_left #*
                    (lbisect_by (fm (neq it.kind TKind.OMarker))
                                ntline.tokens)))
        (setv ntline2_tokens
              (prepend_indent_token (tlen (tokens_to_indent_token ntline1_tokens))
                                    ntline2_tokens))
        ;
        (lmapm (NTLine :rowN           ntline.rowN
                       :realRowN_start ntline.realRowN_start
                       :realRowN_end   ntline.realRowN_end
                       :tokens         it)
               [ntline1_tokens ntline2_tokens]))

; _____________________________________________________________________________/ }}}1
; [assm] expand all smarkers on 1 line :: NTLine -> [NTLine ...] ‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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
        ;
        (return _new_lines))

; _____________________________________________________________________________/ }}}1

; 2) Expand RMarkers (at this stage no OMarker can be at NTLine start)
; [util] ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ (of List (of List Token))
        split_tokens_by_rmarker_tokens
        [ #^ (of List Token) tokens
        ]
        "rmarker tokens themselves are removed"
        (lmulticut_by (fm (eq it.kind TKind.RMarker))
                      tokens
                      :keep_border  False
                      :merge_border False))

    (defn [validateF] #^ (of List Token)
        prepend_rmarker_opener
        [ #^ (of List Token) tokens
        ]
        "['■■■','riba'] -> ['■■■', ':', '■', 'riba']"
        (setv token1 (first tokens))
        (if (= token1.kind TKind.Indent)
            (lconcat [token1]
                     [(Token TKind.OMarker ":") (Token TKind.Indent $INDENT_MARK)]
                     (drop 1 tokens))
            (lconcat [(Token TKind.OMarker ":") (Token TKind.Indent $INDENT_MARK)]
                     tokens)))
            
; _____________________________________________________________________________/ }}}1
; [assm] :: [Token ...] -> [[Token ...] ...] ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ (of List (of List Token))
        expand_rmarkers_on_tokens
        [ #^ (of List Token) tokens
        ]
        "| ⎤  f <$ ⎤ x <$ y     
         |
         |            ; ⎤ is continuator in this notation
         |■:■:■⎤■■f   ; _head_line
         |■■■■■■■⎤x   ; _expd_line1 (expanded)
         |■■■4        ; _expd_line2
        "
        (unless (in (Token TKind.RMarker $RMARKER) tokens) (return [tokens])) 
        ;
        (setv _chunks (split_tokens_by_rmarker_tokens tokens))
        ;
        (setv _head_line  (first _chunks))
        (setv _expd_lines (drop 1 _chunks))
        (setv _head_line_updated (apply_n (len _expd_lines) prepend_rmarker_opener _head_line))
        ;
        ; building indents for expd lines:
        (setv indent_profile (first_indent_profile _head_line)) ; notice: here is head_line, not head_line_updated
        (setv _i1    (sum indent_profile))
        (setv _iRest (lrepeat (first indent_profile)
                              (dec (len _expd_lines))))
        (setv _indents (lmapm (+ (double %1) %2)
                              (lreversed (range_ 1 (len _expd_lines)))
                              (lconcat [_i1] _iRest)))
        ;
        (setv _expd_lines_updated 
              (lmapm (lconcat [(indent_token (+ (if (= (getattrm (first %1) .kind) TKind.CMarker) -1 0)
                                                %2))]   
                              %1)
                     _expd_lines
                     _indents))
        (return (lconcat [_head_line_updated] _expd_lines_updated)))

; _____________________________________________________________________________/ }}}1
; [assm] :: NTLine -> [NTLine ...] ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

   (defn [validateF] #^ (of List NTLine)
        expand_rmarkers
        [ #^ NTLine ntline
        ]
        "this is just wrapping of 'expand_rmarkers_on_tokens' into ntline"
        (setv tokenss (expand_rmarkers_on_tokens ntline.tokens))
        (lmapm (NTLine :rowN           ntline.rowN
                       :realRowN_start ntline.realRowN_start
                       :realRowN_end   ntline.realRowN_end
                       :tokens         it)
               tokenss))

; _____________________________________________________________________________/ }}}1

;3) Expand AMarkers (again, no OMarker can be at NTLine start)
; [assm] :: [Token ...] -> [[Token ...] ...] ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ (of List (of List Token))
        expand_one_amarker_on_tokens
        [ #^ (of List Token) tokens
        ]
        "| ⎤  f $ ⎤ x $ : y     
         |
         |            ; ⎤ is continuator in this notation
         | ⎤  f
         |    →→→→⎤ x $ : y
        "
        (unless (in (Token TKind.RMarker $RMARKER) tokens) (return [tokens])) 
        ;
        (setv _chunks (split_tokens_by_rmarker_tokens tokens))
        ;
        (setv _head_line  (first _chunks))
        (setv _expd_lines (drop 1 _chunks))
        (setv _head_line_updated (apply_n (len _expd_lines) prepend_rmarker_opener _head_line))
        ;
        ; building indents for expd lines:
        (setv indent_profile (first_indent_profile _head_line)) ; notice: here is head_line, not head_line_updated
        (setv _i1    (sum indent_profile))
        (setv _iRest (lrepeat (first indent_profile)
                              (dec (len _expd_lines))))
        (setv _indents (lmapm (+ (double %1) %2)
                              (lreversed (range_ 1 (len _expd_lines)))
                              (lconcat [_i1] _iRest)))
        ;
        (setv _expd_lines_updated 
              (lmapm (lconcat [(indent_token (+ (if (= (getattrm (first %1) .kind) TKind.CMarker) -1 0)
                                                %2))]   
                              %1)
                     _expd_lines
                     _indents))
        (return (lconcat [_head_line_updated] _expd_lines_updated)))

; _____________________________________________________________________________/ }}}1

;+) Assm all expansions
; [assm] ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ (of List NTLine)
        expand_ntlines
        [ #^ (of List NTLine) ntlines
        ]
        (->> ntlines
             (funcy.mapcat expand_smarkers)
             (funcy.mapcat expand_rmarkers)
             (funcy.mapcat expand_smarkers)))

; _____________________________________________________________________________/ }}}1

; [del] indents count ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; ""  -> []
    ;
    ;  ↓
    ; "x" -> [1] Column Number
    ;
    ;  ₁↓
    ; " x" -> [2]
    ;
    ;  ₁₂↓
    ; "\ x"-> [3]
    ;
    ;  ₁₂₃↓
    ; "\  x"-> [4]
    ;
    ;  ₁↓₃₄↓↓₇₈↓↓↓↓₃₄₅₆₇↓ (after \ only 1st symbol is used)
    ; " L  #:  ~@#:   \ ~: x" -> [2, 5-6, 9-12, 18]

    (defn [validateF] #^ (of List Token)
        count_indents_for_ntline [#^ NTLine ntline]
        ;
        (setv _indentable_tokens [])
        (for [&token ntline.tokens]
            (cond (eq &token.kind TKind.Indent)  (    += _indentable_tokens [&token])
                  (eq &token.kind TKind.OMarker) (    += _indentable_tokens [&token])
                  (eq &token.kind TKind.CMarker) (do (+= _indentable_tokens [&token]) (break))
                  True                           (break)))
        _indentable_tokens)

; _____________________________________________________________________________/ }}}1
; run ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import Preparator [wycode_to_prepared_code])
    (import Parser     [prepared_code_to_ntlines])

    (setv _code1 " L L 1 2 3 \n   L 2 3 4")

    (defn cntl [ntline] (re_sub "■" " " (sconcat #* (pluckm .atom ntline.tokens))))

    (->> _code1
         wycode_to_prepared_code
         prepared_code_to_ntlines
         expand_ntlines
         (lmap cntl)
         lprint)

; _____________________________________________________________________________/ }}}1

