
; Imports ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import sys) (sys.setrecursionlimit 3000) ; needed for pyparser, I saw it crash at 1300

    (import  wy.utils.fptk_local [validateF])
    (require wy.utils.fptk_local [->>])

    (import  wy.Backend.Classes  [WyCode HyCode])
    (import  wy.Backend.Preparator    [wycode_to_prepared_code])
    (import  wy.Backend.Parser        [prepared_code_to_ntlines])
    (import  wy.Backend.Expander      [expand_ntlines])
    (import  wy.Backend.Deconstructor [deconstruct_ntlines])
    (import  wy.Backend.Bracketer     [bracktify_ndlines])
    (import  wy.Backend.Writer        [blines_to_hcode])

; _____________________________________________________________________________/ }}}1

    (defn [validateF] #^ HyCode
        transpile_wy2hy
        [ #^ WyCode code
        ]
        "takes wy code as a string,
         produces hy code as a string,
         raises function call trace when errors encountered"
        (->> code
             wycode_to_prepared_code
             prepared_code_to_ntlines
             expand_ntlines
             deconstruct_ntlines        
             bracktify_ndlines
             blines_to_hcode))

