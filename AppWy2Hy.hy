
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

    (setv _hysky         (-> "docs\\_test3.wy" file_to_code))
    (setv _prepared_code (prepare_code_for_pyparsing _hysky))
    ;
    (setv _tlines        (prepared_code_to_tlines _prepared_code))  ; tokenize
    (setv _dlines        (lmap tline_to_dline  _tlines))            ; deconstruct
    ;
    (setv _blines        (run_processor $CARD0 _dlines))            ; bracketize
    (setv _hycode        (blines_to_hcode _blines))                 ; assembly

    (print  "=== source hysky code ===")  (print  _hysky)           (print "")
    (print  "=== prepared code ===")      (print  _prepared_code)   (print "")
    (print  "=== tokenized lines ===")    (lprint _tlines)          (print "")
    (print  "=== decontructed lines ===") (lprint _dlines)          (print "")
    (print  "=== bracketed lines ===")    (lprint _blines)          (print "")
    (print  "=== final hy code ===")      (lprint _blines)          (print "")
    (print _hycode)

    ;(-> _hycode hy.read_many hy.eval)

