
    (import  wy.utils.fptk_local.core *)
    (require wy.utils.fptk_local.core *)

    (import wy.Frontend.wy2hy [run_wy2hy_script Wy2Hy_Args])

    (import termcolor [colored :as clrz])

; preventing sys.exit ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import sys)
    (import contextlib)
        
    (defclass [] PreventExit [Exception])

    (defn prevent_sys_exit [#* args]
          (raise (PreventExit)))

    (defn [contextlib.contextmanager]
        prevent_exit []
        (setv original_exit sys.exit)
        (try (setv sys.exit prevent_sys_exit)
             (yield)
             (finally (setv sys.exit original_exit))))


; _____________________________________________________________________________/ }}}1
; testing machinery setup ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1
    
    (setv clrz_ow (fm (clrz it None "on_white")))

    (defn run_cli_test [memo files_list modes_dict]
        (print (clrz_ow f"=== {memo}: ==="))
        (run_wy2hy_with_exit_prevention
            (Wy2Hy_Args :filenames files_list #** modes_dict)))

    (defn run_wy2hy_with_exit_prevention [wy2hy_args]
        (try 
             (with [(prevent_exit)] (run_wy2hy_script :dummy_args wy2hy_args))
             (except [e PreventExit] "do nothing")))

; _____________________________________________________________________________/ }}}1

    (setv $OK "wy_code\\01_correct_code.wy")
    (setv $XX "wy_code\\02_incorrect_code.wy")
    (setv $NE "wy_code\\non_existing_file.wy")
    (setv $HY "wy_code\\03_generated_by_cli_test.hy")
    
    (setv modes (dict :silent_mode True  :stdout_mode False))
    (setv modes (dict :silent_mode False :stdout_mode False))
    (run_cli_test "[o] Show info"               []            modes)
    (run_cli_test "[V] Compile GOOD.wy"         [$OK]         modes)
    (run_cli_test "[V] Compile GOOD.wy+GOOD.hy" [$OK $HY]     modes)
    (run_cli_test "[X] TRNSPERR.wy"             [$XX]         modes)
    (run_cli_test "[X] NONEXIST.wy"             [$NE]         modes)
    (run_cli_test "[X] GOOD.wy -> BADEXT"       [$OK "1.txt"] modes)
    (run_cli_test "[X] BADEXT"                  [$HY]         modes)
    (run_cli_test "[X] BADEXT BADEXT"           [$HY $HY]     modes)
    (run_cli_test "[X] BADEXT GOOD.wy"          [$HY $OK]     modes)

    (setv modes (dict :silent_mode False :stdout_mode False))
    (run_cli_test "[VV] Compile GOOD.wy GOOD.wy+GOOD.hy"  [$OK $OK $HY]     modes)
    (run_cli_test "[VXX] GOOD.wy TRNSPERR.wy NONEXIST.wy" [$OK $XX $NE]     modes)
    (run_cli_test "[X] GOOD.wy GOOD.wy BADEXT"            [$OK $OK "1.txt"] modes)

    (setv modes (dict :silent_mode False :stdout_mode True))
    (run_cli_test "Show info"                      []            modes)
    (run_cli_test "Compile GOOD.wy"                [$OK]         modes)
    (run_cli_test "[X] TRNSPERR.wy"                [$XX]         modes)
    (run_cli_test "[X] NONEXIST.wy"                [$NE]         modes)
    (run_cli_test "[X] compile GOOD.wy -> BADEXT"  [$OK "1.txt"] modes)
    (run_cli_test "[X] compile BADEXT"             [$HY]         modes)
    (run_cli_test "[X] compile GOOD.wy -> GOOD.hy" [$OK $HY]     modes)
    (run_cli_test "[X] compile BADEXT GOOD.wy"     [$HY $OK]     modes)
    (run_cli_test "[X] compile GOOD.wy GOOD.wy"    [$OK $OK]     modes)

