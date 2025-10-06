
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import  wy._fptk_local *)
    (require wy._fptk_local *)
    (import sys)
    (. sys.stdout (reconfigure :encoding "utf-8"))

    (import argparse)

    (import  wy.AppLayer [convert_wy2hy])

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
                             :nargs "+" 
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

    (defclass FTYPE [Enum]
        (setv WY    0)
        (setv HY    1)
        (setv ERROR 2))

    (defn #^ FTYPE get_ft [#^ str filename]
        (cond (re_test r"\.wy$" filename) (return FTYPE.WY)
              (re_test r"\.hy$" filename) (return FTYPE.HY)
              True                        (return FTYPE.ERROR)))

    (defn #^ (of List (of Tuple str str))
        generate_wy_hy_filename_pairs
        [ #^ (of List str) filenames
        ]
        (when (in FTYPE.ERROR (lmap get_ft filenames))
              (raise (Exception "BAD ARGS: files can only be of *.wy and *.hy extension")))
        (when (neq (get_ft (get filenames 0)) FTYPE.WY)
              (raise (Exception "BAD ARGS: first provided file should be of *.wy type")))
        ;
        (setv splitted_by_wy (lmulticut_by (fm (= (get_ft %1) FTYPE.WY))
                                           filenames
                                           :keep_border  True
                                           :merge_border False))
        (when (any (lmapm (>= (len %1) 3) splitted_by_wy))
              (raise (Exception "BAD ARGS: *.hy may only follow *.wy")))
        ; add *.hy where were not provided:
        ; TO BE DONE
        (return splitted_by_wy))

    (setv args_for_test ["1.wy" "2.wy" "2.hy" "3.wy" "3.hy" "4.wy"])

    (setv args (get_args))
    (print (generate_wy_hy_filename_pairs args.filenames))

