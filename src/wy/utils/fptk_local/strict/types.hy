
    (import typing [Union])
    (require wy.utils.fptk_local.core.from_hyrule [of])

    (export :objects [ BaseModel
                       StrictInt StrictStr StrictFloat StrictNumber
                       validate_call validateF
                     ])

; [GROUP] Typing: Pydantic ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import pydantic [BaseModel])       #_ "pydantic base class"
    (import pydantic [StrictInt])       #_ "will be still of int type, but will perform strict typecheck when variable is created"
    (import pydantic [StrictStr])       #_ "will be still of str type, but will perform strict typecheck when variable is created"
    (import pydantic [StrictFloat])     #_ "will be still of float type, but will perform strict typecheck when variable is created" ;;

    #_ "Union of StrictInt and StrictFloat"
    (setv StrictNumber (of Union #(StrictInt StrictFloat))) ;;

    (import pydantic [validate_call])   #_ "decorator for type-checking func args" ;;

    #_ "same as validate_call but with option validate_return=True set (thus validating args and return type)"
    (setv validateF (validate_call :validate_return True))

; _____________________________________________________________________________/ }}}1

