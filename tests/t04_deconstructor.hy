
    (import  _fptk_local *)
    (require _fptk_local *)

    (import wy.Classes *)
    (import wy.Preparator    [wycode_to_prepared_code])
    (import wy.Parser        [prepared_code_to_ntlines])
    (import wy.Expander      [expand_ntlines])   ; [NTLine ...] -> [NTLine ...]
    (import wy.Deconstructor [deconstruct_ntlines])   ; [NTLine ...] -> [NDLine ...]

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

