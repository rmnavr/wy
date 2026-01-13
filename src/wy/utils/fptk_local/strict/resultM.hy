
; non-strict as compared to strict:
; 1) do not import pydantic
; 2) Classes definition
; -- utils functions are totally the same

; Import/Export ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import pydantic [BaseModel])

    (import typing [TypeVar Generic Union])
    (import funcy [rcompose lmap partial])
    (require wy.utils.fptk_local.core.from_hyrule [of unless])

    (export :objects [ Success Failure Result
                       successQ failureQ
                       mapR bindR
                       unwrapR unwrapS unwrapS_or unwrapE unwrapE_or
                     ])

; _____________________________________________________________________________/ }}}1

; Classes ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv S (TypeVar "S"))
    (setv F (TypeVar "F"))

    (defclass _Failure [BaseModel (of Generic F)]
        #^ F value
        ;
        (defn __str__ [self] (+ "Failure: " (str self.value)))
        (defn __repr__ [self] (self.__str__)))

    (defclass _Success [BaseModel (of Generic S)]
        #^ S value
        ;
        (defn __str__ [self] (+ "Success: " (str self.value)))
        (defn __repr__ [self] (self.__str__)))

    (defclass Result [BaseModel (of Generic S F)]
        #^ (of Union (of _Success S) (of _Failure F)) container
        (defn [property] value [self] self.container.value)
        ;
        (defn __str__ [self] (+ "<R." (str self.container) ">"))
        (defn __repr__ [self] (self.__str__)))

    (defn Failure [value] (Result :container (_Failure :value value)))
    (defn Success [value] (Result :container (_Success :value value)))

; _____________________________________________________________________________/ }}}1

; utils: failureQ/successQ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ bool failureQ [#^ Result resultM]
        (unless (isinstance resultM Result)
            (raise (TypeError f"Object <{resultM}> is not of Result type.\nFunction 'failureQ' is not applicable.")))
        (isinstance resultM.container _Failure))

    (defn #^ bool successQ [#^ Result resultM]
        (unless (isinstance resultM Result)
            (raise (TypeError f"Object <{resultM}> is not of Result type.\nFunction 'successQ' is not applicable.")))
        (isinstance resultM.container _Success))

; _____________________________________________________________________________/ }}}1
; utils: mapR/bindR ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ Result mapR [#^ Result resultM #* fs]
        (unless (isinstance resultM Result)
             (raise (TypeError f"Object <{resultM}> is not of Result type.\nFunction 'mapR' is not applicable.")))
        (if (isinstance resultM.container _Failure)
             (return resultM)
             (return (Success ((rcompose #* fs) resultM.container.value )))))

    (defn #^ Result bindR [#^ Result resultM #* fs]
        (unless (isinstance resultM Result)
             (raise (TypeError f"Object <{resultM}> is not of Result type.\nFunction 'bindR' is not applicable.")))
        (setv _fs (lmap (fn [it] (partial _bindR1 it)) fs))
        ( (rcompose #* _fs) resultM))

    (defn #^ Result _bindR1 [f #^ Result resultM]
        ; we don't check if resultM is of Result type here, because bindR guarantees it
        (when (isinstance resultM.container _Failure)
               (return resultM))
        (do (setv new_result (f resultM.container.value ))
             (unless (isinstance new_result Result)
                      (raise (TypeError f"Trying to bindR function {f} that returns {new_result}. Binding won't work unless return type is Result.")))
             (return new_result)))

; _____________________________________________________________________________/ }}}1
; utils: unwrapping ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv _unwrappingError
        (fn [resultM]
            (TypeError f"Object <{resultM}> is not of Result type.\nUnwrapping is not applicable.")))

    (defn #^ S unwrapR [#^ (of Result S F) resultM]
        (unless (isinstance resultM Result)
             (raise (_unwrappingError resultM)))
        (return resultM.value))

    (defn #^ S unwrapS [#^ (of Result S F) resultM]
        "throws error when on Failure track"
        (unless (isinstance resultM Result)
             (raise (_unwrappingError resultM)))
        (if (isinstance resultM.container _Success)
             (return resultM.value)
             (raise (TypeError f"Can't unwrapS {resultM}, since it's on Failure track"))))

    (defn #^ S unwrapS_or
        [ #^ (of Result S F) resultM
          #^ S default]
        (unless (isinstance resultM Result)
             (raise (_unwrappingError resultM)))
        (if (isinstance resultM.container _Success)
             (return resultM.value)
             (return default)))

    (defn #^ F unwrapE [#^ (of Result S F) resultM]
        "throws error when on Success track"
        (unless (isinstance resultM Result)
             (raise (_unwrappingError resultM)))
        (if (isinstance resultM.container _Failure)
             (return resultM.value)
             (raise (TypeError f"Can't unwrapE {resultM}, since it's on Success track"))))

    (defn #^ F unwrapE_or
        [ #^ (of Result S F) resultM
          #^ F default]
        (unless (isinstance resultM Result)
             (raise (_unwrappingError resultM)))
        (if (isinstance resultM.container _Failure)
             (return resultM.value)
             (return default)))

; _____________________________________________________________________________/ }}}1
