
; Import/Export ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import typing [Any Union])
    (import funcy [rcompose lmap partial])
    (import dataclasses [dataclass])
    (require wy.utils.fptk_local.core.from_hyrule [of unless])

    (export :objects [ Success Failure Result
                       successQ failureQ
                       mapR bindR
                       unwrapR unwrapR_or unwrapE unwrapE_or
                     ])

; _____________________________________________________________________________/ }}}1

; Classes ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defclass [dataclass] _Failure []
        #^ Any value
        (defn __str__ [self] (+ "Failure: " (str self.value)))
        (defn __repr__ [self] (self.__str__)))

    (defclass [dataclass] _Success []
        #^ Any value
        (defn __str__ [self] (+ "Success: " (str self.value)))
        (defn __repr__ [self] (self.__str__)))


    (defclass [dataclass] Result []
        #^ (of Union _Success _Failure) result
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

    (defn unwrapR [#^ Result resultM]
        "throws error when on Failure track"
        (if (successQ resultM)
             (return resultM.value)
             (raise (ValueError f"Can't unwrapR {resultM}, since it's on Failure track"))))

    (defn unwrapR_or
        [ #^ Result resultM
          default]
        (if (successQ resultM)
             (return resultM.value)
             (return default)))

    (defn unwrapE [#^ Result resultM]
        "throws error when on Success track"
        (if (failureQ resultM)
             (return resultM.value)
             (raise (ValueError f"Can't unwrapE {resultM}, since it's on Success track"))))

    (defn unwrapE_or
        [ #^ Result resultM
          default]
        (if (failureQ resultM)
             (return resultM.value)
             (return default)))

; _____________________________________________________________________________/ }}}1
