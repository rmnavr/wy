
    ; TODO:
    ; - propagate failure exit if at least one file failed?

; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import  wy.utils.fptk_local *)
    (require wy.utils.fptk_local *)
    (import  wy.utils.coloring *)

    (import os)
    (import sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))

    (import argparse)

    (import wy.Backend.Classes   [HyCode])
    (import wy.Backend.Assembler [convert_wy2hy])

; _____________________________________________________________________________/ }}}1

    (defn #^ str clrz_source2target
        [ #^ str source
          #^ str target]
        (sconcat (clrz_u f"{source}")
                 " -> "
                 (clrz_u f"{target}")))

; C: Classes ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defclass [] Wy2Hy_Args [BaseModel]
        (#^ (of List StrictStr) filenames)
        (#^ bool                silent_mode)
        (#^ bool                stdout_mode))

    (defclass FTYPE [Enum]
        (setv WY    0)
        (setv HY    1)
        (setv ERROR 2))

    (defclass RUN_MODE [Enum]
        (setv INFO        1)
        (setv STDOUT_1    2)
        (setv TRANSPILE_N 3))

    (defclass APP_ERROR [BaseModel]
        (setv #^ StrictStr msg "ERROR: unspecified")
        (defn __init__ [self #^ StrictStr msg] (-> (super) (.__init__ :msg msg))))

    (defclass Transpiled [BaseModel]
        (#^ StrictNumber time) ; in seconds 
        (#^ HyCode       code) ; not used anywhere really
        (defn __init__ [self #^ StrictNumber time #^ HyCode code] (-> (super) (.__init__ :time time :code code))))

; _____________________________________________________________________________/ }}}1
; F: ErrorHandling helpers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn normal_exit
        [ #^ (of Optional str) [msg None]
        ]
        (when (fnot noneQ msg) (print msg :file sys.stdout)) 
        (print (clrz_b "========================"))
        (sys.exit 0))

    (defn exit_with_error
        [ #^ int errorN ; 1 for general, >1 for others 
          #^ (of Optional str) [msg None]
        ]
        (print msg :file sys.stderr)
        (print (clrz_b "========================"))
        (sys.exit errorN))

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
; F: /monadic/ decide on run mode ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ (of Result RUN_MODE APP_ERROR)
        validate_args_and_decide_on_run_mode
        [ #^ Wy2Hy_Args args
        ]
        ;
        (setv _filenames (. args filenames))
        (setv _m_silent  (. args silent_mode))
        (setv _m_stdout  (. args stdout_mode))
        ;
        (when (oflenQ 0 _filenames) (return (Success RUN_MODE.INFO)))
        ;
        (when _m_stdout
            (when (fnot oflenQ 1 _filenames)
                  (return (Failure (APP_ERROR "ERROR: only one file (and which also should be of *.wy extension) should be used with -stdout mode"))))
            (when (neq (get_ft (first _filenames)) FTYPE.WY)
                  (return (Failure (APP_ERROR "ERROR: file extension should be *.wy"))))
            (return (Success RUN_MODE.STDOUT_1)))
        ;
        (bindR (filenames_pairable_possibility _filenames)
               (fn [it] (Success RUN_MODE.TRANSPILE_N))))

; _____________________________________________________________________________/ }}}1

; F: /monadic/ Runner: stdout_mode ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ (of Result HyCode APP_ERROR) 
        transpile_in_stdout_mode
        [ #^ StrictStr source_filename
        ]
        ;
        (try (setv _wy_code (read_file source_filename))
             (except [e Exception]
                     (return (Failure (APP_ERROR f"ERROR: cannot read {source_filename} (file not available?)")))))
        (try (setv _hy_code (convert_wy2hy _wy_code))
             (except [e Exception]
                     (return (Failure (APP_ERROR f"ERROR: transpilation failed for {source_filename} (incorrect syntax?)")))))
        ; 
        (return (Success _hy_code)))

; _____________________________________________________________________________/ }}}1

; F: Filename operations: utils ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ FTYPE
        get_ft
        [ #^ StrictStr filename
        ]
        (setv [root ext] (os.path.splitext filename))
        (cond (= ext ".wy") (return FTYPE.WY)
              (= ext ".hy") (return FTYPE.HY)
              True          (return FTYPE.ERROR)))

    (defn [validateF] #^ StrictStr
        change_filename_ext_to_hy
        [ #^ StrictStr filename
        ]
        "file1.wy -> file1.hy"
        (setv [root ext] (os.path.splitext filename))
        (return (sconcat root ".hy")))

; _____________________________________________________________________________/ }}}1
; F: /monadic/ Filename operations: try generate pairs ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ (of Result bool APP_ERROR)
        filenames_pairable_possibility
        [ #^ (of List StrictStr) filenames
        ]
        ; check if all files are *.wy or *.hy:
        (setv _types (lmap get_ft filenames))
        (when (in FTYPE.ERROR _types)
              (return (Failure (APP_ERROR "ERROR: files can only be of *.wy or *.hy extension"))))
        ; check if 1st file is *.wy:
        (when (neq (get_ft (first filenames)) FTYPE.WY)
              (return (Failure (APP_ERROR "ERROR: first provided file should be of *.wy type"))))
        ; check if *.hy follows *.wy (not another *.hy):
        (setv splitted_by_wy (lmulticut_by (fm (= (get_ft %1) FTYPE.WY))
                                           filenames
                                           :keep_border  True
                                           :merge_border False))
        (when (any (lmapm (>= (len %1) 3) splitted_by_wy))
              (return (Failure (APP_ERROR "ERROR: *.hy file may only follow *.wy file"))))
        ; 
        (Success True))

    ; should only be used on pairable input!
    (defn [validateF] #^ (of List (of Tuple StrictStr StrictStr))
        generate_filenames_pairs
        [ #^ (of List StrictStr) filenames
        ]
        (setv splitted_by_wy (lmulticut_by (fm (= (get_ft %1) FTYPE.WY))
                                           filenames
                                           :keep_border  True
                                           :merge_border False))
        ; add *.hy where were not provided:
        (lmapm (if (oflenQ 2 it)
                   it
                   [(first it) (change_filename_ext_to_hy (first it))])
               splitted_by_wy))

; _____________________________________________________________________________/ }}}1
; F: /monadic/ Runner: Transpile one wy-hy pair ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ (of Result Transpiled APP_ERROR)
        transpile_wy_file
        [ #^ StrictStr source_filename
          #^ StrictStr target_filename
        ]
        ;
        (setv _pre (sconcat (clrz_r "[xx] ") (clrz_source2target source_filename target_filename) ":"))
        (try (setv _wy_code (read_file source_filename))
             (except [e Exception]
                     (return (Failure (APP_ERROR f"{_pre} ERROR - can't read source file (file not available?)")))))
        (try (setv [_t_s _hy_code] (timing (fm (convert_wy2hy _wy_code))))
             (except [e Exception]
                     (return (Failure (APP_ERROR f"{_pre} ERROR - transpilation failed (incorrect syntax?)")))))
        (try (write_to_file _hy_code target_filename)
             (except [e Exception]
                     (return (Failure (APP_ERROR f"{_pre} ERROR - cannot write to target file (file not available?)")))))
        ;
        (return (Success (Transpiled _t_s _hy_code))))

; _____________________________________________________________________________/ }}}1

; Info message ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv $INFO_MSG (sconcat   "\nwy2hy usage:"
                             "\n\n  [-h] [-silent] [-stdout] file [file ...]"
                             "\n\n  - files can be of *.wy and *.hy extensions only"
                               "\n  - *.hy can only follow *.wy file"
                               "\n  - only one file (which has to be *.wy) can be used for -stdout mode"))

; _____________________________________________________________________________/ }}}1
; F: run wy2hy ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn unwrapEMsg [resultM] (. (unwrapE resultM) msg))
    (defn unwrapTime [resultM] (. (unwrapR resultM) time))

    (defn run_wy2hy_script [* [dummy_args None]] 
        "dummy_args are only for testing"
        ;
        (print (clrz_b "=== wy2hy transpiler ==="))
        (setv #^ Wy2Hy_Args wy2hy_args (if (noneQ dummy_args) (get_args) dummy_args))
        (setv #^ Result run_mode_result  (validate_args_and_decide_on_run_mode wy2hy_args))
        ; failure path (run_mode_result = Failure):
        (when (failureQ run_mode_result) (exit_with_error 1 (unwrapEMsg run_mode_result)))
        ; success path (run_mode_result = Success):
        (setv run_mode   (unwrapR run_mode_result)) 
        (setv _filenames (. wy2hy_args filenames))
        (setv _m_silent  (. wy2hy_args silent_mode))
        ;
        (when (eq run_mode RUN_MODE.INFO) (normal_exit $INFO_MSG))
        ;
        (when (eq run_mode RUN_MODE.STDOUT_1)
              (setv _resultSTD (transpile_in_stdout_mode (first _filenames)))
              (if (successQ _resultSTD)
                  (normal_exit (unwrapR _resultSTD)) ; this is print of HyCode to stdout
                  (exit_with_error 1 (unwrapEMsg _resultSTD))))
        ;
        (when (eq run_mode RUN_MODE.TRANSPILE_N) ; at this stage filenames are guaranteed to be pairable
              (setv _pairs (generate_filenames_pairs _filenames))
              (setv _failedFiles [])
              (lstarmap
                        (fm
                            (do (setv _resultT1 (transpile_wy_file %1 %2))
                                (if (successQ _resultT1)
                                    (unless _m_silent (print (clrz_g "[ok]") (clrz_source2target %1 %2) f": transpiled in {(unwrapTime _resultT1) :.3f} s"))
                                    (do (print (unwrapEMsg _resultT1))
                                        (_failedFiles.append %1)))))
                        _pairs)
              ;
              (if (oflenQ 0 _failedFiles)
                  (if _m_silent
                      (normal_exit)
                      (normal_exit "Transpilation is finished"))
                  (exit_with_error 1 "ERROR: Some transpilations failed"))))

; _____________________________________________________________________________/ }}}1

; /tests/ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (when (eq __name__ "__main__")
    ;   tests:
    ;   
    ;   (setv a1 (Wy2Hy_Args :filenames []              :silent_mode False :stdout_mode False))
    ;   (setv a2 (Wy2Hy_Args :filenames ["1.wy"]        :silent_mode False :stdout_mode True))
    ;   (setv a3 (Wy2Hy_Args :filenames ["1.hy"]        :silent_mode False :stdout_mode True))
    ;   (setv a4 (Wy2Hy_Args :filenames ["1.hy" "2.hy"] :silent_mode True  :stdout_mode True))
    ;   (setv a5 (Wy2Hy_Args :filenames ["1.hy" "2.hy"] :silent_mode False :stdout_mode False))
    ;   (setv a6 (Wy2Hy_Args :filenames ["1.wy"]        :silent_mode False :stdout_mode False))
    ;   (setv a7 (Wy2Hy_Args :filenames ["1.wy" "2.hy"] :silent_mode False :stdout_mode False))
    ;   (setv a8 (Wy2Hy_Args :filenames ["1.wy" "2.wy"] :silent_mode False :stdout_mode False))
    ;   ;
    ;   (run_wy2hy_script :dummy_args a8)
    )

; _____________________________________________________________________________/ }}}1


