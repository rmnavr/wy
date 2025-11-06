
    (import os)
    (import subprocess)

    (import  wy.utils.fptk_local [str_join lmap sconcat zerolenQ])
    (require wy.utils.fptk_local [->> unless])

; [F] test machinery setup ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ str construct_hy_cmd [#^ str filename]
        f"hy {filename} & echo [TEST: {filename}] test finished")

    (defn #^ str construct_wy_cmd [#^ str filename]
        f"wy2hy {filename} & echo [TEST: {filename}] transpilation finished")

    (defn run_shell_command
        [ #^ str  command
          #^ bool [printQ True]
        ]
        (setv result
              (subprocess.run command
                              :shell          True
                              :check          True
                              :text           True
                              :capture_output True))
        (when printQ
            (unless (zerolenQ result.stdout) (print result.stdout))
            (unless (zerolenQ result.stderr) (print result.stderr))))

; _____________________________________________________________________________/ }}}1

; USER CONFIG ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv $HY_TESTS [
                    "BE01_preparator.hy"
                    "BE02_parser.hy"
                    "BE03_expander.hy"
                    "BE04_deconstructor.hy"
                    "BE05_bracketer.hy"
                    "BE06_writer.hy"
                    "BE07_assembler.hy"
                    ])

    (setv $WY_FILES [
                    "wy_code\\rresp.wy"
                    ])

; _____________________________________________________________________________/ }}}1

    (print "*** Launching hy tests ***")
    (->> $HY_TESTS
         (lmap construct_hy_cmd)
         (lmap run_shell_command))
    
    (print "*** Launching wy2hy transpilations ***")
    (->> $WY_FILES
         (lmap construct_wy_cmd)
         (lmap run_shell_command))
