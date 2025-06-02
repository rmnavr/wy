
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import argparse)
    (import os)

    (import AppLayer [file_to_code wy2hy])

    (import sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))

    (require hyrule [of as-> -> ->> doto case branch unless lif do_n list_n ncut])
    (import  _hyextlink *)
    (require _hyextlink [f:: fm p> pluckm lns &+ &+> l> l>=] :readers [L])

; _____________________________________________________________________________/ }}}1

; get args ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv _cmd_parser (argparse.ArgumentParser :description "Process a command line argument"))

    (_cmd_parser.add_argument "options"
                              :nargs   "?" ; optional
                              :choices ["_w" "_wr" "_r"]  
                              :default "_r"
                              :help    "options: _r - only run, _w - only write .hy file, _wr - write and run (from memory)")

    (_cmd_parser.add_argument "filename"
                              :type    str
                              :default None
                              :help    "name of the *.wy file to process")

    (setv cmd_args (_cmd_parser.parse_args))

; _____________________________________________________________________________/ }}}1

    (case cmd_args.options 
          "_r"  (setv $TO_RUN True  $TO_WRITE False)
          "_w"  (setv $TO_RUN False $TO_WRITE True )
          "_wr" (setv $TO_RUN True  $TO_WRITE True))

    (setv $INPUT_FILE_NAME cmd_args.filename)

    (when (not_ os.path.isfile $INPUT_FILE_NAME) 
          (raise (Exception f"file {$INPUT_FILE_NAME} does not exist")))

    (setv [name extension] (os.path.splitext $INPUT_FILE_NAME))
    (when (neq extension ".wy")
          (raise (Exception "file must be of *.wy extension")))

    (setv $OUTPUT_FILE_NAME (sconcat name ".hy"))

    ; 1) Transpile:
    (setv _wy_code (file_to_code $INPUT_FILE_NAME))
    (setv _hy_code (wy2hy _wy_code))
    (print "[wy2hy] [V] tranpilation is successful")

    ; 2) Write:
    (if $TO_WRITE
        (try (with [file (open $OUTPUT_FILE_NAME
                          "w"
                          :encoding "utf-8")]
                   (file.write _hy_code))
             (print f"[wy2hy] [V] file {$OUTPUT_FILE_NAME} is written")
             (except [e Exception] (raise (Exception "could not write a file"))))
        (print "[wy2hy] [~] no file write was requested, skipping"))

    ; 3 Run:
    (if $TO_RUN
        (do (print "--- run transpiled code (from memory) ---")
            (-> _hy_code hy.read_many hy.eval))
        (print "[wy2hy] [~] no run was requested, skipping"))

