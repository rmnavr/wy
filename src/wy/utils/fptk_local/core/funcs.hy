
; Import (required for functions def) ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; underscored in order for «import *» not import them unwantedly
    
    (import  funcy      :as _funcy)
    (import  functools  :as _functools)
    (import  operator   :as _operator)

    (import  typing [List])     ; also re-imported in Typing, but hey
    (require wy.utils.fptk_local.core.from_hyrule [comment of])

; _____________________________________________________________________________/ }}}1
; Export ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; All (automatically)
    ; 
    ; Notice that funcs is not supposed to export macros,
    ; so having (require ... [of comment]) here is OK

; _____________________________________________________________________________/ }}}1

; [GROUP] APL: filtering ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (comment "py | base | filter | filter(function or None, iterable) -> filter object | when f=None, checks if elems are True")
    (import funcy [lfilter]) #_ "lfilter(pred, seq) -> List | funcy list version of extended filter"

    #_ "fltr1st(f, seq) -> Optional elem | returns first found element (or None)"
    (defn fltr1st [function iterable]
        "returns first found element (via function criteria), returns None if not found"
        (next (gfor &x iterable :if (function &x) &x) None))

    (import funcy [remove  :as reject])   #_ "reject(pred, seq)-> iterator | same as filter, but checks for False"
    (import funcy [lremove :as lreject]) #_ "lreject(pred, seq) -> List | list version of reject"

    #_ "without(items, seq) -> generator | subtracts items from seq (as a sets)"
    (defn without [items seq]
        "returns generator for seq with each item in items removed (does not mutate seq)"
        (_funcy.without seq #* items))

    #_ "lwithout(items, seq) -> list | list version of reject"
    (defn lwithout [items seq]
        "returns seq with each item in items removed (does not mutate seq)"
        (_funcy.lwithout seq #* items))

    (import funcy [takewhile]) #_ "takewhile([pred, ] seq) | yields elems of seq as long as they pass pred"
    (import funcy [dropwhile]) #_ "dropwhile([pred, ] seq) | mirror of takewhile"

    (import funcy [split      :as filter_split])  #_ "filter_split(pred, seq) -> passed, rejected |"
    (import funcy [lsplit     :as lfilter_split]) #_ "lfilter_split(pred,seq) -> passed, rejected | list version of filter_split"
    (import funcy [split_at   :as bisect_at])     #_ "bisect_at(n, seq) -> start, tail | len of start will = n, works only with n>=0"

    #_ "lbisect_at(n, seq) -> start, tail | list version of bisect_at, but also for n<0, abs(n) will be len of tail"
    (defn lbisect_at [n seq]
        " splits seq to start and tail lists (returns tuple of lists),
          when n>=0, len of start will be = n (or less, when len(seq) < n),
          when n<0, len of tail will be = n (or less, when len(seq) < abs(n))
        "
        (if (>= n 0)
            (_funcy.lsplit_at n seq)
            (_funcy.lsplit_at (max 0 (+ (len seq) n)) seq)))

    (import funcy [split_by   :as bisect_by])     #_ " bisect_by(pred, seq) -> taken, dropped | similar to (takewhile, dropwhile)"
    (import funcy [lsplit_by  :as lbisect_by])    #_ "lbisect_by(pred, seq) -> taken, dropped | list version of lbisect"

    ;; MASK SELECTION:

    (import itertools [compress :as mask_sel]) #_ "mask_sel('abc', [1,0,1]) -> iterator: 'a', 'c' | "

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
        (setv mask (list (_funcy.repeat 0 mask_len)))
        (for [&idx idxs] (setv (get mask &idx) 1))
        ;;
        (when bools (setv mask (_funcy.lmap (fn [it] (= True it)) mask)))
        (return mask))

; _____________________________________________________________________________/ }}}1
; [GROUP] APL: ranges-iterators-looping ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import itertools [count :as inf_range]) #_ "inf_range(start [, step]) | inf_range(10) -> generator: 10, 11, 12, ..."

    (import itertools [islice])              #_ "islice(iterable, start, stop[, step]) | list(islice(inf_range(10), 2)) == [10, 11]"  

    #_ "| list version of islice: lislice"
    (defn lislice [#* kwargs] "literally just list(lislice(...))" (list (islice #* kwargs)))

    (import itertools [cycle])               #_ "cycle(p) | cycle('AB') -> A B A B ..."

    #_ "lcycle(p, n) -> list | takes first n elems from cycle(p)"
    (defn lcycle [p n] "takes first n elems from cycle(p)" (lislice (cycle p) n))

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

; _____________________________________________________________________________/ }}}1
; [GROUP] APL: working with lists ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (comment "py | base | reversed | reversed(sequence) -> iterator |") 

    (import wy.utils.fptk_local.core.from_hyrule [flatten]) #_ "flatten(coll) | recursively flattens to the bottom"

    #_ "lreversed(sequence) | list version of reversed"
    (defn lreversed [sequence] (list (reversed sequence)))

    #_ "partition(n, seq, *, step=None, tail=False) -> generator | splits seq to lists of len n, tail=True will allow including fewer than n items"
    (defn partition [n seq * [step None] [tail False]]
        " splits seq to lists of len n,
          at step offsets apart (step=None defaults to n when not given),
          tail=False will allow fewer than n items at the end;
          returns generator"
        (cond (and (not tail) (is step None))
              (_funcy.partition n seq)
              (and (not tail) (not (is step None)))
              (_funcy.partition n step seq)
              (and tail (is step None))
              (_funcy.chunks n seq)
              (and tail (not (is step None)))
              (_funcy.chunks n step seq)))

    #_ "lpartition(n, seq, *, step=None, tail=False) -> List | simply list(partition(...))"
    (defn lpartition [n seq * [step None] [tail False]]
        " splits seq to lists of len n,
          at step offsets apart (step=None defaults to n when not given),
          tail=False will allow fewer than n items at the end;
          returns list of lists"
        (list (partition n seq :step step :tail tail)))

    (import funcy [partition_by])   #_ "partition_by(f, seq) -> iterator of iterators | splits when f(item) change" ;;
    (import funcy [lpartition_by])  #_ "lpartition_by(f,seq) -> list of lists | list(partition_by(...))" ;;

    (import funcy [group_by] ) #_ "group_by(f, seq) -> defaultdict(list) | groups elems of seq keyed by the result of f" ;;

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
          in the example below evenQ is function that gives True for even numbers,
          that is cuts will happen at elems=0
          #
                                                 #  keep_b merge_b
                                                 #  ------ -------
          lmulticut_by(evenQ, [0, 1, 0, 0, 1, 1, 0], True , True ) # -> [[0, 1], [0, 0, 1, 1], [0]]
          lmulticut_by(evenQ, [0, 1, 0, 0, 1, 1, 0], True , False) # -> [[0, 1], [0], [0, 1, 1], [0]]
          lmulticut_by(evenQ, [0, 1, 0, 0, 1, 1, 0], False, True ) # -> [[1], [1, 1]]
          lmulticut_by(evenQ, [0, 1, 0, 0, 1, 1, 0], False, False) # -> [[1], [], [1, 1], []]
        "
        (when (= (len seq) 0) (return []))
        (setv _newLists [])
        (for [&elem seq]
            (if (pred &elem)
                (_newLists.append [&elem])
                (if (= (len _newLists) 0)
                    (_newLists.append [&elem])
                    (. (_funcy.last _newLists) (append &elem)))))
        (when (not keep_border)
              (setv _newLists (_funcy.lmap (fn [it] (if (pred (get it 0))
                                                 (cut it 1 None)
                                                 it))
                                    _newLists)))
        (when merge_border
              (if keep_border
                  (do (setv single_borders_pos [])
                      (for [&i (range 0 (len _newLists))]
                           (setv cur_list (get _newLists &i))
                           (when (and (= (len cur_list) 1)
                                      (pred (get cur_list 0)))
                                 (single_borders_pos.append &i)))
                      (for [&i single_borders_pos]
                           (when (< &i (- (len _newLists) 1))
                                 (setv (get _newLists (+ &i 1)) (+ (get _newLists &i) (get _newLists (+ &i 1))))))
                      (setv others_pos (list (- (set (range 0 (len _newLists))) (set single_borders_pos))))
                      (when (in (- (len _newLists) 1) single_borders_pos)
                            (others_pos.append (- (len _newLists) 1)))
                      (setv _newLists (lfor &n others_pos (get _newLists &n))))
                  (setv _newLists (lwithout [[]] _newLists))))
        (return _newLists))

; _____________________________________________________________________________/ }}}1
; [GROUP] APL: counting ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    #_ "count_occurrences(elem, seq) -> int | rename of list.count method"
    (defn count_occurrences [elem seq] (seq.count elem))

; _____________________________________________________________________________/ }}}1

; [GROUP] Benchmarking ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import time [time :as cur_time]) #_ "cur_time() | gets current time in seconds"

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
        (when fresh_run (setv (get last_T 0) None))
        (setv _time_getter hy.I.time.perf_counter)
        (setv curT (_time_getter))
        ;;
        (if (=  (get last_T 0) None)
            (do (setv (get last_T 0) curT)
                (print "[ Timer started ]" #* args))
            (do (setv dT (- curT (get last_T 0)))
                (setv (get last_T 0) curT)
                (print f"[dT = {dT :.6f} s]" #* args))))

; _____________________________________________________________________________/ }}}1

; [GROUP] FP: Control flow ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (comment "hy | base | if   | (if check true false)          | ")
    (comment "hy | base | cond | (cond check1 do1 ... true doT) | ")

; _____________________________________________________________________________/ }}}1
; [GROUP] FP: Composition ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import  funcy  [identity])      #_ "identity(n) -> n"

    #_ "constantly(val) | constantly(30) is FUNCTION that always return val no matter the arguments"
    (defn constantly [value] (fn [#* args #** kwargs] value))

    (import  funcy  [partial])      #_ "| applicator"
    (import  funcy  [rpartial])     #_ "| applicator"

    (import  funcy  [compose])      #_ "compose(f1, f2, ..., fn) | = f1(f2(..fn(***))) ; applicator"
    (import  funcy  [rcompose])     #_ "rcompose(f1, f2, ..., fn) | = fn(..(f2(f1(***)))) ; applicator"

    (import  funcy  [ljuxt])        #_ "ljuxt(*fs) | = [f1, f2, ...](***) ; applicator" ;;

    #_ "pflip(f, a) | applicator for function f(a,b) of 2 args; example: pflip(div, 4)(1) == 0.25"
    (defn pflip
        [f a]
        " creates partial applicator for f(a,b) with args a and b flipped;
          example usage: pflip(div, 4)(1) == div(1, 4) == 0.25
        "
        (fn [%x] (f %x a)))

    #_ "flip(f, a, b) = f(b, a) | calls f with flipped args"
    (defn flip [f a b] "flip(f, a, b) = f(b, a)" (f b a))

; _____________________________________________________________________________/ }}}1
; [GROUP] FP: threading ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (comment "py | base | zip | zip(*iterables) -> zip object |")

    #_ "lzip(*iterables) -> List | literally just list(zip(*iterables))"
    (defn lzip [#* iterables] (list (zip #* iterables)))

    (comment "py | base | map | map(func, *iterables) -> map object |")
    (import funcy     [lmap])       #_ "lmap(f, *seqs) -> List | list version of map"

    (import itertools [starmap])    #_ "starmap(function, iterable) |" ;;

    #_ "lstarmap(function, iterable) -> list | list version of starmap"
    (defn lstarmap [function iterable]
        "literally just list(starmap(function, iterable))"
        (list (starmap function iterable)))

    (import functools [reduce])             #_ "reduce(function, sequence[, initial]) -> value | theory: reduce + monoid = binary-function for free becomes n-arg-function"
    (import funcy     [reductions])         #_ "reductions(f, seq [, acc]) -> generator | returns sequence of intermetidate values of reduce(f, seq, acc)"
    (import funcy     [lreductions])        #_ "lreductions(f, seq [, acc]) -> list | list version of reductions"
    (import funcy     [sums])               #_ "sums(seq [, acc]) -> generator | reductions with addition function"
    (import funcy     [lsums])              #_ "lsums(seq [, acc]) -> list | list version of sums"
    (import math      [prod :as product])   #_ "product(iterable, /, *, start=1) | product([2, 3, 5]) = 30"

; _____________________________________________________________________________/ }}}1
; [GROUP] FP: n-applicators ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    #_ "nested(n, f) | applicator f(...(f(***)))"
    (defn nested [n f]
        " constructs function f(f(f(...f))), where nesting is n times deep "
        (compose #* (* n [f])))

    #_ "apply_n(n, f, *args, **kwargs) | f(f(f(...f(*args, **kwargs))"
    (defn apply_n [n f #* args #** kwargs]
        " applies f to args and kwargs,
          than applies f to result of prev application,
          and this is repeated in total for n times,

          n=1 is simply f(args, kwargs)
        "
        ((compose #* (* n [f])) #* args #** kwargs))

; _____________________________________________________________________________/ }}}1

; [GROUP] Getters: idxs and keys ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ;; dub basics:

        ;; idxs, keys, attrs:
        (comment "hy     | macro | .     | (. xs [n1] [n2] ...) -> xs[n1][n2]... | throws error when not found")

        ;; idxs, keys:
        (comment "hy     | macro | get   | (get xs n #* keys) -> xs[n][key1]... | throws error when not found")
        (import wy.utils.fptk_local.core.from_hyrule [assoc]) #_ "assoc(xs, k1, v1, k2, v2, ...) -> None | ≈ (setv (get xs k1) v1 (get xs k2) v2) ; also possible: (assoc xs :x 1)"

        ;; idxs:
        (import funcy [nth])        #_ "nth(n, seq) -> Optional elem | 0-based index; works also with dicts"
        (comment "py     | base  | slice | (slice start end step) | returns empty list when not found ")
        (comment "hy     | macro | cut   | (cut xs start end step) -> (get xs (slice start end step)) -> List | returns empty list when none found")

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

; _____________________________________________________________________________/ }}}1
; [GROUP] Getters: one based index ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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
                    (if (and (= (type &n) int) (>= &n 1))
                        (- &n 1)
                        &n)))) ;; this line covers both &n<0 and &n=dict_key        
        (return (get seq #* _ns_plus1)))

    #_ "nth_(n, seq) -> Optional elem | same as nth, but with 1-based index; will return None for n=0"
    (defn nth_ [n seq] 
        " same as nth, but with 1-based index,
          will throw error for n=0,
          will return None if elem not found (just like nth)
        "
        (when (= (type seq) dict) (return (nth n seq)))
        (when (=  n 0) (return None))
        (when (>= n 1) (return (nth (- n 1) seq)))
        (return (nth n seq))) ;; this line covers both n<0 and n=dict_key

    #_ "slice_(start, end, step=None) | similar to slice, but with 1-based index; will throw error for start=0 or end=0"
    (defn slice_
        [ start
          end
          [step None]
        ]
        " similar to py slice, but:
          - has 1-based index
          - will throw error when start=0 or end=0
        "
        (cond (>= start 1) (setv _start (- start 1))
              (<  start 0) (setv _start start)
              (=  start 0) (raise (IndexError "start=0 can't be used with 1-based getter"))
              True         (raise (IndexError "start in 1-based getter is probably not an integer")))
        ;;
        (cond (=  end -1) (setv _end None)
              (>= end  1) (setv _end end)
              (<  end -1) (setv _end (+ end 1))
              (=  end  0) (raise (IndexError "end=0 can't be used with 1-based getter"))
              True        (raise (IndexError "end in 1-based getter is probably not an integer")))
        (return (slice _start _end step)))

    #_ "cut_(seq, start, end, step=None) -> List | similar to cut, but with 1-based index; will throw error for start=0 or end=0"
    (defn cut_ [seq start end [step None]]
        " same as hy cut macro, but with 1-based index:
          - will throw error when start=0 or end=0
        "
        (get seq (slice_ start end step)))

    #_ "range_(start, end=None, step=1) -> List | same as range, but with 1-based index"
    (defn range_ [start [end None] [step 1]]
        (when (is end None)
              (setv [start end] [0 start]))
        (range start (+ end (if (> step 0) 1 -1)) step))

    #_ "lrange_(start, end, step=1) -> List | range including both ends when possible, also works on fractionals"
    (defn lrange_ [start end [step 1]]
        "range including both ends when possible,
         also works on fractionals"
        ;; integers
        (when (and (= (type start) int)
                   (= (type end) int)
                   (= (type step) int))
              (return (list (range_ start end step))))
        ;;
        (when (= step 0) (raise (ZeroDivisionError "step must be != 0")))
        (setv n (round (py "(end-start)/step + 1")))
        ;; floats for start<end
        (when (< start end)
              (setv _end (+ end (abs (/ start 1E13))))
              (return
                  (lfor &i (range_ 0 n)
                        :setv candidate (+ start (* &i step))
                        :if   (<= candidate _end)
                        candidate)))
        ;; floats for start=end
        (when (= start end) (return [start]))
        ;; floats for start>end
        (setv _end (- end (abs (/ start 1E13))))
        (return
            (lfor &i (range_ 0 n) ;; here n<0
                  :setv candidate (+ start (* &i step))
                  :if   (>= candidate _end)
                  candidate)))

; _____________________________________________________________________________/ }}}1
; [GROUP] Getters: keys and attrs ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ;; attrs
    (comment "py | base | getattr | getattr(object, name[, default]) -> value | arg name should be given as str")

    ;; idxs, keys
    (import  funcy  [pluck])            #_ "pluck(key, mappings) -> generator | gets same key (or idx) from every mapping, mappings can be lists of lists/dicts/etc."
    (import  funcy  [lpluck])           #_ "lpluck(key, mappings) -> list | "

    ;; attrs
    (import  funcy  [pluck_attr])       #_ "pluck_attr(attr, objects) -> generator | attr should be given as str" ;;
    (import  funcy  [lpluck_attr])      #_ "lpluck_attr(attr, objects) -> list | list version of pluck_attr" ;;

; _____________________________________________________________________________/ }}}1

; [GROUP] IO ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import os.path [exists :as file_existsQ]) #_ "file_existsQ(filename) | also works on folders" ;;
    (import os.path [isfile :as fileQ])        #_ "fileQ(filename) |"
    (import os.path [isdir  :as dirQ])         #_ "dirQ(filename) |"

    #_ "read_file(file_name, encoding='utf-8') -> str | returns whole file content"
    (defn read_file
        [ #^ str file_name
          #^ str [encoding "utf-8"]
        ]
        "returns whole file content"
        (with [file (open file_name "r" :encoding encoding)] (setv outp (file.read)))
        (return outp))

    #_ "write_file(text, file_name, mode='w', encoding='utf-8') | modes: 'w' - (over)write, 'a' - append, 'x' - exclusive creation"
    (defn write_to_file
        [ #^ str text
          #^ str file_name
          #^ str [mode "w"]
          #^ str [encoding "utf-8"]
        ]
        " writes text to file_name;
          modes:
          - 'w' - (over)write
          - 'a' - append
          - 'x' - exclusive creation
          - ...
          - see more at help(open)"
        (with [file (open file_name mode :encoding encoding)] (file.write text)))

; _____________________________________________________________________________/ }}}1

; [GROUP] Math and logic: Basic math ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import operator  [neg])        #_ "neg(n) | = -1 * n"
    (import operator  [mod])        #_ "mod(5, 2) | = 1"

    ;;

    (import math [floor])  #_ "| floor(1.9) = 1"
    (import math [ceil])   #_ "| ceil(1.1) = 2"

    #_ "inc(n) | = n + 1"
    (defn dec [n] (- n 1))

    #_ "dec(n) | = n - 1"
    (defn inc [n] (+ n 1))

    #_ "sign(n) | will give 0 for n=0"
    (defn sign [x]
      (cond
        (< x 0) -1
        (> x 0)  1
        (= x 0)  0
        True     (raise TypeError)))

    #_ "clip(x, lower, upper) | clips x to fit in lower <= x <= upper limit"
    (defn clip [x lower upper]
        "clips x to fit in lower <= x <= upper limit"
        (when (< upper lower)
              (raise (ValueError "can't have lower>upper")))
        (max lower (min x upper)))

    #_ "half(x) | = x/2"
    (defn half       [x] "half(x) = x / 2" (/ x 2))

    #_ "double(x) | = x*2"
    (defn double     [x] "double(x) = x * 2" (* x 2))

    #_ "squared(x) | = pow(x,2)"
    (defn squared    [x] "squared(x) = pow(x, 2)" (pow x 2))

    #_ "reciprocal(x) | = 1/x ; throws error for x=0"
    (defn reciprocal [x] "reciprocal(x) = 1 / x" (/ 1 x))

    (import math [sqrt])    #_ "sqrt(n) | = √n"
    (import math [dist])    #_ "dist(p, q) -> float | ≈ √((px-qx)² + (py-qy)² ...)"
    (import math [hypot])   #_ "hypot(*coordinates) | = √(x² + y² + ...)" ;;

    #_ "normalize(xs) -> xs | will throw error for zero-len vector"
    (defn normalize [xs]
        " devides each coord of vector to vectors norm,
          example: norm of [1, 2, 3] = sqrt(1 + 4 + 9) = sqrt(14) ~= 3.74,
          so will return [1/3.74, 2/3.74, 3/3.74]
          ---
          will throw error for norm == 0"
        (setv norm (hypot #* xs))
        (if (!= norm 0)
            (return (list (map (fn [%1] (div %1 norm)) xs)))
            (raise (ValueError "Can't normalize zero vector"))))

    (import math [exp]) #_ "exp(x) |"

    (import math [log]) #_ "log(x, base=math.e) |" ;;

    #_ "ln(x) | = math.log(x, math.e) ; coexists with log for clarity"
    (defn ln [x] (log x))

    (import math [log10])  #_ "log10(x) |"

    ;; checks:
    (import funcy [even :as evenQ]) #_ "evenQ(x) |"
    (import funcy [odd  :as oddQ])  #_ "oddQ(x)  |"

    #_ "zeroQ(x) | checks directly via (= x 0)"
    (defn zeroQ     [x] "checks literally if x == 0" (= x 0))

    #_ "negativeQ(x) | checks directly via (< x 0)"
    (defn negativeQ [x] "checks literally if x < 0" (< x 0))

    #_ "positiveQ(x) | checks directly via (> x 0)"
    (defn positiveQ [x] "checks literally if x > 0" (> x 0))

; _____________________________________________________________________________/ }}}1
; [GROUP] Math and logic: Trigonometry ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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

; _____________________________________________________________________________/ }}}1
; [GROUP] Math and logic: Base operators to functions ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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

    #_ "gt0(x) | checks for x > 0"
    (defn gt0 [x] "checks for x > 0" (> x 0))

    #_ "geq0(x) | x >= 0"
    (defn geq0 [x] "checks for x >= 0" (>= x 0))

    #_ "lt0(x) | checks for x < 0"
    (defn lt0 [x] "checks for x < 0" (< x 0))

    #_ "leq0(x) | x <= 0"
    (defn leq0 [x] "checks for x <= 0" (<= x 0))

    #_ "minus(x, y) = x - y |"
    (defn minus [x y] "minux(x, y) = x - y" (- x y))


; _____________________________________________________________________________/ }}}1
; [GROUP] Math and logic: Dunders and Monoids ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ;; =========================================================================
    ;; dunders
    ;; - python behaves like so:
    ;; - (*) = 1, (* 3) = 3
    ;; - (+) = 0, (+ 3) = 3
    ;; - (+ "") = error, (+ []) = error

        #_ "dmul(*args) = arg1 + arg2 + ... | 'dunder mul', '*' operator as a function"
        (defn dmul [#* args]
            "dmul(a1, a2, ...) = a1 * a2 * ...
             dunder mul, '*' operator as a function"
            (* #* args))

        #_ "dadd(*args) = arg1 + arg2 + ... | 'dunder add', '+' operator as a function"
        (defn dadd [#* args]
            "dadd(a1, a2, ...) = a1 + a2 + ...
             dunder add, '+' operator as a function"
            (+ #* args))

    ;; renames

        #_ "lmul(*args) = arg1 * arg2 * ... | rename of * operator, underlines usage for list"
        (defn lmul [#* args]
            "lmul(list, n, ...) = list * n * ...
             rename of * operator, can be used to underline usage on list"
            (* #* args))

        #_ "smul(*args) = arg1 * arg2 * ... | rename of * operator, underlines usage for string"
        (defn smul [#* args]
            " smul(s, n, ...) = s * n * ...
              rename of * operator, can be used to underline usage on string"
            (* #* args))

    ;; monoids

        #_ "mul(*args) | multiplication as a monoid (will not give error when used with 0 or 1 args)"
        (defn mul [#* args]
            " mul(a1, a2, ...) = 1 * a1 * a2 * ...
              multiplication as a monoid with identity = 1,
              can be used with 0 or 1 arg"
            (_functools.reduce _operator.mul args 1))

        #_ "plus(*args) | addition as a monoid (will not give error when used with 0 or 1 args)"
        (defn plus [#* args]
            " plus(a1, a2, ...) = 0 + a1 + a2 + ...
              addition as a monoid with identity = 0 "
            (_functools.reduce (fn [%s1 %s2] (+ %s1 %s2)) args 0))

        #_ "sconcat(*args) | string concantenation as a monoid (will not give error when used with 0 or 1 args)"
        (defn sconcat [#* args]
            " sconcat(s1, s2, ...) = '' + s1 + s2 + ...
              string concantenation as a monoid with identity = '',
              can be used with 0 or 1 args"
            (_functools.reduce (fn [%s1 %s2] (+ %s1 %s2)) args ""))

        ;; lconcat (list on itertools.chain) is a monoid on lists too

; _____________________________________________________________________________/ }}}1
; [GROUP] Math and logic: Logic checks ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    #_ "fnot(f, *args, **kwargs) | = not(f(*args, **kwargs)) "
    (defn fnot [f #* args #** kwargs]
        "fnot(f, *args, **kwargs) = not(f(*args, **kwargs))"
        (not (f #* args #** kwargs)))

    #_ "eq_any(x, values) | = (or (eq x value1) (eq x value2) ...)"
    (defn eq_any [x values]
        "eq_any(x, [v1, v2, ...]) = or(eq(x, v1), eq(x, v2), ...)"
        (or #* (list (map (fn [it] (= x it)) values))))

    #_ "on(f, check, x, y) | example: (on len eq xs ys) -> (eq (len xs) (len yx))"
    (defn on [f check x y]
        "on(f, check, x, y) = check(f(x), f(y))
         inspired by Haskell's 'on' function"
        (check (f x) (f y)))

    #_ "all_fs(fs, *args, **kwargs) | checks if all f(*args, **kwargs) are True"
    (defn all_fs [fs #* args #** kwargs]
        "all_fs([f1, f2, ...], *args, **kwargs) = and(f1(*args, **kwargs), f2, ...)"
        (and #* (lfor &f fs (&f #* args #** kwargs))))

    #_ "any_fs(fs, *args, **kwargs) | checks if any of f(*args, **kwargs) is True"
    (defn any_fs [fs #* args #** kwargs]
        "all_fs([f1, f2, ...], *args, **kwargs) = or(f1(*args, **kwargs), f2, ...)"
        (or #* (lfor &f fs (&f #* args #** kwargs))))

    #_ "trueQ(x) | checks directly via (= x True)"
    (defn trueQ [x] "checks literally if x == True" (= x True))

    #_ "falseQ(x) | checks directly via (= x False)"
    (defn falseQ [x] "checks literally if x == False" (= x False))

    #_ "oflenQ(n, xs) | checks directly via (= (len xs) n)"
    (defn oflenQ [n xs] "checks literally if len(xs) == n" (= (len xs) n))

    #_ "zerolenQ(xs) | checks directly via (= (len xs) 0)"
    (defn zerolenQ [xs] "checks literally if len(xs) == 0" (= (len xs) 0))

; _____________________________________________________________________________/ }}}1
; [GROUP] Math and logic: Random ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import random    [choice])                 #_ "choice(seq) -> Elem | throws error for empty list"
    (import random    [randint])                #_ "randint(a, b) -> int | returns random integer in range [a, b] including both end points"
    (import random    [uniform :as randfloat])  #_ "randfloat(a, b) -> float | range is [a, b) or [a, b] depending on rounding"
    (import random    [random :as rand01])      #_ "rand01() -> float | generates random number in interval [0, 1) "

    ;; shuffle — is mutating

; _____________________________________________________________________________/ }}}1

; [GROUP] Misc ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import pprint [pprint]) #_ "| standard python pprint function"

    #_ "lprint(seq, sep=None) | prints every elem of seq on new line"
    (defn lprint [seq [sep None]]
          " essentially list(map(print, seq)) ;
            with sep='---' (or some other) will print sep between seq elems
          "
          (if (= sep None)
              (_funcy.lmap print seq)
              (_funcy.lmap print (_funcy.interpose sep seq)))
          (return None))

; _____________________________________________________________________________/ }}}1

; [GROUP] Strings: Basics ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    #_ "strlen(text) | rename of len, underlines usage on strings"
    (defn strlen [text]
        "rename of len, underlines usage on strings"
        (len text))

    #_ "str_join(ss, sep='') | rearrangement of funcy.str_join, ss is seq of strings"
    (defn str_join [ss [sep ""]]
        "str_join(['1', '2', '3'], '-') = '1-2-3'"
        (if (bool sep)
            (_funcy.str_join sep ss)
            (_funcy.str_join ss)))

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

    #_ "enlengthen(target_len, string, char=' ', on_tail=True) | adds char to string until target_len reached"
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
                          (return (cut string (- (len string) target_len) (+ (len string) 1)))))
        ;;
        (setv n_required (max 0 (- target_len (len string))))
        (if on_tail
            (setv outp (+ string (cut (* char n_required) 0 (- target_len (len string)))))
            (setv outp (+ (cut (* char n_required) 0 (- target_len (len string))) string)))
        (return outp))

; _____________________________________________________________________________/ }}}1
; [GROUP] Strings: Regex ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import re      [sub :as re_sub])       #_ "re_sub(rpattern, replacement, string, count=0, flags=0) |"
    (import re      [split :as re_split])   #_ "re_split(rpattern, string) |"
    (import funcy   [re_find])              #_ "re_find(rpattern, string, flags=0) -> str| returns first found"
    (import funcy   [re_test])              #_ "re_test(rpattern, string, ...) -> bool | tests if string has match (not neccessarily whole string)"
    (import funcy   [re_all])               #_ "re_all(rpattern, string, ...) -> List | returns tuples if groups requested like via r'a(b)(c)d'"

; _____________________________________________________________________________/ }}}1

; [GROUP] Typing: Base ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import enum   [Enum])
    (import typing [List])
    (import typing [Tuple])
    (import typing [TypedDict])
    (import typing [Dict])
    (import typing [Union])
    (import typing [Generator])
    (import typing [Any])
    (import typing [Optional])
    (import typing [Callable])
    (import typing [Literal])
    (import typing [Type])
    (import typing [TypeVar])
    (import typing [Generic])

    ;; type checks:

    (import funcy [isnone  :as noneQ])
    (import funcy [notnone :as notnoneQ]) ;;

    #_ "oftypeQ(tp, x) | checks directly via (= (type x) tp)"
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
        (= (type x) str))

    #_ "dictQ(x) | checks literally if type(x) == dict"
    (defn dictQ [x]
        "checks literally if type(x) == dict"
        (= (type x) dict))

    (import funcy [is_list  :as listQ ])    #_ "listQ(value)     | checks if value is list"
    (import funcy [is_tuple :as tupleQ])    #_ "tupleQ(value)    | checks if value is tuple"
    (import funcy [is_set   :as setQ])      #_ "setQ(value)      | checks if value is set"
    (import funcy [is_iter  :as iteratorQ]) #_ "iteratorQ(value) | checks if value is iterator"
    (import funcy [iterable :as iterableQ]) #_ "iterableQ(value) | checks if value is iterable"

; _____________________________________________________________________________/ }}}1
; [GROUP] Typing: Dataclasses ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import dataclasses [dataclass])
    (import dataclasses [replace :as upd_field ]) #_ "| non-mutating"

; _____________________________________________________________________________/ }}}1

