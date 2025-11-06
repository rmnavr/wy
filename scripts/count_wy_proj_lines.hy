
    (import wy.utils.fptk_local *)
    (require wy.utils.fptk_local *)

; define printing machinery ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn count_file_lines
        [ #^ str filename]
        (-> filename read_file (.count "\n")))

    (defn construct_lineN_string
        [ #^ int forced_filename_len
          #^ str filename]
        (return
            (sconcat (enlengthen forced_filename_len filename)
                    " | "
                    (str (count_file_lines filename)))))

    (defn print_group
        [ #^ str groupname
          #^ (of List str) filenames]
        (setv total (sum (lmap count_file_lines filenames ))
        );
        (print (sconcat groupname " (" (str total) "):"))
        (lprint
            (lmap (partial construct_lineN_string (max (map len filenames)))
                 filenames))
        (print ""))

; _____________________________________________________________________________/ }}}1
; user config ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv $DOCS
        [ "../docs/01_Overview.md"
          "../docs/02_Basic.md"
          "../docs/03_Condensed.md"
          "../docs/04_One_liners.md"
          "../docs/05_Symbols.md"
          "../docs/repl.md"
          "../docs/wy2hy.md"])

    (setv $BACKEND
        [ "../src/wy/Backend/Classes.hy"
          "../src/wy/Backend/Preparator.hy"
          "../src/wy/Backend/Parser.hy"
          "../src/wy/Backend/Expander.hy"
          "../src/wy/Backend/Deconstructor.hy"
          "../src/wy/Backend/Bracketer.hy"
          "../src/wy/Backend/Writer.hy"
          "../src/wy/Backend/Assembler.hy"])

    (setv $FRONTEND
        [ "../src/wy/Frontend/DebugHelpers.hy"
          "../src/wy/Frontend/ErrorHelpers.hy"
          "../src/wy/Frontend/ReplHelpers.hy"
          "../src/wy/Frontend/wy2hy.hy"
          "../src/repl_wy/magic.py"])

    (setv $TESTS
        [ "../tests/ALL_BE_tests.hy"
          "../tests/BE01_preparator.hy"
          "../tests/BE02_parser.hy"
          "../tests/BE03_expander.hy"
          "../tests/BE04_deconstructor.hy"
          "../tests/BE05_bracketer.hy"
          "../tests/BE06_writer.hy"
          "../tests/BE07_assembler.hy"
          "../tests/FE01_PrettyErrors.hy"
          "../tests/FE02_CLI.hy"
          "../tests/FE03_REPL.wy"])



; _____________________________________________________________________________/ }}}1

    (setv groups ["Docs" "Backend" "Frontend" "Tests"])
    (setv filenames [$DOCS $BACKEND $FRONTEND $TESTS])

    (lmap print_group
        groups
        filenames)

    (print "----------------------\nTotal:"
          (sum (lmap count_file_lines (flatten filenames ))))

          (print (str_join [] :sep "1"))
