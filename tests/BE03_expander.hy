
    (import  wy.utils.fptk_local *)
    (require wy.utils.fptk_local *)

; [F] testing machinery setup ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import wy.Backend.Classes *)

    (import wy.Backend.Preparator [wycode_to_prepared_code  :as w2pc])
    (import wy.Backend.Parser     [prepared_code_to_ntlines :as pc2ntls])

    ; for omarkers2sm_markers + syntax checks:

    (import wy.Backend.Expander   [classify_omarkers :as com])   ; NTLine -> NTLine
    (import wy.Backend.Expander   [check_syntax      :as chstx]) ; NTLine -> None

    (defn #^ (of List NTLine) wy2coms [wycode] (->> wycode w2pc pc2ntls (lmap com)))
    (defn #^ (of List NTLine) chcm_wy [wycode] (->> wycode wy2coms (lmap chstx)))

    ; for expansion:

    (import wy.Backend.Expander [expand_smarkers :as esm])   ; NTLine -> [NTLine ...]
    (import wy.Backend.Expander [expand_rmarkers :as erm])   ; NTLine -> [NTLine ...]
    (import wy.Backend.Expander [expand_amarkers :as eam])   ; NTLine -> [NTLine ...]
    (import wy.Backend.Expander [expand_jmarkers :as ejm])   ; NTLine -> [NTLine ...]

    (defn #^ (of List NTLine) wy2expS
        [wycode]
        (setv coms (wy2coms wycode))
        (lmap chstx coms) ; only checks
        (lmapcat esm coms))

    (defn #^ (of List NTLine) wy2expSR   [wycode] (->> wycode wy2expS   (lmapcat erm)))
    (defn #^ (of List NTLine) wy2expSRA  [wycode] (->> wycode wy2expSR  (lmapcat eam)))
    (defn #^ (of List NTLine) wy2expSRAJ [wycode] (->> wycode wy2expSRA (lmapcat ejm)))

    ; for assembly:

    (import wy.Backend.Expander [expand_ntlines  :as ent])   ; [NTLine ...] -> [NTLine ...]

    (defn #^ (of List NTLine) wy2entls [wycode] (->> wycode w2pc pc2ntls ent))

; _____________________________________________________________________________/ }}}1

;«...» prefix is : WyCode -> PreparedCode -> Parsed NTLines -> 
; ... -> o2sm (markers to s/m-markers) ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn wy2tkinds
        [wycode]
        (l> (wy2coms wycode) 0 .tokens (Each) .tkind (collect)))

    (assertm eq (wy2tkinds ": :")
                [ TKind.SMarker TKind.Indent TKind.SMarker])

    (assertm eq (wy2tkinds ": $ : : \\ : <$ \\ : , : \\ : <$ :")
                [ TKind.SMarker TKind.Indent TKind.AMarker TKind.SMarker TKind.SMarker
                  TKind.CMarker TKind.MMarker TKind.RMarker TKind.CMarker TKind.MMarker
                  TKind.JMarker TKind.SMarker TKind.CMarker TKind.MMarker
                  TKind.RMarker TKind.SMarker])

    (assertm eq (wy2tkinds " x $ : \\ : z")
                [ TKind.Indent TKind.RAOpener TKind.AMarker TKind.SMarker
                  TKind.CMarker TKind.MMarker TKind.RAOpener])

; _____________________________________________________________________________/ }}}1
; ... -> o2sm -> ch_stx (check syntax) ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; cmarker checks:
    (chcm_wy "\\ x")
    (chcm_wy "\\ x : y $ \\ z <$ \\ m , \\ t $ : \\ x")
    (assertm gives_error_typeQ (chcm_wy "\\ \\")            WyExpanderError)
    (assertm gives_error_typeQ (chcm_wy ": \\ \\ x")        WyExpanderError)
    (assertm gives_error_typeQ (chcm_wy "\\ ; comment")     WyExpanderError)
    (assertm gives_error_typeQ (chcm_wy "x \\ ; comment")   WyExpanderError)
    (assertm gives_error_typeQ (chcm_wy "x \\ $ ; comment") WyExpanderError)
    (assertm gives_error_typeQ (chcm_wy "x \\ y ; comment") WyExpanderError)

    ; amarker checks:
    (chcm_wy "x $ y")
    (assertm gives_error_typeQ (chcm_wy " $ ; comment")     WyExpanderError)
    (assertm gives_error_typeQ (chcm_wy "x $")              WyExpanderError)
    (assertm gives_error_typeQ (chcm_wy "$ x")              WyExpanderError)
    (assertm gives_error_typeQ (chcm_wy ": $ $ y")          WyExpanderError)
    (assertm gives_error_typeQ (chcm_wy "$ <$")             WyExpanderError)
    (assertm gives_error_typeQ (chcm_wy "$ ,")              WyExpanderError)

    ; rmarker checks:
    (chcm_wy "x : <$")
    (chcm_wy "x <$")
    (chcm_wy "x <$ <$")
    (assertm gives_error_typeQ (chcm_wy " <$ ; comment")    WyExpanderError)
    (assertm gives_error_typeQ (chcm_wy "<$ x")             WyExpanderError)
    (assertm gives_error_typeQ (chcm_wy "<$ $")             WyExpanderError)
    (assertm gives_error_typeQ (chcm_wy "<$ ,")             WyExpanderError)

    ; jmarker checks:
    (chcm_wy "x , :")
    (assertm gives_error_typeQ (chcm_wy " , ; comment")     WyExpanderError)
    (assertm gives_error_typeQ (chcm_wy "x ,")              WyExpanderError)
    (assertm gives_error_typeQ (chcm_wy ", x")              WyExpanderError)
    (assertm gives_error_typeQ (chcm_wy "x , , y")          WyExpanderError)
    (assertm gives_error_typeQ (chcm_wy ": , , :")          WyExpanderError)
    (assertm gives_error_typeQ (chcm_wy "$ <$")             WyExpanderError)
    (assertm gives_error_typeQ (chcm_wy "$ ,")              WyExpanderError)

; _____________________________________________________________________________/ }}}1

; ... o2sm -> ch_stx -> expS (expand S-markers) ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (assertm eq (len (wy2expS "\\:")) 1)
    (assertm eq (len (wy2expS ": \"\n\"x")) 2)
    (assertm eq (len (wy2expS " : L x")) 3)

    (setv openers (str_join [  " :"   "L"    "C"   "#:"   "#C"
                               "':"  "'L"   "'C"  "'#:"  "'#C"
                               "`:"  "`L"   "`C"  "`#:"  "`#C"
                               "~:"  "~L"   "~C"  "~#:"  "~#C"
                              "~@:" "~@L"  "~@C" "~@#:" "~@#C" ]
                             :sep " "))

    (assertm eq (len (wy2expS openers)) 25)

; _____________________________________________________________________________/ }}}1
; ... o2sm -> ch_stx -> expSR ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (assertm eq (len (wy2expSR "x <$ <$")) 3)
    (assertm eq (len (wy2expSR "x <$")) 2)

    (assertm eq (len (wy2expSR "x <$ y")) 3) ; because ": x\n  y" is then R_expanded also
    (assertm eq (len (wy2expSR "x <$ y <$ z")) 5) 
    (assertm eq (len (wy2expSR ": x <$ y <$ z")) 6)
    (assertm eq (len (wy2expSR "L Monad x <$ 3 <$ 4\n  5")) 7)

; _____________________________________________________________________________/ }}}1
; ... o2sm -> ch_stx -> expSRA ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (assertm eq (len (wy2expSRA "x $ y")) 2) 
    (assertm eq (len (wy2expSRA "x $ y $ z")) 3) 
    (assertm eq (len (wy2expSRA ": x $ y $ z")) 4)
    (assertm eq (len (wy2expSRA "L Monad x $ 3 $ 4 5")) 4)
    (assertm eq (len (wy2expSRA ": x <$ \\ y $ \\ z")) 5) 

; _____________________________________________________________________________/ }}}1
; ... o2sm -> ch_stx -> expSRAJ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (assertm eq (len (wy2expSRAJ "x , y")) 2) 
    (assertm eq (len (wy2expSRAJ "x , y , z")) 3) 
    (assertm eq (len (wy2expSRAJ ": x , y , z")) 4)
    (assertm eq (len (wy2expSRAJ "L Monad x , 3 , 4 5")) 4)
    (assertm eq (len (wy2expSRAJ ": x <$ \\ y , \\ z")) 5) 

; _____________________________________________________________________________/ }}}1

; wycode -> expanded ntlines ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (assertm eq (len (wy2entls "")) 0) 
    (assertm eq (len (wy2entls "\n\n")) 2) 

    (assertm eq (len (wy2entls "x , y $ z")) 3) 
    (assertm eq (len (wy2entls "x , y $ z")) 3) 

    (assertm gives_error_typeQ (wy2entls "\\ \\") WyExpanderError)

; _____________________________________________________________________________/ }}}1

