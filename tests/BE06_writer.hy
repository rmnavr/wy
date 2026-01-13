
    (import  wy.utils.fptk_local.core *)
    (require wy.utils.fptk_local.core *)

    (import wy.Backend.Classes *)
    (import wy.Backend.Preparator    [wycode_to_prepared_code])
    (import wy.Backend.Parser        [prepared_code_to_ntlines])
    (import wy.Backend.Expander      [expand_ntlines])      ; [NTLine ...] -> [NTLine ...]
    (import wy.Backend.Deconstructor [deconstruct_ntlines]) ; [NTLine ...] -> [NDLine ...]
    (import wy.Backend.Bracketer     [bracktify_ndlines])   ; [NDLine ...] -> [BLine ...]
    (import wy.Backend.Writer        [blines_to_hcode])     ; [BLine ...] -> HyCode

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



