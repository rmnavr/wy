
    (import fptk *)
    (import os)
    (import _fptk_local *)
    (require _fptk_local *)

    (setv $DESIRED_EXTENSION ".hy")

    (defn file_lines
         [ #^ str filename]
         (-> filename
            read_file
            (.count "\n")))

    (defn #^ bool
        of_desired_extensionQ
        [ #^ str extension
          #^ str filename]
        (when (fnot fileQ filename) (return False))
        (setv [root ext] (os.path.splitext filename))
        (return (eq ext extension)))

    (setv files (lfilter (partial of_desired_extensionQ $DESIRED_EXTENSION) (os.listdir ".")))
    (setv lengths (lmap file_lines files))

    (lmap print files (repeat "|") lengths)
    (print "Total:" (sum lengths))

