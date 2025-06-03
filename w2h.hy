; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import argparse)
    (import os)
    (import subprocess)

    (import AppLayer [file_to_code wy2hy])
    (import Classes *)

    (import sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))

    (require hyrule [of as-> -> ->> doto case branch unless lif do_n list_n ncut])
    (import  _hyextlink *)
    (require _hyextlink [f:: fm p> pluckm lns &+ &+> l> l>=] :readers [L])

; _____________________________________________________________________________/ }}}1

; [F] setup cmd parser ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn
        setup_cmd_parser
        [ ]
        (setv _cmd_parser (argparse.ArgumentParser :description "Process a command line argument"))
        (_cmd_parser.add_argument "options"
                                  :nargs   "?" ; optional
                                  :choices [ "_w"   "_m"   "_f"   "_wm"  "_mw"  "_wf"  "_fw" 
                                             "_sw"  "_sm"  "_sf"  "_swm" "_smw" "_swf" "_sfw" 
                                             "_ws"  "_ms"  "_fs"  "_wsm" "_msw" "_wsf" "_fsw" 
                                             "_wms" "_mws" "_wfs" "_fws" 
                                           ]
                                  :default "_m"
                                  :help    "options: f - write and run from file, w - write to file, m - run from memory, s - silent")

        (_cmd_parser.add_argument "filename"
                                  :type    str
                                  :default None
                                  :help    "name/fullname of the *.wy file to process (if fullname is given, will cd to it's dir if mem/file run was requested)")
        (return (_cmd_parser.parse_args)))

; _____________________________________________________________________________/ }}}1
; [F] process cmd args ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defclass [dataclass] RunOption []
        (setv NO_RUN    0)
        (setv FROM_FILE 1)
        (setv FROM_MEM  2))

    (defn
        process_cmd_args
        [ cmd_args
        ]
        (setv _options (list (cut cmd_args 1 None)))
        (setv memQ    (in "m" _options))
        (setv fileQ   (in "f" _options))
        (setv writeQ  (or (in "f" _options)
                          (in "w" _options)))
        (setv silentQ (in "s" _options))
        (case [memQ fileQ]
            [False False] (setv how_to_run RunOption.NO_RUN)
            [True  False] (setv how_to_run RunOption.FROM_MEM)
            [False True ] (setv how_to_run RunOption.FROM_FILE)
            [True  True ] "this case is unreachable")
        (return [writeQ how_to_run silentQ]))

; _____________________________________________________________________________/ }}}1
; [F] process filename ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of Tuple str str str)
        process_filename
        [ #^ str filename #_ "possibly full filename"
        ]
        "will return full filenames"
        (when (not_ os.path.isfile filename) (raise (Exception f"file {filename} does not exist")))
        ; directory will be "" if no dir was provided
        ; directory will have no "\\" at the end
        (setv [directory filename_with_wy_extension] (os.path.split filename))
        (setv [filename_without_extention extension] (os.path.splitext filename_with_wy_extension))
        (when (neq extension ".wy") (raise (Exception "file must be of *.wy extension")))
        ;
        (when (= directory "") (setv directory (os.getcwd)))
        (setv output_filename (sconcat directory "\\" filename_without_extention ".hy"))
        (return [ directory filename output_filename]))

; _____________________________________________________________________________/ }}}1
; [F] transpile ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ HyCodeFull
        transpile_code_from_wy_file
        [ #^ str  filename #_ "possibly full filename"
          #^ bool silent_mode
        ]
        (setv _wy_code (file_to_code filename))
        (setv [_t_s prompt _hy_code] (execution_time (fm (wy2hy _wy_code)) :tUnit "s"))
        (unless silent_mode (print f"[wy2hy] [V] transpilation is successful (done in {_t_s :.3f} seconds)"))
        (return _hy_code))

; _____________________________________________________________________________/ }}}1
; [F] write to file ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ None
        write_hy_file
        [ #^ str        filename #_ "possibly full filename"
          #^ HyCodeFull code_to_write
          #^ bool       silent_mode
        ]
        (try (with [file (open filename
                          "w"
                          :encoding "utf-8")]
                   (file.write code_to_write))
             (unless silent_mode (print f"[wy2hy] [V] file {filename} is written"))
             (except [e Exception] (raise (Exception "could not write a file")))))

; _____________________________________________________________________________/ }}}1
; [F] run ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ None
        run_hy_code_from_memory
        [ #^ HyCodeFull code_to_run
          #^ str        directory #_ "to run code from"
          #^ bool       silent_mode
        ]
        (unless (= directory "") (os.chdir directory))
        (unless silent_mode (do (print "[wy2hy] Running transpiled code from memory ...")
                                (print "")))
        (-> code_to_run hy.read_many hy.eval))

    (defn #^ None
        run_hy_code_from_file
        [ #^ str        filename  #_ "possibly full filename"
          #^ str        directory #_ "to run code from"
          #^ bool       silent_mode
        ]
        "relies on <hy> command present in the system"
        ; info: dir from [filename] and [directory] may be different
        (unless (= directory "") (os.chdir directory))
        (setv _command (sconcat "hy \"" filename "\""))
        (setv result (subprocess.run _command
                                     :shell          True
                                     :text           True
                                     :capture_output True))
        (unless silent_mode (do (print f"[wy2hy] Running transpiled code from file {(second (os.path.split filename))} ...")
                                (print "")))
        (print result.stdout)
        (print result.stderr))

; _____________________________________________________________________________/ }}}1

    (setv $CMD_ARGS (setup_cmd_parser))
    (setv [$WRITEQ $HOW_TO_RUN $SILENTQ] (process_cmd_args $CMD_ARGS.options))
    (setv [$SOURCE_DIR $INPUT_FULL_FILENAME $OUTPUT_FULL_FILENAME] (process_filename $CMD_ARGS.filename))
    ;(setv [$WRITEQ $TO_RUN $SILENTQ] [True True False])
    ;(setv [$INPUT_DIR $INPUT_FULL_FILENAME $OUTPUT_FULL_FILENAME] ["" "_test5.wy" "_test5.hy"])

    (setv _hy_code (transpile_code_from_wy_file $INPUT_FULL_FILENAME  $SILENTQ))
    (when $WRITEQ  (write_hy_file $OUTPUT_FULL_FILENAME _hy_code $SILENTQ))
    (case $HOW_TO_RUN
        RunOption.FROM_MEM  (run_hy_code_from_memory _hy_code $SOURCE_DIR $SILENTQ)
        RunOption.FROM_FILE (run_hy_code_from_file   $OUTPUT_FULL_FILENAME $SOURCE_DIR $SILENTQ))

