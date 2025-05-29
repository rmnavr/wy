
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import pyparsing :as pp)

    (import Preparator [prepare_code_for_pyparsing])
    (import Parser     [prepared_code_to_tlines tline_to_dline])
    (import Bracketer  [$CARD0 run_processor blines_to_hcode])

    (import Classes *)

    (import sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))

    (require hyrule [of as-> -> ->> doto case branch unless lif do_n list_n ncut])
    (import  _hyextlink *)
    (require _hyextlink [f:: fm p> pluckm lns &+ &+> l> l>=] :readers [L])

; _____________________________________________________________________________/ }}}1

; IO ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ WyCodeFull
        file_to_code #_ IO
        [#^ str file_name]
        (with [file (open file_name
                          "r"
                          :encoding "utf-8")]
              (setv outp (file.read)))
        (return outp))

; _____________________________________________________________________________/ }}}1
; vim tmp ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ;nnoremap <A-/> mz^hr\`z:delmarks!<Enter>
    ;nnoremap <A-\> mz^Whr\`z:delmarks!<Enter>
    ;inoremap <A-/> <Esc>^hr\A
    ;inoremap <A-\> <Esc>^Whr\A

    ;nnoremap <leader>wi V}o><Esc>O<BS>
    ;nnoremap <leader>wd ^mzjwY}Pmy`z<C-V>`yhoxddmx}kdd`x:delmarks!<Enter>

; _____________________________________________________________________________/ }}}1

    (setv _hysky         (-> "_test5.wy" file_to_code))
    (setv _prepared_code (prepare_code_for_pyparsing _hysky))

    (setv _tlines        (prepared_code_to_tlines _prepared_code))  ; tokenize
    (setv _dlines        (lmap tline_to_dline  _tlines))            ; deconstruct
    (setv _blines        (run_processor $CARD0 _dlines))            ; bracketize
    (setv _hycode        (blines_to_hcode _blines))                 ; assembly

    ;(print  "=== source hysky code ===")  (print  _hysky)           (print "")
    ;(print  "=== prepared code ===")      (print  _prepared_code)   (print "")
    ;(print  "=== tokenized lines ===")    (lprint _tlines)          (print "")
    ;(print  "=== decontructed lines ===") (lprint _dlines)          (print "")
    ;(print  "=== bracketed lines ===")    (lprint _blines)          (print "")
    (print  "=== final hy code ===")      (print _hycode)           (print "")
    (print  "=== repl result ===")        (-> _hycode hy.read_many hy.eval)


