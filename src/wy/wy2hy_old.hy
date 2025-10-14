
    ; TODO:
    ; - try_generate_filenames_pairs is used double-time 

; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import  wy._fptk_local *)
    (require wy._fptk_local *)

    (import sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))

    (import argparse)

    (import wy.Classes   [HyCode])
    (import wy.Assembler [convert_wy2hy])

; _____________________________________________________________________________/ }}}1

; C: Classes ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defclass [dataclass] Wy2Hy_Args []
        (#^ (of List str) filenames)
        (#^ bool          silent_mode)
        (#^ bool          stdout_mode))

    (defclass FTYPE [Enum]
        (setv WY    0)
        (setv HY    1)
        (setv ERROR 2))

    (defclass RUN_MODE [Enum]
        (setv INFO        1)
        (setv STDOUT_1    2)
        (setv TRANSPILE_N 3))

    (defclass [dataclass] APP_ERROR []
        (setv #^ str msg "ERROR: undefined"))

    (defclass [dataclass] SuccessfullTranspilation []
        (#^ float  time)
        (#^ HyCode code))

; _____________________________________________________________________________/ }}}1
; F: ErrorHandling helpers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn normal_exit
        [ #^ (of Optional str) [msg None]
        ]
        (when (fnot noneQ msg) (print msg :file sys.stdout)) 
        (sys.exit 0)
        )

    (defn exit_with_error
        [ #^ int errorN ; 1 for general, >1 for others 
          #^ (of Optional str) [msg None]
        ]
        (print msg :file sys.stderr)
        (sys.exit errorN)
        )

; _____________________________________________________________________________/ }}}1

; F: Get user provided args ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ Wy2Hy_Args get_args []
        ;
        (setv _parser (argparse.ArgumentParser :description "Transpiler: wy-code -> hy-code"))
        (_parser.add_argument "file"
                             :nargs "*" 
                             :help  "List of *.wy files (each file can ")
        ;
        (_parser.add_argument "-silent"
                             :action "store_true"
                             :help   "Do not emit transpilation status messages")
        ;
        (_parser.add_argument "-stdout"
                             :action "store_true"
                             :help   "Output to stdout")
        ;
        (setv _args (. _parser (parse_args)))
        (return (Wy2Hy_Args :filenames   _args.file
                            :silent_mode _args.silent
                            :stdout_mode _args.stdout)))

; _____________________________________________________________________________/ }}}1
; F: decide on run mode ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of Union RUN_MODE APP_ERROR)
        validate_args_and_decide_on_run_mode
        [ #^ Wy2Hy_Args args
        ]
        ;
        (setv _filenames (. args filenames))
        (setv _m_silent  (. args silent_mode))
        (setv _m_stdout  (. args stdout_mode))
        ;
        (when (oflenQ _filenames 0) (return RUN_MODE.INFO))
        ;
        (when _m_stdout
            (when (fnot oflenQ _filenames 1)
                  (return (APP_ERROR "ERROR: only one file (and which also should be of *.wy extension) should be used with -stdout mode")))
            (when (neq (get_ft (first _filenames)) FTYPE.WY)
                  (return (APP_ERROR "ERROR: file extension should be *.wy")))
            (return RUN_MODE.STDOUT_1))
        ;
        (setv _result (try_generate_filenames_pairs _filenames))
        (if (oftypeQ APP_ERROR _result)
            (return _result)
            (return RUN_MODE.TRANSPILE_N)))

; _____________________________________________________________________________/ }}}1

; F: Runner: stdout_mode ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of Union HyCode APP_ERROR) 
        transpile_in_stdout_mode
        [ #^ str source_filename
        ]
        ;
        (try (setv _wy_code (read_file source_filename))
             (except [e Exception]
                     (return (APP_ERROR f"ERROR: cannot read {source_filename} (file not available?)"))))
        (try (setv _hy_code (convert_wy2hy _wy_code))
             (except [e Exception]
                     (return (APP_ERROR f"ERROR: transpilation failed for {source_filename} (incorrect syntax?)"))))
        ; 
        (return _hy_code))

; _____________________________________________________________________________/ }}}1

; F: Filename operations: utils ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ FTYPE
        get_ft
        [ #^ str filename
        ]
        (setv [root ext] (os.path.splitext filename))
        (cond (= ext ".wy") (return FTYPE.WY)
              (= ext ".hy") (return FTYPE.HY)
              True          (return FTYPE.ERROR)))

    (defn #^ str
        change_filename_ext_to_hy
        [ #^ str filename
        ]
        "file1.wy -> file1.hy"
        (setv [root ext] (os.path.splitext filename))
        (return (sconcat root ".hy")))

; _____________________________________________________________________________/ }}}1
; F: Filename operations: pairableQ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of Union (of List (of Tuple str str)) APP_ERROR)
        try_generate_filenames_pairs
        [ #^ (of List str) filenames
        ]
        ; check if all files are *.wy or *.hy:
        (setv _types (lmap get_ft filenames))
        (when (in FTYPE.ERROR _types)
              (return (APP_ERROR (sconcat "ERROR: files can only be of *.wy or *.hy extension"))))
        ; check if 1st file is *.wy:
        (when (neq (get_ft (first filenames)) FTYPE.WY)
              (return (APP_ERROR "ERROR: first provided file should be of *.wy type")))
        ; check if *.hy follows *.wy (not another *.hy):
        (setv splitted_by_wy (lmulticut_by (fm (= (get_ft %1) FTYPE.WY))
                                           filenames
                                           :keep_border  True
                                           :merge_border False))
        (when (any (lmapm (>= (len %1) 3) splitted_by_wy))
              (return (APP_ERROR "ERROR: *.hy file may only follow *.wy file")))
        ; 
        ; add *.hy where were not provided:
        (lmapm (if (oflenQ it 2)
                   it
                   [(first it) (change_filename_ext_to_hy (first it))])
               splitted_by_wy))

; _____________________________________________________________________________/ }}}1
; F: Runner: Transpile one wy-hy pair ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of Union SuccessfullTranspilation APP_ERROR)
        transpile_wy_file
        [ #^ str source_filename
          #^ str target_filename
        ]
        ;
        (setv _pre f"[xx] {source_filename} -> {target_filename} :")
        (try (setv _wy_code (read_file source_filename))
             (except [e Exception]
                     (return (APP_ERROR f"{_pre} ERROR - can't read source file (file not available?)"))))
        (try (setv [_t_s prompt _hy_code] (with_execution_time (fm (convert_wy2hy _wy_code)) :tUnit "s"))
             (except [e Exception]
                     (return (APP_ERROR f"{_pre} ERROR - transpilation failed (incorrect syntax?)"))))
        (try (write_file _hy_code target_filename)
             (except [e Exception]
                     (return (APP_ERROR f"{_pre} ERROR - cannot write to target file (file not available?)"))))
        ;
        (return (SuccessfullTranspilation _t_s _hy_code)))

; _____________________________________________________________________________/ }}}1

; Info message ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv $INFO_MSG (sconcat   "\nwy2hy usage:"
                             "\n\n  [-h] [-silent] [-stdout] file [file ...]"
                             "\n\n  - files can be only of *.wy and *.hy extensions"
                               "\n  - *.hy can only follow *.wy file"
                               "\n  - only one *.wy file can be used for -stdout mode"))

; _____________________________________________________________________________/ }}}1

; F: run wy2hy ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn run_wy2hy_script []
        ;
        (setv wy2hy_args (get_args))
        (setv run_mode (validate_args_and_decide_on_run_mode wy2hy_args))
        (when (oftypeQ APP_ERROR run_mode)
              (exit_with_error 1 run_mode.msg))
        ;
        (setv _filenames (. wy2hy_args filenames))
        (setv _m_silent  (. wy2hy_args silent_mode))
        ;
        (when (eq run_mode RUN_MODE.INFO)
              (normal_exit $INFO_MSG))
        ;
        (when (eq run_mode RUN_MODE.STDOUT_1)
              (setv _result (transpile_in_stdout_mode (first _filenames)))
              (if (oftypeQ HyCode _result)
                  (normal_exit _result) ; this is print of HyCode to stdout
                  (exit_with_error 1 _result.msg)))
        ;
        (when (eq run_mode RUN_MODE.TRANSPILE_N) ; at this point pairs are always correct
              (setv _pairs (try_generate_filenames_pairs _filenames))
              (lstarmap (fm (do (setv _result (transpile_wy_file %1 %2))
                                (if (oftypeQ SuccessfullTranspilation _result)
                                    (unless _m_silent (print "[ok]" %1 "->" %2 f": transpiled in {_result.time :.3f} s"))
                                    (print _result.msg))))
                         _pairs)
              ;
              (if _m_silent
                  (normal_exit)
                  (normal_exit "Transpilation is finished"))))

; _____________________________________________________________________________/ }}}1

    (when (eq __name__ "__main__")
        ; (run_wy2hy_script)
        )


    ; todo: propagate failure exit if at least one file failed?
