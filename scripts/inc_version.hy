
; Doc ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; incv -minor   // 0.3.0.dev10 -> 0.4.0
    ; incv -patch   // 0.3.0.dev10 -> 0.3.1 

    ; incv -dev     // 0.3.0.dev10 -> 0.3.0.dev11
    ;               // 0.3.0       -> 0.3.0.dev1

; _____________________________________________________________________________/ }}}1
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import  _fptk_local *)
    (require _fptk_local *)

    (import dataclasses [replace :as dc_replace])

    (import  argparse)

; _____________________________________________________________________________/ }}}1

; PURE FUNCTIONS:
; C: Classes ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defclass CLI_CMD [Enum]
        (setv UPD_MAJOR 0)
        (setv UPD_MINOR 1)
        (setv UPD_PATCH 2)
        (setv UPD_DEV   3)
        (setv NONE      4))

    (defclass [dataclass] Version []
        (#^ int major)
        (#^ int minor)
        (#^ int patch)
        (#^ (of Optional int) dev)      ; None when not present
        ;
        (defn __str__ [self] 
            (setv _maybe_dev (if (noneQ self.dev) "" f".dev{self.dev}"))
            (sconcat f"{self.major}.{self.minor}.{self.patch}{_maybe_dev}")))

; _____________________________________________________________________________/ }}}1
; F: deconstruct version string ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1


    (defn #^ Version
        version_string_to_Version
        [ #^ str vstring ; like "0.3.0.dev1"
        ]
        ;                      (1  )  (2  )  (3  )(4    ) (5  )  regex will produce None for empty matches
        (setv parts (re_find r"(\d+)\.(\d+)\.(\d+)(\.dev)?(\d+)?" vstring))
        (Version :major (int (first  parts))
                 :minor (int (second parts))
                 :patch (int (third  parts))
                 :dev   (if (noneQ (last parts))
                            None
                            (int (last parts)))))

; _____________________________________________________________________________/ }}}1
; F: increase version ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ Version
        inc_version
        [ #^ Version v0
          #^ CLI_CMD target  ; major, minor, patch, dev
        ]
        (case target
              CLI_CMD.UPD_MAJOR (dc_replace v0 :major (inc v0.major) :dev None)
              CLI_CMD.UPD_MINOR (dc_replace v0 :minor (inc v0.minor) :dev None)
              CLI_CMD.UPD_PATCH (dc_replace v0 :patch (inc v0.patch) :dev None)
              CLI_CMD.UPD_DEV   (dc_replace v0 :dev   (if (noneQ v0.dev) 1 (inc v0.dev)))
              CLI_CMD.NONE      v0))

; _____________________________________________________________________________/ }}}1
; /test/ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; (version_string_to_Version "0.3.10.dev2")
    ; (version_string_to_Version "0.3.10")

    ; (setv v00 (Version 1 1 1 3))
    ; (print v00)
    ; (print (inc_version v00 :target "major"))
    ; (print (inc_version v00 :target "minor"))
    ; (print (inc_version v00 :target "patch"))
    ; (print (inc_version v00 :target "dev"))

; _____________________________________________________________________________/ }}}1

; IO:
; F: prepare cli args ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ CLI_CMD
        get_cli_cmd []
        ;
        (setv parser (argparse.ArgumentParser))
        (parser.add_mutually_exclusive_group :required False)
        (parser.add_argument "-major" :action "store_true")
        (parser.add_argument "-minor" :action "store_true")
        (parser.add_argument "-patch" :action "store_true")
        (parser.add_argument "-dev"   :action "store_true")
        (setv args (parser.parse_args))
        ;
        (cond args.major CLI_CMD.UPD_MAJOR
              args.minor CLI_CMD.UPD_MINOR
              args.patch CLI_CMD.UPD_PATCH
              args.dev   CLI_CMD.UPD_DEV
              True       CLI_CMD.NONE))

; _____________________________________________________________________________/ }}}1

; ========================================================================

    (setv $SOURCE_FILE  "../setup.py")

    (setv _file_content (read_file $SOURCE_FILE))
    (setv _cli_cmd (get_cli_cmd))

    ; exit when no "proj_version = " string was found
    (when (noneQ (re_find r"proj_version = '(.*)'" _file_content))
          (print f"ERROR: 'proj_version' string was not found in {$SOURCE_FILE}")
          (sys.exit 1))

    (setv _v0 (->> _file_content
                   (re_find r"proj_version = '(.*)'")
                   (version_string_to_Version)))
    (print "Found cur version: " (str _v0))

    ; when no args were given — only prompt cur version
    (when (eq _cli_cmd CLI_CMD.NONE)
          (print "\nno version upd made, since instruction was not provided"
                 "\n(options: -major, -minor, -patch, -dev)")
          (sys.exit 1))

    (setv _v1 (inc_version _v0 _cli_cmd))

    (write_file (re_sub r"proj_version = '.*'"
                        f"proj_version = '{(str _v1)}'"
                        _file_content)
                $SOURCE_FILE)
    (print "Updated to version:" (str _v1))

