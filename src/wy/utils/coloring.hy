
    (import termcolor [colored :as clr])

    (setv clrz_lg (fn [text] (clr text "light_green")))
    (setv clrz_ow (fn [text] (clr text None "on_white")))
    (setv clrz_u  (fn [text] (clr text None None ["underline"])))
    (setv clrz_g  (fn [text] (clr text "green")))
    (setv clrz_b  (fn [text] (clr text "blue")))
    (setv clrz_c  (fn [text] (clr text "cyan")))
    (setv clrz_m  (fn [text] (clr text "magenta")))
    (setv clrz_r  (fn [text] (clr text "red")))

    ; INFO:

    ; "black" "red" "green" "yellow" "blue"
    ; "magenta" "cyan" "white" "light_grey"
    ; "dark_grey" "light_red" "light_green"
    ; "light_yellow" "light_blue" "light_magenta" "light_cyan"

    ; "on_black" "on_red" "on_green" "on_yellow"
    ; "on_blue" "on_magenta" "on_cyan" "on_white"
    ; "on_light_grey" "on_dark_grey" "on_light_red" "on_light_green"
    ; "on_light_yellow" "on_light_blue" "on_light_magenta" "on_light_cyan"

    ; "bold" "dark" "underline" "blink" "reverse" "concealed" "strike"

