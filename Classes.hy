
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))

    (require hyrule [of as-> -> ->> doto case branch unless lif do_n list_n ncut])
    (import  _hyext *)
    (require _hyext [f:: fm p> pluckm lns &+ &+> l> l>=] :readers [L])

; _____________________________________________________________________________/ }}}1

    (setv $INDENT_MARK "✠")

    (setv #_ DC HCode             str)             ; many lines
    (setv #_ DC HCodeLine         str)             ; partial flip 3
    (setv #_ DC IndentMarkedLine  str)             ; ✠✠✠✠partial flip 3 | ■



    (setv #_ DC DeconstructedLine (of List str))   ; ['■'] | ['✠✠' partial ..] | ['partial' ..]

    (defclass [] DLineKind [Enum] ; DLine is DeconstructedLine
        (setv EMPTY         0)
        (setv BRACKET_OPEN  1   #_ ":")
        (setv LIST_OPEN     2   #_ "L")
        (setv FUNCTION_OPEN 3   #_ "partial")
        (setv CONTINUATION  4   #_ "\\partial"))

    (defclass [dataclass] ParserFlow []
        (#^ (of Optional int)   prev_indent    #_ "None is empty line or file start")
        (#^ int                 accum_brackets #_ "count of C brackets")
        (#^ int                 accum_lists    #_ "count of L brackets")
        )

