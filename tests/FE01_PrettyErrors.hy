
    (import  wy.utils.fptk_local.core *)
    (require wy.utils.fptk_local.core *)

    (import wy.Frontend.ErrorHelpers [run_wy2hy_transpilation transpile_wy2hy])

    (import termcolor [colored :as clrz])

; testing machinery setup ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1
    
    (setv clrz_ow (fm (clrz it None "on_white")))

    (defn run_err_test [memo wycode]
        (print (clrz_ow f"=== {memo}: ==="))
        (run_wy2hy_transpilation wycode :silent False))

; _____________________________________________________________________________/ }}}1

    (run_err_test "Unmatched opener"    "(")

    (run_err_test "Naked Unicode"       " •") 
    (run_err_test "Unmatched closer"    " ]") 
    (run_err_test "Unmatched quota"     " \"") 

    (run_err_test "Incorrect cont pos"  "1 \\ 2\nololo ; smth")
    (run_err_test "Incorrect one-liner" "ololo ,")
    (run_err_test "Incorrect one-liner" "$ $\nololo")
    (run_err_test "Deconstructor"       "1\n;\n 2")
    (run_err_test "Deconstructor"       "\n\n1\n \"\nsss\n\" 2")
    (run_err_test "Bracketer"           "  y\n;smth\n z")


