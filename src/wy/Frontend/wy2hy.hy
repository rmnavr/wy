
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

    (import wy.Backend.Classes       [HyCode])
    (import wy.Frontend.ErrorHelpers [run_wy2hy_transpilation])

; _____________________________________________________________________________/ }}}1

; Predefined app messages ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv $NOGO (clrz_r "[wy2hy no run]"))
    (setv $TXX  (sconcat (clrz_r "[trnspl xx]") " ERROR:"))

    (defclass [dataclass] PMsg []
        "predefined message;
         and also preparators for msgs (see attrs starting with f_)"
        ;
        (setv welcome      (clrz_b "=== wy2hy transpiler ==="))
        (setv goodbuy      (clrz_b "========================")) 
        (setv info         (sconcat "\nwy2hy usage:"
                                  "\n\n  [-h] [-silent] [-stdout] file [file ...]"
                                  "\n\n  - files can be of *.wy and *.hy extensions only"
                                    "\n  - *.hy can only follow *.wy file"
                                    "\n  - only one file (which has to be *.wy) can be used for -stdout mode"
                                    "\n"))
        ;
        (setv std_n_err    f"{$NOGO} ERROR: only one file (and which also should be of *.wy extension) should be used with -stdout mode")
        (setv std_ext_err  f"{$NOGO} ERROR: file extension should be *.wy")
        (setv f_std_read   (fn [source_filename]
                               (sconcat (clrz_r "[trnspl xx]")
                                        " ERROR: cannot read "
                                        (clrz_u source_filename)
                                        " (file not available?)")))
        (setv f_std_tr     (fn [source_filename]
                               (sconcat (clrz_r "[trnspl xx]")
                                        " ERROR: transpilation failed for "
                                        (clrz_u source_filename))))
        ;
        (setv pairs_ext    f"{$NOGO} ERROR: files can only be of *.wy or *.hy extension")
        (setv pairs_1wy    f"{$NOGO} ERROR: first provided file should be of *.wy type")
        (setv pairs_wyhy   f"{$NOGO} ERROR: *.hy file may only follow *.wy file")
        ;
        (setv trspl_read   f"{$TXX} Can't read source file (file not available?)")
        (setv trspl_bad    f"{$TXX} Transpilation failed")
        (setv trspl_write  f"{$TXX} Cannot write to target file (file not available?)")
        ;
        (setv f_file1_ok   (fn [time_s] (sconcat (clrz_g "[trnspl ok]") f" transpiled in {time_s :.3f} s")))
        (setv finale_good  (clrz_g "All transpilations were successfull"))
        (setv finale_bad   (clrz_r "Some transpilations failed"))
        )

; _____________________________________________________________________________/ }}}1
; utils: clrz_source2target ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ str clrz_source2target
        [ #^ str source
          #^ str target]
        (sconcat (clrz_u f"{source}")
                 " -> "
                 (clrz_u f"{target}")))

; _____________________________________________________________________________/ }}}1

; [C] Classes ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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
; [F] ErrorHandling helpers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn normal_exit
        [ #^ (of Optional str) [msg None]
          #^ bool              [closing_msg True]
        ]
        (when (notnoneQ msg) (print msg)) 
        (when closing_msg    (print PMsg.goodbuy))
        (sys.exit 0))

    (defn exit_with_error
        [ #^ int errorN ; 1 for general, >1 for others 
          #^ (of Optional str) [msg None]
          #^ bool              [closing_msg True]
        ]
        (when (notnoneQ msg) (print :file sys.stderr msg))
        (when closing_msg    (print :file sys.stderr PMsg.goodbuy))
        (sys.exit errorN))

; _____________________________________________________________________________/ }}}1

; [F] Get user provided args ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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
; [F] /monadic/ decide on run mode ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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
                  (return (Failure (APP_ERROR PMsg.std_n_err))))
            (when (neq (get_ft (first _filenames)) FTYPE.WY)
                  (return (Failure (APP_ERROR PMsg.std_ext_err))))
            (return (Success RUN_MODE.STDOUT_1)))
        ;
        (bindR (filenames_pairable_possibility _filenames)
               (fn [it] (Success RUN_MODE.TRANSPILE_N))))

; _____________________________________________________________________________/ }}}1

; [F] /monadic/ Runner: stdout_mode ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ (of Result HyCode APP_ERROR) 
        transpile_in_stdout_mode
        [ #^ StrictStr source_filename
        ]
        ;
        (try (setv _wy_code (read_file source_filename))
             (except [e Exception]
                     (return (Failure (APP_ERROR (PMsg.f_std_read source_filename))))))
        ;
        (setv _trnsplR (run_wy2hy_transpilation _wy_code)) ; Result[HyCode, PrettyTEMsg]
        (when (failureQ _trnsplR)
              (setv tr_err_msg (-> _trnsplR unwrapE (getattrm .msg)))
              (return (Failure (APP_ERROR (sconcat f"{tr_err_msg}\n" (PMsg.f_std_tr source_filename))))))
        ; 
        (return _trnsplR)) ; Result[HyCode, APP_ERROR] 

; _____________________________________________________________________________/ }}}1

; [F] Filename operations: utils ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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
; [F] /monadic/ Filename operations: try generate pairs ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn [validateF] #^ (of Result bool APP_ERROR)
        filenames_pairable_possibility
        [ #^ (of List StrictStr) filenames
        ]
        ; check if all files are *.wy or *.hy:
        (setv _types (lmap get_ft filenames))
        (when (in FTYPE.ERROR _types)
              (return (Failure (APP_ERROR PMsg.pairs_ext))))
        ; check if 1st file is *.wy:
        (when (neq (get_ft (first filenames)) FTYPE.WY)
              (return (Failure (APP_ERROR PMsg.pairs_1wy))))
        ; check if *.hy follows *.wy (not another *.hy):
        (setv splitted_by_wy (lmulticut_by (fm (= (get_ft %1) FTYPE.WY))
                                           filenames
                                           :keep_border  True
                                           :merge_border False))
        (when (any (lmapm (>= (len %1) 3) splitted_by_wy))
              (return (Failure (APP_ERROR PMsg.pairs_wyhy))))
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
; [F] /monadic/ Runner: Transpile one wy-hy pair ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1


    (defn [validateF] #^ (of Result Transpiled APP_ERROR)
        transpile_wy_file
        [ #^ StrictStr source_filename
          #^ StrictStr target_filename
        ]
        ;
        (try (setv _wy_code (read_file source_filename))
             (except [e Exception]
                     (return (Failure (APP_ERROR PMsg.trspl_read)))))
        ;
        (setv [_t_s _trnsplR]
              (timing run_wy2hy_transpilation _wy_code))
        (if (failureQ _trnsplR)
            (do (setv tr_err_msg (-> _trnsplR unwrapE (getattrm .msg)))
                (return (Failure (APP_ERROR (sconcat f"{tr_err_msg}\n" PMsg.trspl_bad) ))))
            (try (write_to_file (unwrapR _trnsplR) target_filename)
                 (except [e Exception]
                         (return (Failure (APP_ERROR PMsg.trspl_write))))))
        ;
        (return (Success (Transpiled _t_s (unwrapR _trnsplR)))))

; _____________________________________________________________________________/ }}}1

; [F] run wy2hy modes ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; helpers:
    (defn unwrapEMsg [resultM] (. (unwrapE resultM) msg))  ; for run_mode_result/transpilation_result
    (defn unwrapTime [resultM] (. (unwrapR resultM) time)) ; for transpilation_result

    (defn run_wy2hy_incorrect_mode
        [ #^ (of Result RUN_MODE APP_ERROR) run_mode_result
        ]
        "de facto: called for incorrect files for stdout-mode"
        (print :file sys.stderr PMsg.welcome)
        (exit_with_error 1 (unwrapEMsg run_mode_result)))

    (defn run_wy2hy_info_mode []
        (print PMsg.welcome)
        (normal_exit PMsg.info))

    (defn run_wy2hy_stdout_mode
        [ #^ (of List StrictStr) filenames
        ]
        (setv _resultSTD (transpile_in_stdout_mode (first filenames)))
        (if (successQ _resultSTD)
            (normal_exit (unwrapR _resultSTD) :closing_msg False)
            (exit_with_error 1 (unwrapEMsg _resultSTD) :closing_msg False)))

    (defn run_wy2hy_transpileN_mode
        [ #^ (of List StrictStr) filenames
          #^ bool                silent_mode
        ]
        (setv _pairs (generate_filenames_pairs filenames))
        (setv _failedFiles [])
        ; aim of variable soloFileMode:
        ; when only 1 file is transpiled, do not print it as "1) f.wy -> f.hy", but just "f.wy -> f.hy" instead
        (setv soloFileMode (oflenQ 1 _pairs)) 
        ;
        (unless silent_mode (print PMsg.welcome))
        (lmap
             (fm
                 (do (unless silent_mode
                             (setv prefix
                                   (if soloFileMode
                                       "\n"
                                       (sconcat "\n" (str %2) ") ")))
                             (print (sconcat prefix (clrz_source2target #* %1))))
                     (setv _resultT1 (transpile_wy_file #* %1))
                     (if (successQ _resultT1)
                         (unless silent_mode
                                 (print (PMsg.f_file1_ok (unwrapTime _resultT1))))
                         (do (print (unwrapEMsg _resultT1)) ; prints NOT to stderr, yes
                             (_failedFiles.append (first %1))))))
             _pairs  ; of [wy -> hy] files
             (inf_range 1)) 
        (print "")
        ;
        (if (oflenQ 0 _failedFiles)
            (if silent_mode
                (normal_exit :closing_msg False)
                (normal_exit (if soloFileMode None PMsg.finale_good)))
            (exit_with_error 1 (if soloFileMode None PMsg.finale_bad)
                             :closing_msg (not silent_mode))))

; _____________________________________________________________________________/ }}}1
; [F] run wy2hy ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn run_wy2hy_script
        [ *
          #^ Wy2Hy_Args [dummy_args None]
        ] 
        "dummy_args are only for testing"
        ;
        (setv wy2hy_args
              (if (noneQ dummy_args)
                  (get_args)
                  dummy_args))
        (setv run_mode_result (validate_args_and_decide_on_run_mode wy2hy_args))
        ;
        (if (failureQ run_mode_result)
            (run_wy2hy_incorrect_mode run_mode_result)
            ;
            (do (setv run_mode   (unwrapR run_mode_result)) 
                (setv _filenames wy2hy_args.filenames)
                (setv _m_silent  wy2hy_args.silent_mode)
                ;
                (cond (eq run_mode RUN_MODE.INFO)        (run_wy2hy_info_mode)
                      (eq run_mode RUN_MODE.STDOUT_1)    (run_wy2hy_stdout_mode     _filenames)
                      (eq run_mode RUN_MODE.TRANSPILE_N) (run_wy2hy_transpileN_mode _filenames _m_silent))))) ; at this stage filenames are guaranteed to be pairable

; _____________________________________________________________________________/ }}}1

