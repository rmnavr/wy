
    (import  wy.utils.fptk_local.core *)
    (require wy.utils.fptk_local.core *)

    (import wy.Backend.Classes *)
    (import wy.Backend.Preparator    [wycode_to_prepared_code])
    (import wy.Backend.Parser        [prepared_code_to_ntlines])
    (import wy.Backend.Expander      [expand_ntlines])   ; [NTLine ...] -> [NTLine ...]
    (import wy.Backend.Deconstructor [deconstruct_ntlines])   ; [NTLine ...] -> [NDLine ...]

    (defn #^ (of List NDLine)
         wy2ndlines
         [wycode]
         (->> wycode
              wycode_to_prepared_code
              prepared_code_to_ntlines
              expand_ntlines
              deconstruct_ntlines))

    (assertm eq (wy2ndlines "") [])
    (assertm eq (len (wy2ndlines "1")) 1)
    (assertm eq (len (wy2ndlines ": x <$ 7")) 4)

