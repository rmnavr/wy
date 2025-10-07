
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))

    (import  wy._fptk_local *)
    (require wy._fptk_local *)

; _____________________________________________________________________________/ }}}1

    (import os)
    (import pathlib [Path])

    (setv _fname "test_dir")

    (print "exists:"  (file_existsQ _fname))
    (print "is file:" (fileQ _fname))
    (print "is dir:"  (dirQ _fname))

    (print (os.path.splitext _fname))
