
; Import/Export ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import typing [TypeVar Generic Union])
    (import pydantic [BaseModel])
    (import funcy [rcompose lmap partial])
    (require wy.utils.fptk_local.core.from_hyrule [of unless])

    (export :objects [ Success Failure Result
                       successQ failureQ
                       mapR bindR
                       unwrapR unwrapR_or unwrapE unwrapE_or
                     ])

; _____________________________________________________________________________/ }}}1

; Classes ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv S (TypeVar "S"))
    (setv F (TypeVar "F"))

    (defclass _Failure [BaseModel (of Generic F)]
        #^ F value
        (defn __str__ [self] (+ "Failure: " (str self.value)))
        (defn __repr__ [self] (self.__str__)))

    (defclass _Success [BaseModel (of Generic S)]
        #^ S value
        (defn __str__ [self] (+ "Success: " (str self.value)))
        (defn __repr__ [self] (self.__str__)))


    (defclass Result [BaseModel (of Generic S F)]
        #^ (of Union (of _Success S) (of _Failure F)) result
        (defn [property] value [self] self.result.value)
        (defn __str__ [self] (+ "<R." (str self.result) ">"))
        (defn __repr__ [self] (self.__str__)))

    (defn Failure [value] (Result :result (_Failure :value value)))
    (defn Success [value] (Result :result (_Success :value value)))

; _____________________________________________________________________________/ }}}1

; - functions below also work correctly with [validateF]
; - (of Result S F) — this too works with [validateF]
; utils: Typechecks ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; dev note: rely on failureQ/successQ to check if resultM is of Result type

    (defn _nonR_error [x] (ValueError f"Value <{x}> must be of Result type"))

    (defn #^ bool failureQ [#^ Result resultM]
        (unless (isinstance resultM Result) (raise (_nonR_error resultM )))
        (isinstance resultM.result _Failure))

    (defn #^ bool successQ [#^ Result resultM]
        (unless (isinstance resultM Result) (raise (_nonR_error resultM )))
        (isinstance resultM.result _Success))

; _____________________________________________________________________________/ }}}1
; utils: Chaining ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ Result mapR [#^ Result resultM #* fs]
        (if (failureQ resultM)
             (return resultM)
             (return (Success ((rcompose #* fs) resultM.result.value )))))

    (defn #^ Result bindR [#^ Result resultM #* fs]
        (setv _fs (lmap (fn [it] (partial _bindR1 it)) fs))
        ( (rcompose #* _fs) resultM))

    (defn #^ Result _bindR1 [f #^ Result resultM]
        (if (failureQ resultM)
             (return resultM)
             (do (setv new_result (f resultM.result.value ))
                  (unless (isinstance new_result Result)
                           (raise (ValueError f"function {f} should return Result type (it tried to return value = {new_result})!")))
                  (return new_result))))

; _____________________________________________________________________________/ }}}1
; utils: Routing ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ S unwrapR [#^ (of Result S F) resultM]
        "throws error when on Failure track"
        (if (successQ resultM)
             (return resultM.value)
             (raise (ValueError f"Can't unwrapR {resultM}, since it's on Failure track"))))

    (defn #^ S unwrapR_or
        [ #^ (of Result S F) resultM
          #^ S default]
        (if (successQ resultM)
             (return resultM.value)
             (return default)))

    (defn #^ F unwrapE [#^ (of Result S F) resultM]
        "throws error when on Success track"
        (if (failureQ resultM)
             (return resultM.value)
             (raise (ValueError f"Can't unwrapE {resultM}, since it's on Success track"))))

    (defn #^ F unwrapE_or
        [ #^ (of Result S F) resultM
          #^ F default]
        (if (failureQ resultM)
             (return resultM.value)
             (return default)))

; _____________________________________________________________________________/ }}}1
