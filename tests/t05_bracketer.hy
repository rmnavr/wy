
    (import  _fptk_local *)
    (require _fptk_local *)

    (import wy.Classes *)
    (import wy.Preparator    [wycode_to_prepared_code])
    (import wy.Parser        [prepared_code_to_ntlines])
    (import wy.Expander      [expand_ntlines])      ; [NTLine ...] -> [NTLine ...]
    (import wy.Deconstructor [deconstruct_ntlines]) ; [NTLine ...] -> [NDLine ...]
    (import wy.Bracketer     [bracktify_ndlines])   ; [NDLine ...] -> [BLine ...]

    (defn #^ (of List NDLine)
         wy2blines
         [wycode]
         (->> wycode
              wycode_to_prepared_code
              prepared_code_to_ntlines
              expand_ntlines
              deconstruct_ntlines
              bracktify_ndlines))

    (assertm eq (len (wy2blines "")) 1) ; always has +1 extra line
    (assertm eq (len (wy2blines "1")) 2)
    (assertm eq (len (wy2blines ": x <$ 7")) 5)


