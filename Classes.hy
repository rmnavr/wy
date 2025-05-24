
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))

    (require hyrule [of as-> -> ->> doto case branch unless lif do_n list_n ncut])
    (import  _hyextlink *)
    (require _hyextlink [f:: fm p> pluckm lns &+ &+> l> l>=] :readers [L])

; _____________________________________________________________________________/ }}}1

    (setv #_ DC HCode             str)             ; many lines
    (setv #_ DC HCodeLine         str)             ; partial flip 3
    (setv #_ DC IndentMarkedLine  str)             ; ✠✠✠✠partial flip 3 | ■

    (setv #_ DC DeconstructedLine (of List str))   ; ['■'] | ['✠✠' partial ..] | ['partial' ..]

    (defclass [] DLineKind [Enum] ; DLine is DeconstructedLine
        (setv EMPTY         0)
        (setv OPENER        1   #_ "<:> or <word>")
        (setv CONTINUATOR   2   #_ "\\")
        ;(setv DOUBLEOPENER  3   #_ "<: word>")
        )

    (defclass [dataclass] ProcessorCard []
        (#^ (of List int) indents)
        (#^ int           brkt_count     #_ "count of (opener) brackets")
        )

