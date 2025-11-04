
    (import  _fptk_local *)
    (require _fptk_local *)

    (import wy.Frontend.ErrorHelpers [run_wy2hy_transpilation])

    (import termcolor [colored :as clrz])

; testing machinery setup ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1
    
    (setv clrz_ow (fm (clrz it None "on_white")))

    (defn run_err_test [memo wycode]
        (print (clrz_ow f"=== {memo}: ==="))
        (run_wy2hy_transpilation wycode :silent False))

; _____________________________________________________________________________/ }}}1

    (run_err_test "should be Parser error:" "(")
    (run_err_test "should be Indent error:" "   y\n :\\z")
    (run_err_test "should be Syntax error:" "x \\ : z")

