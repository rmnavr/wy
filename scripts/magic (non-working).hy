
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import __future__                [ annotations ])
    (import sys)
    (import typing                    [ Mapping Optional ])

    (import IPython.core.getipython   [ get_ipython ])
    (import IPython.core.magic        [ Magics
                                        magics_class
                                        line_cell_magic
                                        needs_local_scope])

    (import hy)
    (import wy.Frontend.ErrorHelpers  [ run_wy2hy_transpilation ])
    (import wy.Frontend.ReplHelpers   [ frame_hycode ])
    (import  wy.utils.fptk_local      [ unwrapR unwrapE failureQ noneQ sconcat neq ])
    (require wy.utils.fptk_local      [ getattrm ])

; _____________________________________________________________________________/ }}}1

    (defclass [magics_class] WyMagics [Magics]
        ;
        (defn [line_cell_magic needs_local_scope]
             #^ object wy
             [ #^ (of Optional str)                     line
               #^ (of Optional str)                     [cell None]
               #^ (of Optional (of Mapping str object)) [local_ns None]
             ]
             "Magic to execute Wy code within a Python kernel."
             (setv ipython (get_ipython))
             (if (noneQ ipython)
                 ; The last element of `In`, i.e. the just-executed cell
                 (setv cell_number -1)
                 (setv cell_number ipython.execution_count))
            (setv cell_filename f"IPython:In[{cell_number}]")
            (setv code (sconcat (or line "") (or cell "")))
            (setv local_module (get sys.modules (get local_ns "__name__")))
            ;
            (setv transpilationResult (run_wy2hy_transpilation code))
            (if (failureQ transpilationResult)
                (do (print "wy -> hy transpilation failed:\n")
                    (print (. (unwrapE transpilationResult) msg))
                    (return None))
                (do (setv hycode (unwrapR transpilationResult))
                    (return 
                         (hy.eval (hy.read_many hycode :filename cell_filename)
                                  :locals local_ns
                                  :module local_module)))))
        ;
        (defn [line_cell_magic needs_local_scope]
             #^ object wy_spy
             [ #^ (of Optional str)                     line
               #^ (of Optional str)                     [cell None]
               #^ (of Optional (of Mapping str object)) [local_ns None]
             ])
             "Magic to execute Wy code within a Python kernel."
             (setv ipython (get_ipython))
             (if (noneQ ipython)
                 ; The last element of `In`, i.e. the just-executed cell
                 (setv cell_number -1)
                 (setv cell_number ipython.execution_count))
            (setv cell_filename f"IPython:In[{cell_number}]")
            (setv code (sconcat (or line "") (or cell "")))
            (setv local_module (get sys.modules (get local_ns "__name__")))
            ;
            (setv transpilationResult (run_wy2hy_transpilation code))
            (if (failureQ transpilationResult)
                (do (print "wy -> hy transpilation failed:\n")
                    (print (. (unwrapE transpilationResult) msg))
                    (return None))
                (do (setv hycode (unwrapR transpilationResult))
                    (when (neq hycode "")
                          (print (frame_hycode (hycode.strip "\n") :colored True)))
                    (return 
                          (hy.eval (hy.read_many (hycode.strip "\n") :filename cell_filename)
                                   :locals local_ns
                                   :module local_module)))))

