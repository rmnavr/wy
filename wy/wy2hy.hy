
    ; TODO:
    ; append wy version to auto-generated hy files

; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import  wy._fptk_local *)
    (require wy._fptk_local *)

    (import sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))

    (import argparse)

    (import  wy.Classes  [HyCode])
    (import  wy.AppLayer [convert_wy2hy])

; _____________________________________________________________________________/ }}}1

; F: ErrorHandling ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn normal_exit [] (sys.exit 0))

    (defn exit_with_msg
        [ #^ str text 
          *
          #^ int [errorN 1]
        ]
        (print text)
        (sys.exit errorN))

    (defn exit_with_stderr
        [ #^ str text 
          *
          #^ int [errorN 1]
        ]
        (print text :file sys.stderr)
        (sys.exit errorN))


; _____________________________________________________________________________/ }}}1
; F: Get user provided args ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defclass [dataclass] Wy2Hy_Args []
        (#^ (of List str) filenames)
        (#^ bool          silent_mode)
        (#^ bool          stdout_mode))

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
; F: Prepare filenames ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defclass FTYPE [Enum]
        (setv WY    0)
        (setv HY    1)
        (setv ERROR 2))

    (defn #^ FTYPE get_ft [#^ str filename]
        (setv [root ext] (os.path.splitext filename))
        (cond (= ext ".wy") (return FTYPE.WY)
              (= ext ".hy") (return FTYPE.HY)
              True          (return FTYPE.ERROR)))

    (defn #^ str wy_ext_to_hy_ext [#^ str filename]
        (when (fnot file_existsQ filename) 
              (exit_with_msg f"File {filename} does not exist!"))
        (when (fnot fileQ filename) 
              (exit_with_msg f"{filename} is dir, but it has to be a file!"))
        (when (fnot fileQ filename) 
              (Exception f"{filename} is dir, but need to be a file!"))
        (setv [root ext] (os.path.splitext filename))
        (return (sconcat root ".hy")))

    (defn #^ (of List (of Tuple str str))
        generate_wy_hy_filename_pairs
        [ #^ (of List str) filenames
        ]
        (lmapm (when (eq (get_ft it) FTYPE.ERROR) 
                     (exit_with_msg (sconcat "BAD ARG: " it " (need to be of *.wy or *.hy filetype)")))
               filenames)
        (when (neq (get_ft (first filenames)) FTYPE.WY)
              (exit_with_msg "BAD ARGS: first provided file should be of *.wy type"))
        ;
        (setv splitted_by_wy (lmulticut_by (fm (= (get_ft %1) FTYPE.WY))
                                           filenames
                                           :keep_border  True
                                           :merge_border False))
        (when (any (lmapm (>= (len %1) 3) splitted_by_wy))
              (exit_with_msg "BAD ARGS: *.hy may only follow *.wy"))
        ; add *.hy where were not provided:
        (lmapm (if (oflenQ it 2)
                   it
                   [(first it) (wy_ext_to_hy_ext (first it))])
               splitted_by_wy))

; _____________________________________________________________________________/ }}}1
; F: Transpile one wy-hy pair ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ HyCode
        transpile_wy_file
        [ #^ str  source_filename
          #^ str  target_filename
          #^ bool silent_mode
        ]
        (unless silent_mode (print f"Attempting transpilation: {source_filename} -> {target_filename}"))
        (try (setv _wy_code (read_file source_filename))
             (unless silent_mode (print f"[V] successfully opened file {source_filename}"))
             (except [e Exception] (exit_with_msg "ERROR: cannot read {source_filename} (file not available?)")))
        (try (setv [_t_s prompt _hy_code] (with_execution_time (fm (convert_wy2hy _wy_code)) :tUnit "s"))
             (unless silent_mode (print f"[V] transpilation is successful (done in {_t_s :.3f} seconds)"))
             (except [e Exception] (exit_with_msg f"ERROR: transpilation failed for {source_filename} (incorrect syntax?)")))
        (try (write_file _hy_code target_filename)
             (unless silent_mode (print f"[V] file {target_filename} is written\n"))
             (except [e Exception] (exit_with_msg f"ERROR: cannot write {target_filename} (file not available?)"))))

; _____________________________________________________________________________/ }}}1
; F: stdout_mode ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ HyCode
        transpile_to_stdout
        [ #^ str  source_filename
        ]
        (try (setv _wy_code (read_file source_filename))
             (except [e Exception] (exit_with_stderr "ERROR: cannot read {source_filename} (file not available?)")))
        (try (setv _hy_code (convert_wy2hy _wy_code))
             (except [e Exception] (exit_with_stderr f"ERROR: transpilation failed for {source_filename} (incorrect syntax?)")))
        (print _hy_code))

; _____________________________________________________________________________/ }}}1

    (defn run_wy2hy_script []
        ;
        (setv wy2hy_args (get_args))
        (setv _filenames (. wy2hy_args filenames))
        (setv _m_silent  (. wy2hy_args silent_mode))
        (setv _m_stdout  (. wy2hy_args stdout_mode))
        ;
        (when (oflenQ _filenames 0)
              (exit_with_msg (sconcat "wy2hy usage:"
                                      "\n  [-h] [-silent] [-stdout] file [file ...]"
                                      "\n"
                                      "\n  - files can be only of *.wy and *.hy extensions"
                                      "\n  - *.hy can only follow *.wy file"
                                      "\n  - only one *.wy file can be used for -stdout mode")
                             :errorN 0))
        ;
        (when _m_stdout (when (fnot oflenQ _filenames 1)
                              (exit_with_msg "ERROR: only one *.wy file should be used with -stdout mode"))
                        (wy_ext_to_hy_ext (first _filenames)) ; this only checks if file is available
                        (transpile_to_stdout (first _filenames))
                        (normal_exit))
        ;
        (setv _pairs (generate_wy_hy_filename_pairs _filenames))
        (lstarmap (fm (transpile_wy_file %1 %2 :silent_mode _m_silent)) _pairs)
        (exit_with_msg "Transpilation is done successfully" :errorN 0))

    ; (run_wy2hy_script)
    ; why wy2hy_new.hy test_dir/1.wy
    ; why wy2hy_new.hy test_dir/1.wy -stdout
    ; why wy2hy_new.hy test_dir/1.wy -silent

