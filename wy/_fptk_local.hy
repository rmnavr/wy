
; This is local version of github.com/rmnavr/fptk lib.
; It's purpose is to have stable fptk inside other projects until fptk reaches stable version.
; This file was generated from local git version: 0.2.4dev9

; functions and modules ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

; Intro ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (require hyrule [comment])
    ;; DOC SYNTAX: map(f, *, y, *xs) = (map f * y #* xs)

; ________________________________________________________________________/ }}}2

; [GROUP] Import Full Modules ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (import sys)                #_ "py base module"
    (import os)                 #_ "py base module"

    (sys.stdout.reconfigure :encoding "utf-8")

    (import math)               #_ "py base module"
    (import operator)           #_ "py base module"
    (import random)             #_ "py base module"
    (import re)                 #_ "py base module"
    (import itertools)          #_ "py base module"
    (import functools)          #_ "py base module"
    (import pprint [pprint])    

    (import hyrule)             #_ "hy base module"
    (import funcy)              #_ "3rd party module (FP related)"
    (import lenses [lens])      #_ "3rd party module (for working with immutable structures)"

; ________________________________________________________________________/ }}}2
; [GROUP] Typing ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (require hyrule [of])  #_ "| (of List int) -> List[int]"

    (import dataclasses [dataclass])
    (import enum        [Enum])
    (import typing      [List])
    (import typing      [Tuple])
    (import typing      [TypedDict])
    (import typing      [Dict])
    (import typing      [Union])
    (import typing      [Generator])
    (import typing      [Any])
    (import typing      [Optional])
    (import typing      [Callable])
    (import typing      [Literal])
    (import typing      [Type])
    (import typing      [TypeVar])

    ;; type checks:

    (import funcy [isnone  :as noneQ])
    (import funcy [notnone :as notnoneQ]) ;;

    #_ "(oftypeQ tp x) -> (= (type x) tp) |"
    (defn oftypeQ [tp x] "checks literally if type(x) == tp" (= (type x) tp))

    #_ "intQ(x) | checks literally if type(x) == int, will also work with StrictInt from pydantic"
    (defn intQ [x]
        "checks literally if type(x) == int"
        (= (type x) int))    

    #_ "floatQ(x) | checks literally if type(x) == float, will also work with StrictFloat from pydantic"
    (defn floatQ [x]
        "checks literally if type(x) == float"
        (= (type x) float))

    #_ "numberQ(x) | checks for intQ or floatQ, will also work with StrictInt/StrictFloat from pydantic"
    (defn numberQ [x]
        "checks literally if type(x) == int or type(x) == float"
        (= (type x) float))

    #_ "strQ(x) | checks literally if type(x) == str, will also work with StrictStr from pydantic"
    (defn strQ [x]
        "checks literally if type(x) == int or type(x) == float"
        (= (type x) float))

    #_ "dictQ(x) | checks literally if type(x) == dict"
    (defn dictQ [x]
        "checks literally if type(x) == dict"
        (= (type x) dict))

    (import funcy [is_list  :as listQ ])    #_ "listQ(value)     | checks if value is list"
    (import funcy [is_tuple :as tupleQ])    #_ "tupleQ(value)    | checks if value is tuple"
    (import funcy [is_set   :as setQ])      #_ "setQ(value)      | checks if value is set"
    (import funcy [is_iter  :as iteratorQ]) #_ "iteratorQ(value) | checks if value is iterator"
    (import funcy [iterable :as iterableQ]) #_ "iterableQ(value) | checks if value is iterable"

; ________________________________________________________________________/ }}}2
; [GROUP] Strict Typing ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (import pydantic    [BaseModel])
    (import pydantic    [StrictInt])       #_ "will be still of int type, but will perform strict typecheck when variable is created"
    (import pydantic    [StrictStr])       #_ "will be still of str type, but will perform strict typecheck when variable is created"
    (import pydantic    [StrictFloat])     #_ "will be still of float type, but will perform strict typecheck when variable is created" ;;

    #_ "Union of StrictInt and StrictFloat"
    (setv StrictNumber (of Union #(StrictInt StrictFloat))) ;;

    (import pydantic    [validate_call])   #_ "decorator for type-checking func args" ;;

    #_ "same as validate_call but with option validate_return=True set (thus validating args and return type)"
    (setv validateF (validate_call :validate_return True))

; ________________________________________________________________________/ }}}2
; [GROUP] Buffed getters ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    ;; dub basics:

        (comment "hy     | macro | .     | (. xs [n1] [n2] ...) -> xs[n1][n2]... | throws error when not found")
        (comment "hy     | macro | get   | (get xs n #* keys) -> xs[n][key1]... | throws error when not found")
        (import funcy [nth])        #_ "nth(n, seq) -> Optional elem | 0-based index; works also with dicts"
        (comment "py     | base  | slice | (slice start end step) | ")
        (comment "hy     | macro | cut   | (cut xs start end step) -> (get xs (slice start end step)) -> List | gives empty list when none found")

        (import  hyrule [assoc])  #_ "(assoc xs k1 v1 k2 v2 ...) -> (setv (get xs k1) v1 (get xs k2) v2) -> None | also possible: (assoc xs :x 1)"
        (require hyrule [ncut])   

    ;; one elem getters:

        (import funcy [first])      #_ "first(seq) -> Optional elem |"
        (import funcy [second])     #_ "second(seq) -> Optional elem |" ;;

        #_ "third(seq) -> Optional elem |"
        (defn third [seq] (if (<= (len seq) 2) (return None) (return (get seq 2))))

        #_ "fourth(seq) -> Optional elem |"
        (defn fourth [seq] (if (<= (len seq) 3) (return None) (return (get seq 3))))

        #_ "beforelast(seq) -> Optional elem |"
        (defn beforelast [seq] (if (<= (len seq) 1) (return None) (return (get seq -2))))

        (import funcy [last])       #_ "last(seq) -> Optional elem |" 

    ;; list getters:

        #_ "rest(seq) -> List | drops 1st elem of list"
        (defn rest [seq] "drops 1st elem of list" (cut seq 1 None))

        #_ "butlast(seq) -> List | drops last elem of list"
        (defn butlast [seq] "drops last elem of list" (cut seq None -1))

        #_ "drop(n, seq) -> List | drops n>=0 elems from start of the list; when n<0, drops from end of the list"
        (defn drop [n seq]
            "drops n>=0 elems from start of seq; when n<0, drops from end of the seq"
            (if (>= n 0) (cut seq n None) (cut seq None n)))

        #_ "take(n, seq) -> List | takes n elems from start; when n<0, takes from end of the list"
        (defn take [n seq]
            "takes n>=0 elems from start of seq; when n<0, takes from end of the seq"
            (if (>= n 0) (cut seq None n) (cut seq (+ (len seq) n) None)))

        #_ "pick(ns, seq) -> List | throws error if some of ns doesn't exist; ns can be list of ints or dict keys"
        (defn pick [ns seq]
            " pics elems ns from seq,
              throws error if some of ns doesn't exist,
              ns can be list of dicts keys
            "
            (lfor &n ns (get seq &n)))

        (import  funcy  [pluck])        #_ " pluck(key, mappings) -> generator | gets same key from every mapping, mappings can be list of lists, list of dicts, etc."
        (import  funcy  [lpluck])       #_ "lpluck(key, mappings) -> list | "
        (import  funcy  [pluck_attr])   #_ " pluck_attr(attr, objects) -> generator | " ;;
        (import  funcy  [lpluck_attr])  #_ "lpluck_attr(attr, objects) -> list | " ;;

; ________________________________________________________________________/ }}}2
; [GROUP] index-1-based getters ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (import hyrule [thru :as range_])      #_ "range_(start, end, step) -> List | same as range, but with 1-based index"

    #_ "get_(seq, *ns) -> elem | same as get, but with 1-based index (will throw error for n=0)"
    (defn get_ [seq #* ns]
        " same as hy get macro, but with 1-based index,
          can also work with dict keys,
          will throw error for n=0,
          will throw error if elem not found (just like hy get macro)
        "
        (setv _ns_plus1 
            (lfor &n ns
                (do (when (= &n 0) (raise (IndexError "n=0 can't be used with 1-based getter")))
                    (if (and (intQ &n) (>= &n 1))
                        (dec &n)
                        &n)))) ;; this line covers both &n<0 and &n=dict_key        
        (return (get seq #* _ns_plus1)))

    #_ "nth_(n, seq) -> Optional elem | same as nth, but with 1-based index (will throw error for n=0)"
    (defn nth_ [n seq] 
        " same as nth, but with 1-based index,
          will throw error for n=0,
          will return None if elem not found (just like nth)
        "
        (when (dictQ seq) (return (nth n seq)))
        (when (=  n 0) (raise (IndexError "n=0 can't be used with 1-based getter")))
        (when (>= n 1) (return (nth (dec n) seq)))
        (return (nth n seq))) ;; this line covers both n<0 and n=dict_key

    #_ "slice_(start, end, step) | similar to slice, but with 1-based index (also it doesn't understand None and 0 for start and end arguments)"
    (defn slice_
        [ start
          end
          [step None]
        ]
        " similar to py slice, but:
          - has 1-based index
          - won't take None for start and end arguments
          - won't take 0 for start and end
        "
        (cond (>= start 1) (setv _start (dec start))
              (<  start 0) (setv _start start)
              (=  start 0) (raise (IndexError "start=0 can't be used with 1-based getter"))
              True         (raise (IndexError "start in 1-based getter is probably not an integer")))
        ;;
        (cond (=  end -1) (setv _end None)
              (>= end  1) (setv _end end)
              (<  end -1) (setv _end (inc end))
              (=  end  0) (raise (IndexError "end=0 can't be used with 1-based getter"))
              True        (raise (IndexError "end in 1-based getter is probably not an integer")))
        (return (slice _start _end step)))

    #_ "cut_(seq, start, end, step) -> List | same as cut, but with 1-based index (it doesn't understand None and 0 for start and end arguments)"
    (defn cut_ [seq start end [step None]]
        " same as hy cut macro, but with 1-based index,
          - won't take None or 0 for start and end arguments
        "
        (get seq (slice_ start end step)))

; ________________________________________________________________________/ }}}2

; [GROUP] Control flow ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (comment "hy | base | if   | (if check true false)          | ")
    (comment "hy | base | cond | (cond check1 do1 ... true doT) | ")

    (require hyrule [case])
    (require hyrule [branch])
    (require hyrule [unless])
    (require hyrule [lif])

; ________________________________________________________________________/ }}}2

; [GROUP] FP: composition ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (import hyrule [constantly])    #_ "(setv answer (constantly 42)) (answer 1 :x 2) -> 42"
    (import funcy  [identity])      #_ "identity(30) -> 30"

    (require hyrule [as->])
    (require hyrule [->])
    (require hyrule [->>])
    (require hyrule [doto])

    (import funcy   [curry])
    (import funcy   [autocurry])
    (import funcy   [partial])
    (import funcy   [rpartial])
    (import funcy   [compose])  
    (import funcy   [rcompose]) 

    (import funcy   [ljuxt]) #_ "ljuxt(*fs) = [f1, f2, ...] applicator |" ;;

    #_ "flip(f, a, b) = f(b, a) | example: (flip lmap [1 2 3] sqrt)"
    (defn flip [f a b] "flip(f, a, b) = f(b, a)" (f b a))

    #_ "pflip(f, a)| partial applicator with flipped args, works like: pflip(f, a)(b) = f(b, a), example: (lmap (pflip div 0.1) (thru 1 3))"
    (defn pflip
        [f a]
        " flips arguments and partially applies,
          example: pflip(f, a)(b) = f(b, a)
        "
        (fn [%x] (f %x a)))

; ________________________________________________________________________/ }}}2
; [GROUP] FP: threading ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (comment "py | base | map | map(func, *iterables) -> map object |")
    (import funcy     [lmap])       #_ "lmap(f, *seqs) -> List |"
    (import itertools [starmap])    #_ "starmap(function, iterable)" ;;

    #_ "lstarmap(function, iterable) -> list | literally just list(starmap(function, iterable))"
    (defn lstarmap [function iterable]
        "literally just list(starmap(function, iterable))"
        (list (starmap function iterable)))

    (import functools [reduce])             #_ "reduce(function, sequence[, initial]) -> value | theory: reduce + monoid = binary-function for free becomes n-arg-function"
    (import funcy     [reductions])         #_ " reductions(f, seq [, acc]) -> generator | returns sequence of intermetidate values of reduce(f, seq, acc)"
    (import funcy     [lreductions])        #_ "lreductions(f, seq [, acc]) -> List | returns sequence of intermetidate values of reduce(f, seq, acc)"
    (import funcy     [sums])               #_ " sums(seq [, acc]) -> generator | reductions with addition function"
    (import funcy     [lsums])              #_ "lsums(seq [, acc]) -> List |"
    (import math      [prod :as product])   #_ "product(iterable, /, *, start=1) | product([2, 3, 5]) = 30"
    ;;

    (comment "py | base | zip | zip(*iterables) -> zip object |")
    
    #_ "lzip(*iterables) -> List | literally just list(zip(*iterables))"
    (defn lzip [#* iterables] (list (zip #* iterables)))

; ________________________________________________________________________/ }}}2
; [GROUP] FP: n-applicators ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (require hyrule [do_n])     #_ "(do_n   n #* body) -> None |"
    (require hyrule [list_n])   #_ "(list_n n #* body) -> List |"

    #_ "nested(n, f) | f(f(f(...f))), returns function"
    (defn nested [n f]
        " f(f(f(...f))), where nesting is n times deep,
          returns function
        "
        (compose #* (list_n n f)))

    #_ "apply_n(n, f, *args, **kwargs) | f(f(f(...f(*args, **kwargs))"
    (defn apply_n [n f #* args #** kwargs]
        " applies f to args and kwargs,
          than applies f to result of prev application,
          and this is repeated in total for n times,
          n=1 is simply f(args, kwargs)
        "
        ((compose #* (list_n n f)) #* args #** kwargs))

; ________________________________________________________________________/ }}}2

; [GROUP] APL: filtering ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (comment "py | base | filter | filter(function or None, iterable) -> filter object | when f=None, checks if elems are True")
    (import funcy [lfilter]) #_ "lfilter(pred, seq) -> List | list(filter(...)) from funcy"
    ;;

    (import itertools [compress :as mask_sel]) #_ "mask_sel(data, selectors) -> iterator | selects by mask: mask_sel('abc', [1,0,1]) -> iterator: 'a', 'c'"

    #_ "lmask_sel(data, selectors) -> list |"
    (defn lmask_sel [data selectors]
        "selects by mask: lmask_sel('abc', [1,0,1]) -> ['a', 'c']"
        (list (mask_sel data selectors)))

    #_ "mask2idxs(mask) -> list | mask is list like [1 0 1 0] or [True False True False], which will be converted to [0 2]"
    (defn mask2idxs [mask]
        "mask is list like [1 0 1 0] or [True False True False], which will be converted to [0 2]"
        (setv idxs [])
        (for [[&i &elem] (enumerate mask)]
             (if &elem (idxs.append &i) "no action"))
        (return idxs))

    #_ "idxs2mask(idxs) -> list | idxs is non-sorted list of integers like [0 3 2], which will be converted to [1 0 1 1]"
    (defn idxs2mask [idxs [bools False]]
        " idxs is non-sorted list of positive integers like [0 3 2], which will be converted to [1 0 1 1] ;
          setting bools=True will output [True False True True] instead"
        (when (= (len idxs) 0) (return []))
        ;;
        (setv mask_len (+ 1 (max idxs)))
        (setv mask (list (funcy.repeat 0 mask_len)))
        (for [&idx idxs] (assoc mask &idx 1))
        ;;
        (when bools (setv mask (lmap (fn [it] (= True it)) mask)))
        (return mask))

    #_ "fltr1st(f, seq) -> Optional elem | returns first found element (or None)"
    (defn fltr1st [function iterable]
        "returns first found element (via function criteria), returns None if not found"
        (next (gfor &x iterable :if (function &x) &x) None))

    (import funcy [remove :as reject])   #_ "reject(pred, seq)-> iterator | same as filter, but checks for False"
    (import funcy [lremove :as lreject]) #_ "lreject(pred, seq) -> List | list(reject(...))"
    ;;

    #_ "without(items, seq) -> generator | returns seq without each item in items"
    (defn without [items seq]
        "returns generator for seq with each item in items removed (does not mutate seq)"
        (funcy.without seq #* items))

    #_ "lwithout(items, seq) -> list | list(without(...))"
    (defn lwithout [items seq]
        "returns seq with each item in items removed (does not mutate seq)"
        (funcy.lwithout seq #* items))

    (import funcy [takewhile]) #_ "takewhile([pred, ] seq) | yields elems of seq as long as they pass pred"
    (import funcy [dropwhile]) #_ "dropwhile([pred, ] seq) | mirror of dropwhile"

    (import funcy [split      :as filter_split])  #_ "filter_split(pred, seq) -> passed, rejected |"
    (import funcy [lsplit     :as lfilter_split]) #_ "lfilter_split(pred,seq) -> passed, rejected | list(filter_split(...))"
    (import funcy [split_at   :as bisect_at])     #_ "bisect_at(n, seq) -> start, tail | len of start will = n, works only with n>=0"
    ;;

    #_ "lbisect_at(n, seq) -> start, tail | list version of bisect_at, but also for n<0, abs(n) will be len of tail"
    (defn lbisect_at [n seq]
        " splits seq to start and tail lists (returns tuple of lists),
          when n>=0, len of start will be = n (or less, when len(seq) < n),
          when n<0, len of tail will be = n (or less, when len(seq) < abs(n))
        "
        (if (>= n 0)
            (funcy.lsplit_at n seq)
            (funcy.lsplit_at (max 0 (+ (len seq) n)) seq)))

    (import funcy [split_by   :as bisect_by])     #_ " bisect_by(pred, seq) -> taken, dropped | similar to (takewhile, dropwhile)"
    (import funcy [lsplit_by  :as lbisect_by])    #_ "lbisect_by(pred, seq) -> taken, dropped | list version of lbisect"
    ;;

; ________________________________________________________________________/ }}}2
; [GROUP] APL: iterators and looping ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (import itertools [islice])              #_ "islice(iterable, stop), islice(iterable, start, stop[, step]) |" 

    (import itertools [count :as inf_range]) #_ "inf_range(start [, step]) | inf_range(10) -> 10, 11, 12, ..."
    (import itertools [cycle])               #_ "cycle(p) | cycle('AB') -> A B A B ..."

    #_ "lcycle(p, n) -> list | takes first n elems from cycle(p)"
    (defn lcycle [p n] "takes first n elems from cycle(p)" (list (islice (cycle p) n)))

    (import itertools [repeat])              #_ "repeat(elem [, n]) | repeat(10,3) -> 10 10 10" 

    #_ "lrepeat(elem, n) -> list | unlike in repeat, n has to be provided"
    (defn lrepeat [elem n] "literally just list(repeat(elem, n))" (list (repeat elem n)))

    ;; ========================================

    (import itertools [chain :as concat])    #_ "concat(*seqs) -> iterator |"

    #_ "lconcat(*seqs) -> list | list(concat(*seqs))"
    (defn lconcat [#* seqs] "literally just list(concat(*seqs))" (list (concat #* seqs)))

    (import funcy     [cat])        #_ "cat(seqs)  | non-variadic version of concat"
    (import funcy     [lcat])       #_ "lcat(seqs) | non-variadic version of concat"

    (import funcy     [mapcat])     #_ "mapcat(f, *seqs)  | maps, then concatenates"
    (import funcy     [lmapcat])    #_ "lmapcat(f, *seqs) | maps, then concatenates"

    (import funcy     [pairwise])   #_ "pairwise(seq) -> iterator | supposed to be used in loops, will produce no elems for seq with len <= 1"
    (import funcy     [with_prev])  #_ "with_prev(seq, fill=None) -> iterator | supposed to be used in loops"
    (import funcy     [with_next])  #_ "with_next(seq, fill=None) -> iterator | supposed to be used in loops"

; ________________________________________________________________________/ }}}2
; [GROUP] APL: working with lists ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (import hyrule [flatten])   #_ "flattens to the bottom" ;;

    #_ "lprint(seq, sep=None) | literally just list(map(print,seq))"
    (defn lprint [seq [sep None]]
          " essentially list(map(print, seq))

            with sep='---' (or some other) will print sep between seq elems
          "
          (if (= sep None)
              (lmap print seq)
              (lmap print (funcy.interpose sep seq)))
          (return None))

    (comment "py | base | reversed | reversed(sequence) -> iterator |") 

    #_ "lreversed(sequence) = list(reversed(seq)) |"
    (defn lreversed [sequence] (list (reversed sequence)))

    #_ "partition(n, seq, *, step=None, tail=False) -> generator | splits seq to lists of len n, tail=True will allow including fewer than n items"
    (defn partition [n seq * [step None] [tail False]]
        " splits seq to lists of len n,
          at step offsets apart (step=None defaults to n when not given),
          tail=False will allow fewer than n items at the end;
          returns generator"
        (cond (and (not tail) (is step None))
              (funcy.partition n seq)
              (and (not tail) (not (is step None)))
              (funcy.partition n step seq)
              (and tail (is step None))
              (funcy.chunks n seq)
              (and tail (not (is step None)))
              (funcy.chunks n step seq)))

    #_ "lpartition(n, seq, *, step=None, tail=False) -> List | simply list(partition(...))"
    (defn lpartition [n seq * [step None] [tail False]]
        " splits seq to lists of len n,
          at step offsets apart (step=None defaults to n when not given),
          tail=False will allow fewer than n items at the end;
          returns list of lists"
        (list (partition n seq :step step :tail tail)))

    (import funcy [partition_by])   #_ "partition_by(f, seq) -> iterator of iterators | splits when f(item) change" ;;
    (import funcy [lpartition_by])  #_ "lpartition_by(f,seq) -> list of lists | list(partition_by(...))" ;;

    (import funcy [group_by] #_ "group_by(f, seq) -> defaultdict(list) | groups elems of seq keyed by the result of f")

    #_ "lmulticut_by(pred, seq, keep_border=True, merge_border=False) -> list | cut at pred(elem)==True elems"
    (defn #^ (of List list)
        lmulticut_by 
        [ pred
          #^ list seq
          [keep_border  True ]
          [merge_border False]
        ]
        " cuts at elems which give pred(elem)=True
          #
          keep_border =True  will keep elements with pred(elem)=True
          merge_border=True  will cut only at first of a sequence of pred(elem)=True elems 
          #
          in the example below oddQ is function that gives True for odd numbers,
          that is cuts will happen at elems=1
          #
                                                 #  keep_b merge_b
                                                 #  ------ -------
          lmulticut_by(oddQ, [1, 0, 1, 1, 0, 0, 1], True , True ) # -> [[1, 0], [1, 1, 0, 0], [1]]
          lmulticut_by(oddQ, [1, 0, 1, 1, 0, 0, 1], True , False) # -> [[1, 0], [1], [1, 0, 0], [1]]
          lmulticut_by(oddQ, [1, 0, 1, 1, 0, 0, 1], False, True ) # -> [[0], [0, 0]]
          lmulticut_by(oddQ, [1, 0, 1, 1, 0, 0, 1], False, False) # -> [[0], [], [0, 0], []]
        "
        (when (= (len seq) 0) (return []))
        (setv _newLists [])
        ;;
        (for [&elem seq]
            (if (pred &elem)
                (_newLists.append [&elem])
                (if (= (len _newLists) 0)
                    (_newLists.append [&elem])
                    (. (last _newLists) (append &elem)))))
        ;;
        (when (not keep_border)
              (setv _newLists (lmap (fn [it] (if (pred (get it 0))
                                                 (cut it 1 None)
                                                 it))
                                    _newLists)))
        ;;
        (when merge_border
              (if keep_border
                  (do (setv single_borders_pos [])
                      (for [&i (range 0 (len _newLists))]
                           (setv cur_list (get _newLists &i))
                           (when (and (= (len cur_list) 1)
                                      (pred (get cur_list 0)))
                                 (single_borders_pos.append &i)))
                      (for [&i single_borders_pos]
                           (when (< &i (dec (len _newLists)))
                                 (setv (get _newLists (inc &i)) (+ (get _newLists &i) (get _newLists (inc &i))))))
                      (setv others_pos (list (- (set (range 0 (len _newLists))) (set single_borders_pos))))
                      (when (in (dec (len _newLists)) single_borders_pos)
                            (others_pos.append (dec (len _newLists))))
                      (setv _newLists (pick others_pos _newLists)))
                  (setv _newLists (lwithout [[]] _newLists))))
        (return _newLists))

; ________________________________________________________________________/ }}}2
; [GROUP] APL: counting ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    #_ "count_occurrences(elem, seq) -> int | rename of list.count method"
    (defn count_occurrences [elem seq] (seq.count elem))

; ________________________________________________________________________/ }}}2

; [GROUP] General Math ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (import hyrule    [inc])
    (import hyrule    [dec])
    (import hyrule    [sign])
    (import operator  [neg])
    ;;

    #_ "(half x) = (/ x 2)"
    (defn half       [x] "half(x) = x / 2" (/ x 2))

    #_ "(double x) = (* x 2)"
    (defn double     [x] "double(x) = x * 2" (* x 2))

    #_ "(squared x) = (pow x 2)"
    (defn squared    [x] "squared(x) = pow(x, 2)" (pow x 2))

    #_ "reciprocal(x) = 1/x literally |"
    (defn reciprocal [x] "reciprocal(x) = 1 / x" (/ 1 x))

    (import math [sqrt])
    (import math [dist])    #_ "dist(p, q) -> float | ≈ √((px-qx)² + (py-qy)² ...)"
    (import math [hypot])   #_ "hypot(*coordinates) | = √(x² + y² + ...)" ;;

    #_ "normalize(xs) -> xs | returns same vector xs if it's norm=0"
    (defn normalize [xs]
        " devides each coord of vector to vectors norm,
          example: norm of [1, 2, 3] = sqrt(1 + 4 + 9) = sqrt(14) ~= 3.74,
          so will return [1/3.74, 2/3.74, 3/3.74]
          ---
          will return same vector when norm == 0"
        (setv norm (hypot #* xs))
        (if (!= norm 0) (return (lmap (pflip div norm) xs)) (return xs)))

    (import math     [exp]) #_ "exp(x) |"

    (import math     [log]) #_ "log(x, base=math.e)" ;;

    #_ "ln(x) = math.log(x, math.e) | coexists with log for clarity"
    (defn ln [x] (log x))

    (import math [log10])  #_ "log10(x) |"

    ;; checks:

    (import funcy [even :as evenQ])
    (import funcy [odd  :as oddQ])   

    #_ "| checks directly via (= x 0)"
    (defn zeroQ     [x] "checks literally if x == 0" (= x 0))

    #_ "| checks directly via (< x 0)"
    (defn negativeQ [x] "checks literally if x < 0" (< x 0))

    #_ "| checks directly via (> x 0)"
    (defn positiveQ [x] "checks literally if x > 0" (> x 0))


; ________________________________________________________________________/ }}}2
; [GROUP] Trigonometry ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (import math [pi])      #_ "| literally just float pi=3.14..."
    (import math [sin])     #_ "sin(x) | x is in radians"
    (import math [cos])     #_ "cos(x) | x is in radians"
    (import math [tan])     #_ "tan(x) | x is in radians, will give smth like 1.6E+16 for x = pi"
    (import math [degrees]) #_ "degrees(x) | x in radians is converted to degrees"
    (import math [radians]) #_ "radians(x) | x in degrees is converted to radians"
    (import math [acos])    #_ "acos(x) | x is in radians, result is between 0 and pi"
    (import math [asin])    #_ "asin(x) | x is in radians, result is between -pi/2 and pi/2"
    (import math [atan])    #_ "asin(x) | x is in radians, result is between -pi/2 and pi/2"
    (import math [atan2])   #_ "atan2(y, x) | both signs are considered"

; ________________________________________________________________________/ }}}2
; [GROUP] Base operators to functions ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (import operator [and_])                #_ "'and' as function"
    (import operator [or_])                 #_ "'or' as function"
    (import operator [not_])                #_ "'not' as function"
    (import operator [is_])                 #_ "'is' as function"
    (import operator [xor])                 

    (import operator [eq])                  #_ "equal"
    (import operator [ne :as neq])          #_ "non-equal"
    (import operator [gt])                  #_ "greater than"
    (import operator [lt])                  #_ "less than"
    (import operator [ge :as geq])          #_ "greater or equal"
    (import operator [le :as leq])          #_ "less or equal"

    (import operator [matmul])              #_ "'@' as function"
    (import operator [truediv :as div])     #_ "div(a, b) |"

    #_ "minus(x, y) = x - y |"
    (defn minus [x y] "minux(x, y) = x - y" (- x y))

    ;; =========================================================================
    ;; dunders
    ;; - python behaves like so:
    ;; - (*) = 1, (* 3) = 3 
    ;; - (+) = 0, (+ 3) = 3 
    ;; - (+ "") = error, (+ []) = error
        
        #_ "dmul(*args) = arg1 + arg2 + ... | 'dunder mul', '*' operator as a function"
        (defn dmul [#* args]
            "dunder mul, '*' operator as a function"
            (* #* args))

        #_ "dadd(*args) = arg1 + arg2 + ... | 'dunder add', '+' operator as a function"
        (defn dadd [#* args]
            "dunder add, '+' operator as a function"
            (+ #* args))

    ;; renames

        #_ "lmul(*args) = arg1 * arg2 * ... | rename of * operator, underlines usage for list"
        (defn lmul [#* args]
            "rename of * operator, can be used to underline usage on list"
            (* #* args))

        #_ "smul(*args) = arg1 * arg2 * ... | rename of * operator, underlines usage for string"
        (defn smul [#* args]
            "rename of * operator, can be used to underline usage on string"
            (* #* args))

    ;; monoids

        #_ "mul(*args) | multiplication as a monoid (will not give error when used with 0 or 1 args)"
        (defn mul [#* args]
            " multiplication as a monoid with identity = 1,
              can be used with 0 or 1 arg"
            (reduce operator.mul args 1))

        #_ "plus(*args) | addition as a monoid (will not give error when used with 0 or 1 args)"
        (defn plus [#* args]
            " plus as a monoid with identity = 0 "
            (reduce (fn [%s1 %s2] (+ %s1 %s2)) args 0))

        #_ "sconcat(*args) | string concantenation as a monoid (will not give error when used with 0 or 1 args)"
        (defn sconcat [#* args]
            " string concantenation as a monoid with identity = '',
              can be used with 0 or 1 args"
            (reduce (fn [%s1 %s2] (+ %s1 %s2)) args ""))

        ;; lconcat (list on itertools.chain) is a monoid on lists too

; ________________________________________________________________________/ }}}2
; [GROUP] General checksQ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    ;; my convenience funcs:

    #_ "fnot(f, *args, **kwargs) = not(f(*args, **kwargs)) | "
    (defn fnot [f #* args #** kwargs]
        "literally just not(f(*args, **kwrgs))"
        (not (f #* args #** kwargs)))

    #_ "(eq_any x values) | (and (eq x value1) (eq x value2) ...)"
    (defn eq_any [x values]
        "essentially just or(eq(x, value1), eq(x, value2), ...)"
        (or #* (lmap (fn [it] (= x it)) values)))

    #_ "(on f check x y) | (on len eq xs ys) -> (eq (len xs) (len yx))"
    (defn on [f check x y]
        "inspired by Haskell's 'on' function, essentially is check(f(x), f(y)) "
        (check (f x) (f y)))

    #_ "all_fs(fs, *args, **kwargs) | checks if all f(*args, **kwargs) are True"
    (defn all_fs [fs #* args #** kwargs]
        "checks if all f(*args, **kwargs) are True"
        (and #* (lfor &f fs (&f #* args #** kwargs))))

    #_ "any_fs(fs, *args, **kwargs) | checks if any of f(*args, **kwargs) is True"
    (defn any_fs [fs #* args #** kwargs]
        "checks if any of f(*args, **kwargs) is True"
        (or #* (lfor &f fs (&f #* args #** kwargs))))

    #_ "| checks directly via (= x True)"
    (defn trueQ [x] "checks literally if x == True" (= x True))

    #_ "| checks directly via (= x False)"
    (defn falseQ [x] "checks literally if x == False" (= x False))

    #_ "(oflenQ xs n) -> (= (len xs) n) |"
    (defn oflenQ [xs n] "checks literally if len(xs) == n" (= (len xs) n))

    #_ "| checks literally if (= (len xs) 0)"
    (defn zerolenQ [xs] "checks literally if len(xs) == 0" (= (len xs) 0))

; ________________________________________________________________________/ }}}2

; [GROUP] Strings ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    #_ "strlen(text) | rename of len, underlines usage on strings"
    (defn strlen [text]
        "rename of len, underlines usage on strings"
        (len text))

    #_ "str_join(ss, sep='') | rearrangement of funcy.str_join, ss is seq of strings"
    (defn str_join [ss [sep ""]]
        "str_join(['1', '2', '3'], '-') = '1-2-3'"
        (if (bool sep)
            (funcy.str_join sep ss)
            (funcy.str_join ss)))

    #_ "lowercase(string) | str.lower method as a function"
    (defn #^ str lowercase [#^ str string]
        "str.lower method as a function"
        (string.lower))

    #_ "strip(string, chars=None) | str.strip method as a function"
    (defn #^ str strip [#^ str string [chars None]]
        " str.strip method as a function, 
          removes leading and trailing whitespaces (or chars when given)"
        (string.strip chars))

    #_ "lstrip(string, chars=None) | str.lstrip method as a function"
    (defn #^ str lstrip [#^ str string [chars None]]
        "str.lstrip method as a function"
        (string.lstrip chars))

    #_ "rstrip(string, chars=None) | str.rstrip method as a function"
    (defn #^ str rstrip [#^ str string [chars None]]
        "str.rstrip method as a function"
        (string.rstrip chars))

    #_ "enlengthen(string, target_len, char=' ', on_tail=True) | adds char to string until target_len reached"
    (defn #^ str
        enlengthen
        [ #^ int  target_len
          #^ str  string
          #^ str  [char      " "]
          #^ bool [on_tail   True]
          #^ bool [force_len False]
        ]
        " appends char to string until target_len reached

          - if len(string) > target_len, will return string with no change
          - with on_tail=False will prepend chars rather than append
          - with force_len=True will cut string to target_len if required (taking on_tail option into account)
          - when len(char)> 1 is given, repeats it's pattern, but still ensures target_len 
        "
        (when (< target_len 0) (raise (ValueError "target_len < 0 is not allowed")))
        (when (= char "")      (raise (ValueError "empty char is not allowed")))
        ;;
        (when (and force_len 
                   (> (len string) target_len))
              (if on_tail (return (cut string target_len))
                          (return (take (- target_len) string))))
        ;;
        (setv n_required (max 0 (- target_len (len string))))
		(if on_tail
			(setv outp (sconcat string (cut (* char n_required) 0 (- target_len (len string)))))
			(setv outp (sconcat (cut (* char n_required) 0 (- target_len (len string))) string)))
		(return outp))

; ________________________________________________________________________/ }}}2
; [GROUP] Regex ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    ;; Theory:
    ;;      re: match, search, findall, finditer, split, compile, fullmatch, escape
    ;;      non-escaped (commands):   .  ^  $  *  +  ? {2,4} [abc]      ( | )
    ;;      escaped (literals):      \. \^ \$ \* \+ \? \{ \} $$_bracket $_parenthesis \| \\ \' \"
    ;;      special:                 \d \D \w \W \s \S \b \B \n \r \f \v
    ;;      raw strings:             r"\d+" = "\\d+"

    (import re        [sub :as re_sub])         #_ "re_sub(rpattern, replacement, string, count=0, flags=0) |"
    (import re        [split :as re_split])     #_ "re_split(rpattern, string) |"
    (import funcy     [re_find])                #_ "re_find(rpattern, string, flags=0) -> str| returns first found"
    (import funcy     [re_test])                #_ "re_test(rpattern, string, ...) -> bool | tests if string has match (not neccessarily whole string)"
    (import funcy     [re_all])                 #_ "re_all(rpattern, string, ...) -> List |"

; ________________________________________________________________________/ }}}2
; [GROUP] Random ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (import random    [choice])                 #_ "choice(seq) -> Elem | throws error for empty list"
    (import random    [randint])                #_ "randint(a, b) -> int | returns random integer in range [a, b] including both end points" 
    (import random    [uniform :as randfloat])  #_ "randfloat(a, b) -> float | range is [a, b) or [a, b] depending on rounding"
    (import random    [random :as rand01])      #_ "rand01() -> float | generates random number in interval [0, 1) "

    ;; shuffle — is mutating

; ________________________________________________________________________/ }}}2

; [GROUP] IO ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (import os.path [exists :as file_existsQ]) #_ "file_existsQ(filename) | also works on folders" ;;

    #_ "read_file(file_name, encoding='utf-8') -> str | returns whole file content"
    (defn read_file
        [ #^ str file_name
          #^ str [encoding "utf-8"]
        ]
        "returns whole file content"
        (with [file (open file_name "r" :encoding encoding)] (setv outp (file.read)))
        (return outp))

    #_ "write_file(text, file_name, mode='w', encoding='utf-8') | modes: 'w' - (over)write, 'a' - append, 'x' - exclusive creation"
    (defn write_file
        [ #^ str text
          #^ str file_name
          #^ str [mode "w"]
          #^ str [encoding "utf-8"]
        ]
        " writes text to file_name;
          modes:
          - 'w' - (over)write
          - 'a' - append
          - 'x' - exclusive creation"
        (with [file (open file_name mode :encoding encoding)] (file.write text)))

; ________________________________________________________________________/ }}}2
; [GROUP] Benchmarking ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    #_ "w_e_t(f, *, n=1, tUnit='ns', msg='') -> avrg_time_of_1_run_in_seconds, pretty_string, f_result | f_result is from 1st function execution"
    (defn #^ (of Tuple float str Any)
        with_execution_time
        [ #^ Callable f
          *
          #^ int      [n     1]
          #^ str      [tUnit "ns"]      #_ "s/ms/us/ns"
          #^ str      [msg   ""]
        ]
        " returns tuple:
          - average time of 1 execution in seconds
          - pretty string of execution time in tUnit units
          - function return value from 1st execution

          tUnit can be: s, ms, us, ns"
        (setv _time_getter hy.I.time.perf_counter)
        (setv n (int n))
        ;;
        (setv t0 (_time_getter))
        (setv _outp (f))
        (do_n (dec n) (f))
        (setv t1 (_time_getter))
        (setv seconds (- t1 t0))
        (setv _time_1_s (/ seconds n))
        ;;
        (case tUnit
            "s"  (do (setv time_n    seconds            ) (setv unit_str " s"))
            "ms" (do (setv time_n (* seconds 1000)      ) (setv unit_str "ms"))
            "us" (do (setv time_n (* seconds 1000000)   ) (setv unit_str "us"))
            "ns" (do (setv time_n (* seconds 1000000000)) (setv unit_str "ns")))
        (setv time_1 (/ time_n n))
        ;;
        (setv line_01       f"/ ({msg})")
        (setv line_02_time1 f"\\ {time_1 :.3f} {unit_str}")
        (setv line_02_n     (re_sub "," "'" f"average of {n :,} runs"))
        (setv line_02_timeN f"test duration: {seconds :.3f} s")
        ;;
        (setv _prompt (sconcat line_01 "\n"
                               line_02_time1 " as " line_02_n " // " line_02_timeN))
        (return [_time_1_s _prompt _outp]))
    ;;
    ;; (print (execution_time :n 100 (fn [] (get [1 2 3] 1))))

    #_ "dt_printer(* args, fresh_run=False) | starts timer on fresh run, prints time passed since previous call"
    (defn dt_print
        [ #* args
          [fresh_run False]
          [last_T    [None]]
        ]
        " on first run, starts the timer (and print message that it started)
          on subsequent runs prints how many time (in seconds) have passed since previous call
          #
          call with fresh_run = True to reset timer
          #
          last_T should not be touched by user!
          it is used for storing time of previous run between runs"
        (when fresh_run (assoc last_T 0 None))
        (setv _time_getter hy.I.time.perf_counter)
        (setv curT (_time_getter))
        ;;
        (if (=  (get last_T 0) None)
            (do (assoc last_T 0 curT)
                (print "[ Timer started ]" #* args))
            (do (setv dT (- curT (get last_T 0)))
                (assoc last_T 0 curT)
                (print f"[dT = {dT :.6f} s]" #* args))))

; ________________________________________________________________________/ }}}2


; _____________________________________________________________________________/ }}}1
; macros ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

; Import ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (import  hyrule [rest butlast])
	(require hyrule [-> ->> of])
    (import  operator)

; ________________________________________________________________________/ }}}2


; === Helpers (precompiled functions) ===
; neg integer expr ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

	; (- 1)
	(-> (defn _isNegIntegerExpr
			[ arg
			]
			(and (= (type arg) hy.models.Expression)
				 (= (get arg 0) (hy.models.Symbol "-"))
				 (= (len arg) 2)
				 (= (type (get arg 1)) hy.models.Integer)))
		eval_and_compile)

	; (_isNegIntegerExpr '(- 3))

; ________________________________________________________________________/ }}}2
; expr with head symbol ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

	; (head ...)
	(-> (defn _isExprWithHeadSymbol
			[ #^ hy.models.Expression arg
			  #^ str head
			]
			(and (= (type arg) hy.models.Expression)
				 (= (get arg 0) (hy.models.Symbol head))))
		eval_and_compile)

; ________________________________________________________________________/ }}}2
;
; DEVDOC: Dot Macro Expressions ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2
(when False

	;in normal code:
		'obj.attr				; / access attr (no call)  ; [. obj attr]
		'(. obj attr)			; \
		'(. obj (mth arg1))		; access mth (and call)    ; [. obj [mth arg1]]
		'(.mth obj arg1)		; access mth (and call)    ; [[. None mth] obj arg1]
		'(obj.mth 3)			; access mth (and call)    ; [[. obj mth] 3]

	;in hyrule -> macro:
		'(-> obj func1 .attr)			; will give error, since can't call
		'(-> obj func1 (. obj2 mth 1))	; will give error, since can't parse to correct place
		;
		'(-> obj obj2.mth)				; will expand to: (obj2.mth obj)
		'(-> obj (obj2.mth 2))			; will expand to: (obj2.mth obj 2)
		'(-> obj func1 .method)			; will expand to: (. (func1 obj) (method))
		'(-> obj func1 (.method 1))		; will expand to: (. (func1 obj) (method 1))
		'(-> obj func1 (. obj2 mth))	; will expand to: (obj2.mth (func1 obj))

	; used in my p> macro:
		'.attr					; dottedAttr	; [. None attr]			; ~ get attr
		'operator.neg			; dottedAccess	; [. operator neg]		; (partial operator.neg)
		'(operator.add 3)		; dottedCall	; [[. operator add] 3]	; (partial operator.add 3)
		'(.mth)					; dottedMth		; [[. None mth]]		; ~(partial obj.mth 1 2)
		'(.mth 1 2)				; dottedMth		; [[. None mth] 1 2]	; ~(partial obj.mth 1 2)

)
; ________________________________________________________________________/ }}}2
; .dottedAttr ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

	; .x
	(-> (defn _isDottedAttr
			[ arg
			]
			(and (= (type arg) hy.models.Expression)
				 (= (get arg 0) (hy.models.Symbol "."))
				 (= (get arg 1) (hy.models.Symbol "None"))))
		eval_and_compile)

	; hy.models.Symbol[x]
	(-> (defn #^ hy.models.Symbol
			_extractDottedAttr
			[ arg
			]
			(get arg 2))
		eval_and_compile)

; ________________________________________________________________________/ }}}2
; .dottedAccess ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

	; operator.add
	(-> (defn _isDottedAccess
			[ arg
			]
			(and (= (type arg) hy.models.Expression)
				 (= (get arg 0) (hy.models.Symbol "."))
				 (= (type (get arg 1)) hy.models.Symbol)
				 (!= (get arg 1) (hy.models.Symbol "None"))))
		eval_and_compile)

; ________________________________________________________________________/ }}}2
; .dottedMth ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

	; (.mth obj 1 2)
	;  ---- -------
	;  head  args
	(-> (defn _isDottedMth
			[ arg
			]
			(and (= (type arg) hy.models.Expression)
				 (_isDottedAttr (get arg 0))))
		eval_and_compile)

	(-> (defn _extractDottedMth
			[ arg
			]
			(dict :head (get arg 0 2)
				  :args (cut arg 1 None)))
		eval_and_compile)

	 ; (_isDottedMth '(.obj obj 1 2))
	 ; (_extractDottedCall '(.obj obj 1 2))

; ________________________________________________________________________/ }}}2
; [ARCHIVE] :attr: ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

	; leftover from lns macro:
	;
	;(_isAttrAccess &arg)
	;(setv (get args &i) (hy.models.Symbol (_extractAttrName &arg)))

	; leftover from pluckm macro:
	;
	; (_isAttrAccess indx)
	; (return `(lpluck_attr ~(_extractAttrName indx) ~iterable)))

	(-> (defn #^ bool
			_isAttrAccess
			[ arg
			]
			(setv arg_str (str arg))
			(and (= (type arg) hy.models.Keyword)
				 (> (len arg_str) 2)
				 (= (get arg_str (- 1)) ":")))
		eval_and_compile)

	(-> (defn #^ str
			_extractAttrName
			[ arg
			]
			(cut (str arg) 1 (- 1)))
		eval_and_compile)

; ________________________________________________________________________/ }}}2

; === Macros ===

    ; when only importing (import fptk [f>]), f> is required to have fm internally, and it can be called as:
    ; 
    ; -> hy.R._fptk_local.fm               -> ✗ does not work in dev file
    ;                                  ✓ works from outside projs (it is essentially call to installed lib)
    ;                                  ✓ this is how it is done in hyrule (I think this is due to their hy_init.hy importing everything)
    ;                                        
    ;    fm                         -> [✓ ✗] works from dev file
    ;    hy.R.fptk_macros.fm        -> [✓ ✗] works from dev file
    ;    hy.R.fptk.fptk_macros.fm   -> [✗ ✗] does not work anywhere

; f:: ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

	(defmacro f:: [#* macro_args]
		;
		(setv fInputsOutputs (get macro_args (slice None None 2)))
		(setv fInputs (get fInputsOutputs (slice 0 (- 1))))
		(setv fOutput (get fInputsOutputs (- 1)))
		`(of Callable ~fInputs ~fOutput))

; ________________________________________________________________________/ }}}2
; p: ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

; ■ comment on (.mth 3 4) deconstruction ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{3

	; this is how (.mth 3 4) works:

	;	(defclass [dataclass] Point []
	;		(#^ int x)
	;		(#^ int y)
	;		(defn getXscaled [self scale1 scale2] (* scale1 scale2 self.x)))
	;	
	;	; will be assembled to: Point(7,2).getXscaled(3,4)
	;	(	(rcompose (partial Point 7)
	;				  (partial flip getattr "getXscaled")					; \
	;				  (partial (fn [%args %mth] (%mth #* %args)) [3 4]))	; /
	;		2)

; ___________________________________________________________________/ }}}3

	; .attr				; [. None attr]			; _isDottedAttr   checks for: [. None _]
	; (.mth 1 2)		; [[. None mth] 1 2]	; _isDottedMth	  checks for: [[. None _] _]
	; operator.neg		; [. operator neg]		; _idDottetAccess checks for: [. smth _]
	; (operator.add 3)	; [[. operator add] 3]

	(defmacro p: [#* args]
		(setv pargs [])
		(for [&arg args]
			  (cond ; .x  -> (partial flip getattr "x")
					(_isDottedAttr &arg)
					(pargs.append `(hy.I.funcy.partial (fn [f x y] (f y x)) getattr ~(str (_extractDottedAttr &arg))))
					; operator.neg
					(_isDottedAccess &arg)
					(pargs.append `(hy.I.funcy.partial ~&arg))
					; (. mth 2 3) -> essentially (. SLOT mth 2 3)
					(_isDottedMth &arg)
					(do (pargs.append `(hy.I.funcy.partial (fn [f x y] (f y x)) getattr
											~(str (get (_extractDottedMth &arg) "head")))) ; -> mth)
						(pargs.append `(hy.I.funcy.partial (fn [%args %mth] (%mth (unpack_iterable  %args)))
												[~@(get (_extractDottedMth &arg) "args")])))
					; abs -> (partial abs)
					(= (type &arg) hy.models.Symbol)
					(pargs.append `(hy.I.funcy.partial ~&arg))
	                ; (fn/fm ...) -> no change
                    (or (_isExprWithHeadSymbol &arg "fn")
                        (_isExprWithHeadSymbol &arg "fm")
                        (_isExprWithHeadSymbol &arg "f>"))
                    (pargs.append &arg)
					; (func 1 2) -> (partial func 1 2)
					; (operator.add 3) -> (partial operator.add 3)
					(= (type &arg) hy.models.Expression)
					(pargs.append `(hy.I.funcy.partial ~@(cut &arg 0 None)))
					; (etc ...) -> (partial etc ...)
					True
					(pargs.append `(hy.I.funcy.partial ~&arg))))
	   `(hy.I.funcy.rcompose ~@pargs))

; ________________________________________________________________________/ }}}2
; (l)pluckm, getattrm ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

	(defmacro pluckm [indx iterable]
		(cond ; .attr -> "attr"
			  (_isDottedAttr indx)
			  (return `(hy.I.funcy.pluck_attr ~(str (_extractDottedAttr indx)) ~iterable))
			  ;
			  True
			  (return `(hy.I.funcy.pluck ~indx ~iterable))))

	(defmacro lpluckm [indx iterable]
		(cond (_isDottedAttr indx) (return `(hy.I.funcy.lpluck_attr ~(str (_extractDottedAttr indx)) ~iterable))
			  True                 (return `(hy.I.funcy.lpluck ~indx ~iterable))))

	(defmacro getattrm [iterable #* args] ; first arg is «indx», second - is «default» (may be absent)
        (setv indx (get args 0))
        (cond (= (len args) 1)
              (setv default_not_given True)
              (= (len args) 2)
              (do (setv default (get args 1))
                  (setv default_not_given False)))
		(cond ; .attr -> "attr"
			  (_isDottedAttr indx)
              (if default_not_given
                  (return `(getattr ~iterable ~(str (_extractDottedAttr indx))))
                  (return `(getattr ~iterable ~(str (_extractDottedAttr indx)) ~default)))
			  ;
			  True
			  (if default_not_given
                  (return `(getattr ~iterable ~indx))
                  (return `(getattr ~iterable ~indx ~default)))))

; ________________________________________________________________________/ }}}2
; fm, f>, (l)mapm, (l)filterm ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

	; recognizes "it" as solo-arg
    ; or %1..%9 as multi args
    ; 
	; "it" cannot be used together with %i
	; 
	; nested fm calls will probably not work as intended

	(defmacro fm [expr]
		(import hyrule [flatten thru])
		;
        (setv args (->> expr
                        flatten
                        (filter (fn [%x] (or (= %x 'it)
                                             (= %x '%1) (= %x '%2) (= %x '%3)
                                             (= %x '%4) (= %x '%5) (= %x '%6)
                                             (= %x '%7) (= %x '%8) (= %x '%9))))
                        sorted))    ; example: [hy.models.Symbol('%1'), hy.models.Symbol('%2')]
        (when (in 'it args) (return `(fn [it] ~expr)))
		(if (= (len args) 0)
			(setv maxN 0)
			(setv maxN (int (get args -1 -1)))) 
		(setv inputs (lfor n (thru 1 maxN) (hy.models.Symbol f"%{n}")))
		(return `(fn [~@inputs] ~expr)))

	(defmacro f> [lambda_def #* args]
		(return `((hy.R._fptk_local.fm ~lambda_def) ~@args)))

    (defmacro mapm [one_shot_fm #* args]
		(return `(map (hy.R._fptk_local.fm ~one_shot_fm) ~@args)))

    (defmacro lmapm [one_shot_fm #* args]
		(return `(list (map (hy.R._fptk_local.fm ~one_shot_fm) ~@args))))

    (defmacro filterm [one_shot_fm iterable]
		(return `(filter (hy.R._fptk_local.fm ~one_shot_fm) ~iterable)))

    (defmacro lfilterm [one_shot_fm iterable]
		(return `(list (filter (hy.R._fptk_local.fm ~one_shot_fm) ~iterable))))

; ________________________________________________________________________/ }}}2
; lns ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

	(defmacro lns [#* macro_args]
		;
		(setv args (list macro_args)) ; for mutations
		(for [[&i &arg] (enumerate args)]
			(cond ; Integer/String/Symbol
				  (or (= (type &arg) hy.models.Integer)  ; 1 -> [1]
					  (= (type &arg) hy.models.String)	 ; "str" -> ["str"]
					  (= (type &arg) hy.models.Symbol))  ; vrbl -> [vrbl]
				  (setv (get args &i) [&arg])
				  ; .attr -> attr
				  (_isDottedAttr &arg)
				  (setv (get args &i) (_extractDottedAttr &arg))
				  ; (-1) -> [(- 1)]
				  (_isNegIntegerExpr &arg)
				  (setv (get args &i) [&arg])
				  ; (mth> f 1) -> (call "f" 1)
				  (_isExprWithHeadSymbol &arg "mth>")
				  (setv (get args &i) `(call ~(str (_extractDottedAttr (get &arg 1)))
											~@(get &arg (slice 2 None))))
				  ; (mut> f 1) -> (call_mut "f" 1)
				  (_isExprWithHeadSymbol &arg "mut>")
				  (setv (get args &i) `(call_mut ~(str (_extractDottedAttr (get &arg 1)))
												~@(get &arg (slice 2 None))))))
		; process (dndr> ...):
		(setv last_arg (get args (- 1)))
		(cond (_isExprWithHeadSymbol last_arg "dndr>")
			 `(->  (. lens ~@(get args (slice 0 (- 1))))
				  ~(get last_arg (slice 1 None)))
			  (_isExprWithHeadSymbol last_arg "dndr>>")
			 `(->> (. lens ~@(get args (slice 0 (- 1))))
				  ~(get last_arg (slice 1 None)))
			  True
			 `(. lens ~@args)))

; ________________________________________________________________________/ }}}2
; &+ &+> l> l>= ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

	; compose lens, add setters/getters

	(defmacro &+ [#* macro_args]
		(setv lenses_ (butlast macro_args))
		(setv func	 (get macro_args (- 1)))
	   `(& ~@lenses_ (hy.R._fptk_local.lns ~func)))

	; compose lens, add setters/getters, apply

	(defmacro &+> [#* macro_args]
		(setv variable (get macro_args 0))
		(setv lenses   (butlast (rest macro_args)))
		(setv func	   (get macro_args (- 1)))
	   `((& ~@lenses (hy.R._fptk_local.lns ~func)) ~variable))

	; construct lens, apply:

	(defmacro l> [#* macro_args]
		(setv variable	  (get macro_args 0))
		(setv lenses_args (rest macro_args))
	   `((hy.R._fptk_local.lns ~@lenses_args) ~variable))

	(defmacro l>= [#* macro_args]
		(setv variable	  (get macro_args 0))
		(setv lenses_args (rest macro_args))
	   `(&= ~variable (hy.R._fptk_local.lns ~@lenses_args)))

; ________________________________________________________________________/ }}}2
; assertm, errortypeQ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

	(defmacro assertm [op arg1 arg2]
        (setv to_test `(~op ~arg1 ~arg2))
        (setv _test_expr (hy.repr `(~op ~arg1 ~arg2)))
        (setv _arg1 (hy.repr arg1))
        (setv _arg2 (hy.repr arg2))
        ;
        (setv _full_expr_result True)
       `(try (assert ~to_test False)
             True ; return
             (except [eFull Exception]
                     (print "Error in" ~_test_expr "|" (type eFull) ":" eFull)
                     (setv _outp eFull)
                     (try ~arg1
                          (print ">>" ~_arg1 "=" ~arg1)
                          (except [e1 Exception]
                                  (print ">> Can't calc" ~_arg1 "|" (type e1) ":" e1)))
                     (try ~arg2
                          (print ">>" ~_arg2 "=" ~arg2)
                          (except [e2 Exception]
                                  (print ">> Can't calc" ~_arg2 "|" (type e1) ":" e2)))
                                  (print)
                     eFull )))

	(defmacro gives_error_typeQ [expr error_type]
       `(try ~expr
             False
             (except [e Exception]
                     (= ~error_type (type e)))))

; ________________________________________________________________________/ }}}2


; _____________________________________________________________________________/ }}}1

