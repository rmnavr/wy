
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
                                  :choices [ "_w" "_r" "_wr" "_rw" "_sw" "_sr" "_swr" "_srw" "_ws" "_rs" "_wsr" "_rsw" "_wrs" "_rws" ]
                                  :default "_m"
                                  :help    "options: f - write and run from file, w - write to file, m - run from memory, s - silent")

        (_cmd_parser.add_argument "filename"
                                  :type    str
                                  :default None
                                  :help    "name/fullname of the *.wy file to process (if fullname is given, will cd to it's dir if mem/file run was requested)")
        (return (_cmd_parser.parse_args)))

; _____________________________________________________________________________/ }}}1
; [F] process cmd args ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1


"_w"  
"_m"  
"_f"  
"_wm" 
"_mw" 
"_wf" 
"_fw" 








    (defn
        process_cmd_args
        [ cmd_args
        ]
        (case cmd_args
              "_w"    (setv writeQ True  to_runQ False silentQ False)
              "_r"    (setv writeQ False to_runQ True  silentQ False)
              "_wr"   (setv writeQ True  to_runQ True  silentQ False)
              "_rw"   (setv writeQ True  to_runQ True  silentQ False)
              ;
              "_sw"   (setv writeQ True  to_runQ False silentQ True )
              "_sr"   (setv writeQ False to_runQ True  silentQ True )
              "_swr"  (setv writeQ True  to_runQ True  silentQ True )
              "_srw"  (setv writeQ True  to_runQ True  silentQ True )
              ;
              "_ws"   (setv writeQ True  to_runQ False silentQ True )
              "_rs"   (setv writeQ False to_runQ True  silentQ True )
              "_wsr"  (setv writeQ True  to_runQ True  silentQ True )
              "_rsw"  (setv writeQ True  to_runQ True  silentQ True )
              ;
              "_wrs"  (setv writeQ True  to_runQ True  silentQ True )
              "_rws"  (setv writeQ True  to_runQ True  silentQ True ))
        (return [writeQ to_runQ silentQ]))

; _____________________________________________________________________________/ }}}1
; [F] process filename ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ (of Tuple str str str)
        process_filename
        [ #^ str filename #_ "possibly full filename"
        ]
        "will return full filenames if filename included dir, will return just filenames otherwise"
        (when (not_ os.path.isfile filename) (raise (Exception f"file {filename} does not exist")))
        ; directory will be "" if no dir was provided
        ; directory will have no "\\" at the end
        (setv [directory filename_with_wy_extension] (os.path.split filename))
        (setv [filename_without_extention extension] (os.path.splitext filename_with_wy_extension))
        (when (neq extension ".wy") (raise (Exception "file must be of *.wy extension")))
        ;
        (setv output_filename ; possibly full filename
              (sconcat (if (= directory "") "" (sconcat directory "\\"))
                       filename_without_extention
                       ".hy"))
        (return [ directory
                  filename
                  output_filename]))

; _____________________________________________________________________________/ }}}1
; [F] transpile ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ HyCodeFull
        transpile_wy_file
        [ #^ str  filename #_ "possibly full filename"
          #^ bool silent_mode
        ]
        (setv _wy_code (file_to_code filename))
        (setv [_t_s prompt _hy_code] (execution_time (fm (wy2hy _wy_code)) :tUnit "s"))
        (unless silent_mode (print f"[wy2hy] [V] tranpilation is successful (done in {_t_s :.3f} seconds)"))
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
        run_hy_code
        [ #^ HyCodeFull code_to_run
          #^ str        directory #_ "to run code from"
          #^ bool       silent_mode
        ]
        (unless (= directory "") (os.chdir directory))
        (unless $SILENTQ (print "--- run transpiled code (from memory) ---"))
        (-> code_to_run hy.read_many hy.eval))


; _____________________________________________________________________________/ }}}1

    (setv $CMD_ARGS (setup_cmd_parser))
    (setv [$WRITEQ $TO_RUN $SILENTQ] (process_cmd_args $CMD_ARGS.options))
    (setv [$INPUT_DIR $INPUT_FULL_FILENAME $OUTPUT_FULL_FILENAME] (process_filename $CMD_ARGS.filename))

    (setv _hy_code (transpile_wy_file $INPUT_FULL_FILENAME $SILENTQ))
    (when $WRITEQ  (write_hy_file $OUTPUT_FULL_FILENAME _hy_code $SILENTQ))
    (when $TO_RUN  (run_hy_code _hy_code $INPUT_DIR $SILENTQ))



;# Command to be executed
;command = "dir"  # Example command to list directory contents
;
;# Call the command
;result = subprocess.run(command, shell=True, text=True, capture_output=True)
;
;# Print the output and error (if any)
;print("Output:\n", result.stdout)
;print("Error:\n", result.stderr)
