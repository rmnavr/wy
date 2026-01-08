
; Import/Export ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import typing [TypeVar Generic Union])
    (import pydantic [BaseModel])
    (import funcy [rcompose lmap partial])
    (require wy.utils.fptk_local.core.from_hyrule [of unless])

    (export :objects [ Maybe Just Nothing
                       justQ nothingQ
                       mapM bindM
                       unwrapM unwrapM_or
                     ])

; _____________________________________________________________________________/ }}}1

; Classes ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (setv J (TypeVar "J"))

    (defclass _Just [BaseModel (of Generic J)]
        #^ J value
        (defn __str__ [self] (+ "Just: " (str self.value)))
        (defn __repr__ [self] (self.__str__)))

    (defclass _Nothing [BaseModel]
        (defn __str__ [self] "Nothing")
        (defn __repr__ [self] (self.__str__)))

    (defclass Maybe [BaseModel (of Generic J)]
        #^ (of Union (of _Just J) _Nothing) container
        (defn __str__ [self] (+ "<M." (str self.container) ">"))
        (defn __repr__ [self] (self.__str__)))

    (defn Just [value] (Maybe :container (_Just :value value)))
    (setv Nothing (Maybe :container (_Nothing)))

; _____________________________________________________________________________/ }}}1

; - functions below also work correctly with [validateF]
; - (of Maybe J) — this too works with [validateF]
; utils: Typechecks ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn _nonM_error [x] (ValueError f"Value <{x}> must be of Maybe type"))

    (defn #^ bool justQ [#^ Maybe maybeM]
        (unless (isinstance maybeM Maybe) (raise (_nonM_error maybeM )))
        (isinstance maybeM.container _Just))

    (defn #^ bool nothingQ [#^ Maybe maybeM]
        (unless (isinstance maybeM Maybe) (raise (_nonM_error maybeM )))
        (isinstance maybeM.container _Nothing))

; _____________________________________________________________________________/ }}}1
; utils: Chaining ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ Maybe mapM [#^ Maybe maybeM #* fs]
        (if (nothingQ maybeM)
             (return Nothing)
             (return (Just ((rcompose #* fs) maybeM.container.value )))))

    (defn #^ Maybe bindM [#^ Maybe maybeM #* fs]
        (setv _fs (lmap (fn [it] (partial _bindM1 it)) fs))
        ( (rcompose #* _fs) maybeM))

    (defn #^ Maybe _bindM1 [f #^ Maybe maybeM]
        (if (nothingQ maybeM)
             (return Nothing)
             (do (setv new_maybe (f maybeM.container.value ))
                  (unless (isinstance new_maybe Maybe)
                           (raise (ValueError f"function {f} should return Maybe type (it tried to return value = {new_maybe})!")))
                  (return new_maybe))))

; _____________________________________________________________________________/ }}}1
; utils: routing ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn #^ J unwrapM [#^ (of Maybe J) maybeM]
        "throws error on Nothing"
        (if (justQ maybeM)
             (return maybeM.container.value)
             (raise (ValueError f"Can't unwrapM {maybeM}, since it's Nothing"))))

    (defn #^ J unwrapM_or
        [ #^ (of Maybe J) maybeM
          #^ J default]
        (if (justQ maybeM)
             (return maybeM.container.value)
             (return default)))

; _____________________________________________________________________________/ }}}1
