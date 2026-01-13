
    (import  wy.utils.fptk_local.core *)
    (require wy.utils.fptk_local.core *)

    (import wy.Backend.Classes *)
    (import wy.Backend.Preparator [wycode_to_prepared_code :as w2p])

    (assertm eq (w2p "") "")
    (assertm eq (w2p "\n") "☇¦")
    (assertm eq (w2p "\n \n") "☇¦\n☇¦")
    (assertm eq (w2p "  : :  :  smth $ riba <$") "☇¦■■:■:■■:■■smth $ riba <$")
    (assertm eq (w2p "  L C \\ \\ pups : riba") "☇¦■■L■C■\\■\\ pups : riba")
    (assertm eq (w2p "  LL CC \\ riba") "☇¦■■LL CC \\ riba")
    (assertm eq (w2p "  :x \\ m") "☇¦■■:x \\ m")


