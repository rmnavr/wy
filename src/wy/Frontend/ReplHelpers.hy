
    (require wy.utils.fptk_local.loader [load_fptk])
    (load_fptk "core")
    (import  wy.utils.coloring *)

    (import  wy.Backend.Classes *)

    (setv $FRAME_OP       "/=== TRANSPILED_HY_CODE ===")
    (setv $FRAME_CL    "\n\\=== TRANSPILED_HY_CODE ===")

    (defn frame_hycode
        [ #^ HyCode code
          #^ bool   [colored False]
        ]
        "this function is intended to be used in repl"
        (setv pre  (if colored (clrz_lg $FRAME_OP) $FRAME_OP))
        (setv bar  (if colored (clrz_lg "\n|") "\n|"))
        (setv post (if colored (clrz_lg $FRAME_CL) $FRAME_CL))
        (setv lines (lconcat [pre] (lmapm (sconcat bar it) (code.split "\n")) [post]))
        (str_join lines))


