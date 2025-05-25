
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))

    (require hyrule [of as-> -> ->> doto case branch unless lif do_n list_n ncut])
    (import  _hyextlink *)
    (require _hyextlink [f:: fm p> pluckm lns &+ &+> l> l>=] :readers [L])

; _____________________________________________________________________________/ }}}1
; Classes ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; stage 0:

        (setv #_ DC HyskyCode     str)  ; many lines
        (setv #_ DC HyskyCodeLine str)  ; partial flip 3

    ; stage 1:

        (setv #_ DC PreparedCode  str)  ; ✠✠partial flip 3

    ; stage 2:

        (setv #_ DC DeconstructedLine (of List str))   ; ["■"] , ["✠✠" "partial" ..] , ["partial" ..]

        (defclass [] DLineKind [Enum]   ; DLine is DeconstructedLine
            (setv EMPTY         0)
            (setv OPENER        1   #_ "<word> and such")
            (setv CONTINUATOR   2   #_ "\\")
            (setv LINESTARTER   3   #_ ":")
            ;(setv DOUBLEOPENER  3   #_ "<: word>")
            )

    ; stage 3:

        (setv #_ DC ProcessedLine     (of List str))   ; ["✠✠" ")" "(" "partial" ...]

        (defclass [dataclass] ProcessorCard []
            "gives info on previously processed line"
            (#^ (of List int) indents)
            (#^ int           brkt_count)
            (#^ DLineKind     dline_kind)
            )

    ; stage 4:

        (setv #_ DC HyCode str)

; _____________________________________________________________________________/ }}}1

    ; (defclass [dataclass] DeconstructedLine []
    ;     "gives info on previously processed line"
    ;     (#^ int                 raw_indent_length   #_ "number of ✠ symbols")
    ;     (#^ str                 markers             #_ "like : and \ at beginning of the line")
    ;     (#^ (of List str)       tokens              #_ "like «func» and «<=»")
    ;     (#^ (of Optional str)   ending_comment      #_ "like ; comment"))




