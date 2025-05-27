
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

    (defn #^ FullCode
        file_to_code #_ IO
        [#^ str file_name]
        (with [file (open file_name
                          "r"
                          :encoding "utf-8")]
              (setv outp (file.read)))
        (return outp))

; _____________________________________________________________________________/ }}}1

    (setv _hysky         (-> "parser_docs\\_test2.hy" file_to_code))
    (setv _prepared_code (prepare_code_for_pyparsing _hysky))
    (setv _tlines        (prepared_code_to_tlines _prepared_code))
    (setv _dlines        (lmap tline_to_dline  _tlines))
    (setv _blines        (run_processor $CARD0 _dlines))
    (setv _hycode        (blines_to_hcode _blines))

    ;(print _prepared_code)
    ;(lprint _tlines)
    ;(lprint _dlines)
    (print _hycode)
    ;(-> _hycode hy.read_many hy.eval)

