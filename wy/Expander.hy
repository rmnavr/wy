
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import pyparsing :as pp)

    (import Classes *)

    (import  _fptk_local *)
    (require _fptk_local *)

; _____________________________________________________________________________/ }}}1


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

    (defn [validateF] #^ StrictInt
        calc_first_indent
        [ #^ (of List Token) tokens
        ]
        " there may be several options:
          |         0
          |x        0
          |■■       2
          |\\x      1
          |■■x      2
          |\\■■x    3
          |■■\\x    3
          |■■\\■■x  5
          ;
          - x may be anything except indent, even smarkers
        "
        (setv indent_tokens (takewhile (fm (or (= it.kind TKind.Indent)
                                               (= it.kind TKind.CMarker)))
                                       tokens))
        (tlen (tokens_to_indent_token indent_tokens)))

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
        split_tokens_by_rmaker_tokens
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

    (defn [validateF] #^ StrictInt
        calc_base_indent_of_line
        [ #^ (of List Token) tokens
        ]
        "takes CMarker into account"
        (setv indent_tokens (takewhile (fm (or (= it.kind TKind.Indent)
                                               (= it.kind TKind.CMarker)))
                                       tokens))
        (tlen (tokens_to_indent_token indent_tokens)))
            
; _____________________________________________________________________________/ }}}1
; [assm] ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ (of List (of List Token))
        expand_rmarkers_on_tokens
        [ #^ (of List Token) tokens
        ]
        (unless (in (Token TKind.RMarker $RMARKER) tokens) (return [tokens]))
        (setv _chunks (split_tokens_by_rmaker_tokens tokens))
        (setv [_head_elem _tail] [(first _chunks) (drop 1 _chunks)])
        ;
        (setv _head_elem_updated (apply_n (len _tail) prepend_rmarker_opener _head_elem))
        ;
        (setv _head_indent (calc_base_indent_of_line _head_elem))
        (setv _tail_updated 
              (lmapm (lconcat [ (Token TKind.Indent
                                       (smul $INDENT_MARK
                                             (+ _head_indent
                                                (if (= (getattrm (first %1) .kind) TKind.CMarker) -1 0)
                                                (mul %2 2)))) ; 2 is len of ":■"
                              ]   
                              %1)
                     _tail
                     (reversed (range_ 1 (len _tail)))))
        (return (lconcat [_head_elem_updated] _tail_updated)))

   (defn [validateF] #^ (of List NTLine)
        expand_rmarkers
        [ #^ NTLine ntline
        ]
        (setv tokenss (expand_rmarkers_on_tokens ntline.tokens))
        (lmapm (NTLine :rowN           ntline.rowN
                       :realRowN_start ntline.realRowN_start
                       :realRowN_end   ntline.realRowN_end
                       :tokens         it)
               tokenss))

; _____________________________________________________________________________/ }}}1

;3) Expand AMarkers (again, no OMarker can be at NTLine start)
; ....

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

    (setv _code1 " : x <$ y <$ : z")

    (defn cntl [ntline] (re_sub "■" " " (sconcat #* (pluckm .atom ntline.tokens))))

    (->> _code1
         wycode_to_prepared_code
         prepared_code_to_ntlines
         expand_ntlines
         (lmap cntl)
         lprint)

; _____________________________________________________________________________/ }}}1

    ; continue from 1: 
    ; - calc_first_indent

    ; continue from 2: 

        ;| :
        ;|   :
        ;|     \  f_x
        ;|        3
        ;|   ←←←4

        ; probably forbid ' <$ x'

        ; bug: empty lines are cut away -> solution is good multicut function

