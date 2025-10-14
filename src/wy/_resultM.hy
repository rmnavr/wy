
    (import wy._fptk_local *) (require wy._fptk_local *)

    ; Success/Failure — wrapper functions
    ; Result — class, needed for correct type annotation/validation (user usage)

    ; =======================================================

    (export :objects [ Success  Failure Result
                      successQ failureQ
                      mapR bindR unwrapR result_or
                    ])

; Classes ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv S (TypeVar "S"))
    (setv F (TypeVar "F"))

    (defclass _Failure [BaseModel (of Generic F)]
        #^ F value
        (defn __str__ [self] (sconcat "Failure: " (str self.value)))
        (defn __repr__ [self] (self.__str__)))

    (defclass _Success [BaseModel (of Generic S)]
        #^ S value
        (defn __str__ [self] (sconcat "Success: " (str self.value)))
        (defn __repr__ [self] (self.__str__)))


    (defclass Result [BaseModel (of Generic S F)]
        #^ (of Union (of _Success S) (of _Failure F)) result
        (defn __str__ [self] (sconcat "<R." (str self.result) ">"))
        (defn __repr__ [self] (self.__str__)))

    (defn Failure [value] (Result :result (_Failure :value value )))
    (defn Success [value] (Result :result (_Success :value value )))

; _____________________________________________________________________________/ }}}1
; Utils ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; - functions below also work correctly with [validateF]
    ; - (of Result S F) — this too works with [validateF]

    (defn unwrapR [#^ Result resultM]
        (unless (isinstance resultM Result) (raise (_nonR_error resultM )))
        (return resultM.result.value)); both _Success and _Failure have .value attribute

    (defn _nonR_error [x] (ValueError f"Value <{x}> must be of Result type"))

    (defn #^ bool failureQ [#^ Result resultM]
        (unless (isinstance resultM Result) (raise (_nonR_error resultM )))
        (isinstance resultM.result _Failure))

    (defn #^ bool successQ [#^ Result resultM]
        (unless (isinstance resultM Result) (raise (_nonR_error resultM )))
        (isinstance resultM.result _Success))

    (defn #^ Result mapR [#^ Result resultM #* fs]
        (unless (isinstance resultM Result) (raise (_nonR_error resultM )))
        (if (failureQ resultM)
             (return resultM)
             (return (Success ((compose #* fs) resultM.result.value )))))

    ;   defn [validateF] bindR [#^ Result resultM #* fs]
    ;       setv fs_ : lmapm (pflip _bindR1 it) fs
    ;       rcompose #* fs_ <$ \resultM

    (defn #^ Result _bindR1 [#^ Result resultM f]
        (unless (isinstance resultM Result) (raise (_nonR_error resultM )))
        (if (failureQ resultM)
             (return resultM)
             (do (setv new_result (f resultM.result.value ))
                  (unless (isinstance new_result Result)
                           (raise (ValueError f"function {f} should return Result type (it tried to return value = {new_result})!")))
                  (return new_result))))

    (defn #^ Result bindR [#^ Result resultM #* fs]
        (setv _fs (lmapm (pflip _bindR1 it) fs))
        ( (rcompose #* _fs) resultM))

    (defn result_or [#^ Result resultM [another None]]
        (unless (isinstance resultM Result) (raise (_nonR_error resultM )))
        (if (successQ resultM)
             (return resultM.result.value)
             (return another)))

; _____________________________________________________________________________/ }}}1

