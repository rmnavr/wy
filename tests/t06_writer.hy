
    (import  _fptk_local *)
    (require _fptk_local *)

    (import wy.Classes *)
    (import wy.Preparator    [wycode_to_prepared_code])
    (import wy.Parser        [prepared_code_to_ntlines])
    (import wy.Expander      [expand_ntlines])      ; [NTLine ...] -> [NTLine ...]
    (import wy.Deconstructor [deconstruct_ntlines]) ; [NTLine ...] -> [NDLine ...]
    (import wy.Bracketer     [bracktify_ndlines])   ; [NDLine ...] -> [BLine ...]
    (import wy.Writer        [blines_to_hcode])     ; [BLine ...] -> HyCode

    (defn #^ (of List NDLine)
         wy2hy_
         [wycode]
         (->> wycode
              wycode_to_prepared_code
              prepared_code_to_ntlines
              expand_ntlines
              deconstruct_ntlines
              bracktify_ndlines
              blines_to_hcode))

    (assertm eq (wy2hy_ "") "")
    (assertm eq (wy2hy_ "1") "1")



