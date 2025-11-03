
; This is local version of github.com/rmnavr/fptk lib.
; It's purpose is to have stable fptk inside other projects until fptk reaches stable version.
; This file was generated from local git version: 0.4.1.dev4

; [F] flow ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

; Import and export ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    ; ///fptk_local: removed export statement///

    (require hyrule [comment])

; ________________________________________________________________________/ }}}2

; [GROUP] FP: Control flow ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (comment "hy | base | if   | (if check true false)          | ")
    (comment "hy | base | cond | (cond check1 do1 ... true doT) | ")

    (require hyrule [case])   
    (require hyrule [branch])
    (require hyrule [unless])
    (require hyrule [lif])

; ________________________________________________________________________/ }}}2
; [GROUP] FP: Composition ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (import  hyrule [constantly])    #_ "constantly(val) | constantly(30) is FUNCTION that always return val no matter the arguments"
    (import  funcy  [identity])      #_ "identity(n) -> n"

    (require hyrule [->])
    (require hyrule [->>])
    (require hyrule [as->])
    (require hyrule [doto])         #_ "| mutating "

    (import  funcy  [partial])      #_ "| applicator"
    (import  funcy  [rpartial])     #_ "| applicator"
    ; ///fptk_local: removed import of fptk._macros///     #_ "| aplicator, pipe of partials"

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

; ________________________________________________________________________/ }}}2
; [GROUP] FP: threading ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    ; ///fptk_local: removed import of fptk._macros///       #_ "(fm (* it 3)) | anonymous function that accepts args in form of 'it' or '%1', '%2', ... '%9'"
    ; ///fptk_local: removed import of fptk._macros///       #_ "(f> (* %1 %2) 3 4) | calculate anonymous function (with fm-syntax)"

    (comment "py | base | zip | zip(*iterables) -> zip object |")
    
    #_ "lzip(*iterables) -> List | literally just list(zip(*iterables))"
    (defn lzip [#* iterables] (list (zip #* iterables)))


    (comment "py | base | map | map(func, *iterables) -> map object |")
    (import funcy     [lmap])       #_ "lmap(f, *seqs) -> List | list version of map"

    ; ///fptk_local: removed import of fptk._macros///     #_ "| same as map, but expects fm-syntax for func"
    ; ///fptk_local: removed import of fptk._macros///    #_ "| same as lmap, but expects fm-syntax for func"

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

; ________________________________________________________________________/ }}}2
; [GROUP] FP: n-applicators ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (require hyrule [do_n])     #_ "(do_n   n #* body) -> None | expands to ~ (do body body body ...)"
    (require hyrule [list_n])   #_ "(list_n n #* body) -> List |"

    #_ "nested(n, f) | applicator f(...(f(***)))"
    (defn nested [n f]
        " constructs function f(f(f(...f))), where nesting is n times deep "
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


; _____________________________________________________________________________/ }}}1
; [F] apl ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

; Import/Export ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    ; ///fptk_local: removed export statement///

    (require hyrule [comment of])
    (import  hyrule [dec inc assoc])
    (import  typing [List])
    (import  funcy  [repeat    :as funcy_repeat])
    (import  funcy  [without   :as funcy_without])
    (import  funcy  [lwithout  :as funcy_lwithout])
    (import  funcy  [interpose :as funcy_interpose])
    (import  funcy  [lsplit_at :as funcy_lsplit_at])
    (import  funcy  [partition :as funcy_partition])
    (import  funcy  [chunks    :as funcy_chunks])
    (import  funcy  [last lmap])

; ________________________________________________________________________/ }}}2

; [GROUP] APL: filtering ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (comment "py | base | filter | filter(function or None, iterable) -> filter object | when f=None, checks if elems are True")
    (import funcy [lfilter]) #_ "lfilter(pred, seq) -> List | funcy list version of extended filter"
    ; ///fptk_local: removed import of fptk._macros///  #_ "(filterm f xs) | same as filter, but expects fm-syntax for func"
    ; ///fptk_local: removed import of fptk._macros/// #_ "(lfilterm f xs) | list version of lfilterm"

    #_ "fltr1st(f, seq) -> Optional elem | returns first found element (or None)"
    (defn fltr1st [function iterable]
        "returns first found element (via function criteria), returns None if not found"
        (next (gfor &x iterable :if (function &x) &x) None))

    (import funcy [remove  :as reject])   #_ "reject(pred, seq)-> iterator | same as filter, but checks for False"
    (import funcy [lremove :as lreject]) #_ "lreject(pred, seq) -> List | list version of reject"

    #_ "without(items, seq) -> generator | subtracts items from seq (as a sets)"
    (defn without [items seq]
        "returns generator for seq with each item in items removed (does not mutate seq)"
        (funcy_without seq #* items))

    #_ "lwithout(items, seq) -> list | list version of reject"
    (defn lwithout [items seq]
        "returns seq with each item in items removed (does not mutate seq)"
        (funcy_lwithout seq #* items))

    (import funcy [takewhile]) #_ "takewhile([pred, ] seq) | yields elems of seq as long as they pass pred"
    (import funcy [dropwhile]) #_ "dropwhile([pred, ] seq) | mirror of dropwhile"

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
            (funcy_lsplit_at n seq)
            (funcy_lsplit_at (max 0 (+ (len seq) n)) seq)))

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
        (setv mask (list (funcy_repeat 0 mask_len)))
        (for [&idx idxs] (assoc mask &idx 1))
        ;;
        (when bools (setv mask (lmap (fn [it] (= True it)) mask)))
        (return mask))

; ________________________________________________________________________/ }}}2
; [GROUP] APL: iterators and looping ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (import itertools [islice])              #_ "islice(iterable, stop), islice(iterable, start, stop[, step]) | list(islice(inf_range(10), 2)) == [10, 11]"  
    (import itertools [count :as inf_range]) #_ "inf_range(start [, step]) | inf_range(10) -> generator: 10, 11, 12, ..."
    (import itertools [cycle])               #_ "cycle(p) | cycle('AB') -> A B A B ..."
    (import itertools [repeat])              #_ "repeat(elem [, n]) | repeat(10,3) -> 10 10 10" 

    #_ "| list version of islice: lislice"
    (defn lislice [#* kwargs] "literally just list(lislice(...))" (list (islice #* kwargs)))

    #_ "lcycle(p, n) -> list | takes first n elems from cycle(p)"
    (defn lcycle [p n] "takes first n elems from cycle(p)" (lislice (cycle p) n))

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

    (import hyrule [flatten])   #_ "flatten(coll) | flattens to the bottom, non-mutating" ;;

    #_ "lprint(seq, sep=None) | prints every elem of seq on new line"
    (defn lprint [seq [sep None]]
          " essentially list(map(print, seq)) ;
            with sep='---' (or some other) will print sep between seq elems
          "
          (if (= sep None)
              (lmap print seq)
              (lmap print (funcy_interpose sep seq)))
          (return None))

    (comment "py | base | reversed | reversed(sequence) -> iterator |") 

    #_ "lreversed(sequence) | list version of reversed"
    (defn lreversed [sequence] (list (reversed sequence)))

    #_ "partition(n, seq, *, step=None, tail=False) -> generator | splits seq to lists of len n, tail=True will allow including fewer than n items"
    (defn partition [n seq * [step None] [tail False]]
        " splits seq to lists of len n,
          at step offsets apart (step=None defaults to n when not given),
          tail=False will allow fewer than n items at the end;
          returns generator"
        (cond (and (not tail) (is step None))
              (funcy_partition n seq)
              (and (not tail) (not (is step None)))
              (funcy_partition n step seq)
              (and tail (is step None))
              (funcy_chunks n seq)
              (and tail (not (is step None)))
              (funcy_chunks n step seq)))

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
        (for [&elem seq]
            (if (pred &elem)
                (_newLists.append [&elem])
                (if (= (len _newLists) 0)
                    (_newLists.append [&elem])
                    (. (last _newLists) (append &elem)))))
        (when (not keep_border)
              (setv _newLists (lmap (fn [it] (if (pred (get it 0))
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
                           (when (< &i (dec (len _newLists)))
                                 (setv (get _newLists (inc &i)) (+ (get _newLists &i) (get _newLists (inc &i))))))
                      (setv others_pos (list (- (set (range 0 (len _newLists))) (set single_borders_pos))))
                      (when (in (dec (len _newLists)) single_borders_pos)
                            (others_pos.append (dec (len _newLists))))
                      (setv _newLists (lfor &n others_pos (get _newLists &n))))
                  (setv _newLists (lwithout [[]] _newLists))))
        (return _newLists))

; ________________________________________________________________________/ }}}2
; [GROUP] APL: counting ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    #_ "count_occurrences(elem, seq) -> int | rename of list.count method"
    (defn count_occurrences [elem seq] (seq.count elem))

; ________________________________________________________________________/ }}}2


; _____________________________________________________________________________/ }}}1
; [F] getters ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

; Import and Export ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    ; ///fptk_local: removed export statement///

    (require hyrule [comment])
    (import  hyrule [dec inc])

; ________________________________________________________________________/ }}}2

    ;; idxs
    ;; keys
    ;; attrs

; [GROUP] Getters: idxs and keys ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    ;; dub basics:

        ;; idxs, keys, attrs:
        (comment "hy     | macro | .     | (. xs [n1] [n2] ...) -> xs[n1][n2]... | throws error when not found")

        ;; idxs, keys:
        (comment "hy     | macro | get   | (get xs n #* keys) -> xs[n][key1]... | throws error when not found")

        ;; idxs:
        (import funcy [nth])        #_ "nth(n, seq) -> Optional elem | 0-based index; works also with dicts"
        (comment "py     | base  | slice | (slice start end step) | returns empty list when not found ")
        (comment "hy     | macro | cut   | (cut xs start end step) -> (get xs (slice start end step)) -> List | returns empty list when none found")

        (import  hyrule [assoc])  #_ "assoc(xs, k1, v1, k2, v2, ...) -> None | ≈ (setv (get xs k1) v1 (get xs k2) v2) ; also possible: (assoc xs :x 1)"
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

; ________________________________________________________________________/ }}}2
; [GROUP] Getters: one based index ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (import hyrule [thru :as range_])      #_ "range_(start, end=None, step=1) -> List | same as range, but with 1-based index"

    #_ "lrange_(start, end=None, step=1) -> List | list version of range_"
    (defn lrange_ [start [end None] [step 1]]
        (list (range_ start end step)))

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
                        (dec &n)
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
        (when (>= n 1) (return (nth (dec n) seq)))
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

    #_ "cut_(seq, start, end, step=None) -> List | similar to cut, but with 1-based index; will throw error for start=0 or end=0"
    (defn cut_ [seq start end [step None]]
        " same as hy cut macro, but with 1-based index:
          - will throw error when start=0 or end=0
        "
        (get seq (slice_ start end step)))

; ________________________________________________________________________/ }}}2
; [GROUP] Getters: keys and attrs ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    ;; attrs
    (comment "py | base | getattr | getattr(object, name[, default]) -> value | arg name should be given as str")
    ; ///fptk_local: removed import of fptk._macros///   #_ "(getattrm Object 'attr') (getattrm Object .attr) | accepts fptk-style .attr syntax"

    ;; idxs, keys
    (import  funcy  [pluck])            #_ "pluck(key, mappings) -> generator | gets same key (or idx) from every mapping, mappings can be lists of lists/dicts/etc."
    (import  funcy  [lpluck])           #_ "lpluck(key, mappings) -> list | "

    ;; attrs
    (import  funcy  [pluck_attr])       #_ "pluck_attr(attr, objects) -> generator | attr should be given as str" ;;
    (import  funcy  [lpluck_attr])      #_ "lpluck_attr(attr, objects) -> list | list version of pluck_attr" ;;

    ;; idxs, keys and attrs
    ; ///fptk_local: removed import of fptk._macros///     #_ "(pluckm n xs) (pluckm key ys) (pluckm .attr zs) | accepts fptk-style .arg syntax"
    ; ///fptk_local: removed import of fptk._macros///    #_ "| list version of pluckm"

; ________________________________________________________________________/ }}}2


; _____________________________________________________________________________/ }}}1
; [F] typing ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; ///fptk_local: removed export statement///

; [GROUP] Typing: Base ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (require hyrule [of])         #_ "| example: (of List int) which is equiv to py-code: List[int]"
    ; ///fptk_local: removed import of fptk._macros///  #_ "| example: (f:: int -> int => (of Tuple int str)) -> Callable[[int, int], Tuple[int,str]]"
    ; ///fptk_local: removed import of fptk._macros///  #_ "| define function with signature; example: (def:: int -> int -> float fdivide [x y] (/ x y))"

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
    (import typing      [Generic])

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

; ________________________________________________________________________/ }}}2
; [GROUP] Typing: Strict ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (import pydantic    [BaseModel])
    (import pydantic    [StrictInt])       #_ "will be still of int type, but will perform strict typecheck when variable is created"
    (import pydantic    [StrictStr])       #_ "will be still of str type, but will perform strict typecheck when variable is created"
    (import pydantic    [StrictFloat])     #_ "will be still of float type, but will perform strict typecheck when variable is created" ;;

    #_ "Union of StrictInt and StrictFloat"
    (setv StrictNumber (of Union #(StrictInt StrictFloat))) ;;

    (import pydantic [validate_call])   #_ "decorator for type-checking func args" ;;

    #_ "same as validate_call but with option validate_return=True set (thus validating args and return type)"
    (setv validateF (validate_call :validate_return True))

; ________________________________________________________________________/ }}}2


; _____________________________________________________________________________/ }}}1
; [F] mathnlogic ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

; Import and Export ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    ; ///fptk_local: removed export statement///


    (import functools [reduce])
    (import operator [mul :as operator_mul])

; ________________________________________________________________________/ }}}2

; [GROUP] Math and logic: Basic math ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (import hyrule    [inc])        #_ "inc(n) | = n + 1"
    (import hyrule    [dec])        #_ "dec(n) | = n - 1"
    (import hyrule    [sign])       #_ "sign(n) | will give 0 for n=0"
    (import operator  [neg])        #_ "neg(n) | = -1 * n"

    ;;

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

; ________________________________________________________________________/ }}}2
; [GROUP] Math and logic: Trigonometry ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

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
; [GROUP] Math and logic: Base operators to functions ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

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
            (reduce operator_mul args 1))

        #_ "plus(*args) | addition as a monoid (will not give error when used with 0 or 1 args)"
        (defn plus [#* args]
            " plus(a1, a2, ...) = 0 + a1 + a2 + ...
              addition as a monoid with identity = 0 "
            (reduce (fn [%s1 %s2] (+ %s1 %s2)) args 0))

        #_ "sconcat(*args) | string concantenation as a monoid (will not give error when used with 0 or 1 args)"
        (defn sconcat [#* args]
            " sconcat(s1, s2, ...) = '' + s1 + s2 + ...
              string concantenation as a monoid with identity = '',
              can be used with 0 or 1 args"
            (reduce (fn [%s1 %s2] (+ %s1 %s2)) args ""))

        ;; lconcat (list on itertools.chain) is a monoid on lists too

; ________________________________________________________________________/ }}}2
; [GROUP] Math and logic: Logic checks ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

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

; ________________________________________________________________________/ }}}2
; [GROUP] Math and logic: Random ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (import random    [choice])                 #_ "choice(seq) -> Elem | throws error for empty list"
    (import random    [randint])                #_ "randint(a, b) -> int | returns random integer in range [a, b] including both end points"
    (import random    [uniform :as randfloat])  #_ "randfloat(a, b) -> float | range is [a, b) or [a, b] depending on rounding"
    (import random    [random :as rand01])      #_ "rand01() -> float | generates random number in interval [0, 1) "

    ;; shuffle — is mutating

; ________________________________________________________________________/ }}}2


; _____________________________________________________________________________/ }}}1
; [F] strings ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; ///fptk_local: removed export statement///

    (import funcy [str_join :as funcy_str_join])
    (import hyrule [inc])

; [GROUP] Strings: Basics ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    #_ "strlen(text) | rename of len, underlines usage on strings"
    (defn strlen [text]
        "rename of len, underlines usage on strings"
        (len text))

    #_ "str_join(ss, sep='') | rearrangement of funcy.str_join, ss is seq of strings"
    (defn str_join [ss [sep ""]]
        "str_join(['1', '2', '3'], '-') = '1-2-3'"
        (if (bool sep)
            (funcy_str_join sep ss)
            (funcy_str_join ss)))

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
                          (return (cut string (- (len string) target_len) (inc (len string))))))
        ;;
        (setv n_required (max 0 (- target_len (len string))))
		(if on_tail
			(setv outp (+ string (cut (* char n_required) 0 (- target_len (len string)))))
			(setv outp (+ (cut (* char n_required) 0 (- target_len (len string))) string)))
		(return outp))

; ________________________________________________________________________/ }}}2
; [GROUP] Strings: Regex ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (import re        [sub :as re_sub])         #_ "re_sub(rpattern, replacement, string, count=0, flags=0) |"
    (import re        [split :as re_split])     #_ "re_split(rpattern, string) |"
    (import funcy     [re_find])                #_ "re_find(rpattern, string, flags=0) -> str| returns first found"
    (import funcy     [re_test])                #_ "re_test(rpattern, string, ...) -> bool | tests if string has match (not neccessarily whole string)"
    (import funcy     [re_all])                 #_ "re_all(rpattern, string, ...) -> List |"

; ________________________________________________________________________/ }}}2


; _____________________________________________________________________________/ }}}1
; [F] IO ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; ///fptk_local: removed export statement///

; [GROUP] IO ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

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

; ________________________________________________________________________/ }}}2


; _____________________________________________________________________________/ }}}1
; [F] lens ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; ///fptk_local: removed export statement///

; [GROUP] Lens ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (import lenses [lens])         #_ "main object of lenses library (for working with immutable structures)"

    ; ///fptk_local: removed import of fptk._macros///   #_ "macros for working with lens, see lens macros docs for details"
    ; ///fptk_local: removed import of fptk._macros///    #_ "macros for working with lens, see lens macros docs for details"
    ; ///fptk_local: removed import of fptk._macros///   #_ "macros for working with lens, see lens macros docs for details"
    ; ///fptk_local: removed import of fptk._macros///    #_ "macros for working with lens, see lens macros docs for details"
    ; ///fptk_local: removed import of fptk._macros///   #_ "macros for working with lens, see lens macros docs for details"

; ________________________________________________________________________/ }}}2


; _____________________________________________________________________________/ }}}1
; [F] benchmark ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; ///fptk_local: removed export statement///

    (import  typing [Tuple Any])
    (import hyrule [assoc])
    (require hyrule [of do_n case])

; [GROUP] Benchmarking ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    #_ "timing(f, *args, **kwargs) -> (float, Any) | returns tuple of execution time (in s) and result of f(*args, **kwargs)"
    (defn #^ (of Tuple float Any)
        timing [f #* args #** kwargs]
        "calculated f(*args, **kwargs) and returns tuple: (execution time in s, result)"
        (setv _time_getter hy.I.time.perf_counter)
        (setv t0 (_time_getter))
        (setv outp (f #* args #** kwargs))
        (setv t1 (_time_getter))
        (return #((- t1 t0) outp)))

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
; [F] testing ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ; ///fptk_local: removed export statement///

; [GROUP] Testing ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    ; ///fptk_local: removed import of fptk._macros///            #_ "(assertm op arg1 arg2) | tests if (op arg1 arg2), for example (= 1 1)"
    ; ///fptk_local: removed import of fptk._macros///  #_ "| example: (assertm gives_error_typeQ (get [1] 2) IndexError)"

; ________________________________________________________________________/ }}}2

; _____________________________________________________________________________/ }}}1
; [Monads] resultM ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

; Import/Export ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (import typing [TypeVar Generic Union])
    (import pydantic [BaseModel])
    (import funcy [compose rcompose lmap partial])
    (require hyrule [of unless])

    ; ///fptk_local: removed export statement///

; ________________________________________________________________________/ }}}2

; Classes ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

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

    (defn Failure [value] (Result :result (_Failure :value value )))
    (defn Success [value] (Result :result (_Success :value value )))

; ________________________________________________________________________/ }}}2
; utils: Basic ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    ; - functions below also work correctly with [validateF]
    ; - (of Result S F) — this too works with [validateF]

    ; dev note: rely on failureQ/successQ to check if resultM is of Result type

    (defn _nonR_error [x] (ValueError f"Value <{x}> must be of Result type"))

    (defn #^ bool failureQ [#^ Result resultM]
        (unless (isinstance resultM Result) (raise (_nonR_error resultM )))
        (isinstance resultM.result _Failure))

    (defn #^ bool successQ [#^ Result resultM]
        (unless (isinstance resultM Result) (raise (_nonR_error resultM )))
        (isinstance resultM.result _Success))

; ________________________________________________________________________/ }}}2
; utils: Chaining ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (defn #^ Result mapR [#^ Result resultM #* fs]
        (if (failureQ resultM)
             (return resultM)
             (return (Success ((compose #* fs) resultM.result.value )))))

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

; ________________________________________________________________________/ }}}2
; utils: Routing ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

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

; ________________________________________________________________________/ }}}2


; _____________________________________________________________________________/ }}}1
; MACROS ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

; Import ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

	(import  hyrule [rest butlast])
	(require hyrule [-> ->> of])
	(import  operator)

; ________________________________________________________________________/ }}}2

; === Helpers (precompiled functions) ===

; expr type checkers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

	(-> (defn _isNegIntegerExpr ; (_isNegIntegerExpr '(- 3))
			[ arg
			]
			(and (= (type arg) hy.models.Expression)
				 (= (get arg 0) (hy.models.Symbol "-"))
				 (= (len arg) 2)
				 (= (type (get arg 1)) hy.models.Integer)))
		eval_and_compile)
	
	(-> (defn _isExprWithHeadSymbol ; (head ...)
			[ #^ hy.models.Expression arg
			  #^ str head
			]
			(and (= (type arg) hy.models.Expression)
				 (= (get arg 0) (hy.models.Symbol head))))
		eval_and_compile)

	(-> (defn _isUnpackMappingQ  ; #**
			[ arg
			]
			(and (= (type arg)  hy.models.Expression)
                 (= (get arg 0) (hy.models.Symbol "unpack-mapping"))))
		eval_and_compile)

	(-> (defn _isUnpackIterableQ  ; #*
			[ arg
			]
			(and (= (type arg)  hy.models.Expression)
                 (= (get arg 0) (hy.models.Symbol "unpack-iterable"))))
		eval_and_compile)

; ________________________________________________________________________/ }}}2
;
; INFO: Dot Macro Expressions ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2
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
;
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

; Info on importing ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

	; when only importing (import fptk [f>]), f> is required to have fm internally, and it can be called as:
	; 
	; -> fm				-> ✗ does not work in dev file
	;								   ✓ works from outside projs (it is essentially call to installed lib)
	;								   ✓ this is how it is done in hyrule (I think this is due to their hy_init.hy importing everything)
	;										 
	;	 fm							-> [✓ ✗] works from dev file
	;	 hy.R.fptk_macros.fm		-> [✓ ✗] works from dev file
	;	 fptk_macros.fm	-> [✗ ✗] does not work anywhere

; ________________________________________________________________________/ }}}2
; def:: ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

; ■ info ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{3

    ; int -> / -> int -> * -> int -> #* int -> #** int => float
    ; ***    *    ***    *    ***    ******    *******    *****     those are seen as one marg by hy
    ;                                                       ↑ last_sign_n 
    ; 

    ; @ -> int => float
    ; symbol @ is instruction to add no signature

    ; hy.models.Symbol('int')
    ; hy.models.Symbol('/')
    ; hy.models.Symbol('*')
    ; hy.models.Expression([
    ;    hy.models.Symbol('unpack-iterable'),
    ;    hy.models.Symbol('int')])
    ; hy.models.Expression([
    ;    hy.models.Symbol('unpack-mapping'),
    ;    hy.models.Symbol('int')])

    ; '(annotate x int) = #^ int x

    ; in python only one * is available:
    ; f(a, b, /, c, *args, **kwargs)
    ; f(a, b, /, c, *, d, **kwargs)

; ___________________________________________________________________/ }}}3

    ; marg = macros arg
    ; sarg = signature args 
    ; sret = signature return type
    ; farg = function args
    ; aarg = annotated arg

	(defmacro def:: [#* margs]
        ; deconstruct margs:
        (for [[&n &arg] (enumerate margs)]
            (when (= &arg '=>)
                  (setv _last_sign_n (+ &n 1))
                  (break)))
        (setv _sargs (cut margs 0 (- _last_sign_n 1) 2))
        (setv _sreturn (get margs _last_sign_n))
        ;
        (setv decs_or_funcname (get margs (+ _last_sign_n 1)))
        (setv has_decorators_list (= (type decs_or_funcname) (type '[]))) ; empty list = counted as list exists
        (if has_decorators_list 
            (setv i0 (+ _last_sign_n 2))
            (setv i0 (+ _last_sign_n 1)))
        (if has_decorators_list
            (setv _decorators (get margs (- i0 1)))
            (setv _decorators '[]))
        (setv [_fname _fargs _body]
              [(get margs i0) (get margs (+ i0 1)) (cut margs (+ i0 2) None)])
        (when (!= (len _sargs) (len _fargs))
              (raise (SyntaxError "number of args in signature does not match with number of function args")))
        ; build args annotations:
        (setv _aargs []) 
        (for [[&sarg &farg] (zip _sargs _fargs)]
            (cond ; * and / case:
                  (or (= &farg '*) (= &sarg '*))
                  (if (= &farg &sarg)
                      (_aargs.append &farg)
                      (raise (SyntaxError "position of * in signature does not match with args")))
                  (or (= &farg '/) (= &sarg '/))
                  (if (= &farg &sarg)
                      (_aargs.append &farg)
                      (raise (SyntaxError "position of / in signature does not match with args")))
                  ; #* and #** case:
                  (or (_isUnpackIterableQ &sarg) (_isUnpackIterableQ &farg))
                  (if (and (_isUnpackIterableQ &sarg) (_isUnpackIterableQ &farg))
                      (if (= (get &sarg 1) '@)
                          (_aargs.append &farg)
                          (_aargs.append `(annotate ~&farg ~(get &sarg 1))))
                      (raise (SyntaxError "position of #* in signature does not match with args")))
                  (or (_isUnpackMappingQ &sarg) (_isUnpackMappingQ &farg))
                  (if (and (_isUnpackMappingQ &sarg) (_isUnpackMappingQ &farg))
                      (if (= (get &sarg 1) '@)
                          (_aargs.append &farg)
                          (_aargs.append `(annotate ~&farg ~(get &sarg 1))))
                      (raise (SyntaxError "position of #** in signature does not match with args")))
                  ; @ case:
                  (= &sarg '@)
                  (_aargs.append &farg)
                  ; everything else:
                  True
                  (_aargs.append `(annotate ~&farg ~&sarg))))
        ; build function return annotation
        (if (= _sreturn '@)
            (setv _aret _fname) 
            (setv _aret `(annotate ~_fname ~_sreturn)))
        ; build function:
        `(defn ~_decorators
               ~_aret
               ~_aargs
               ~@_body))

; ________________________________________________________________________/ }}}2
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
						(pargs.append `(hy.I.funcy.partial (fn [%args %mth] (%mth (unpack_iterable	%args)))
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
			  True				   (return `(hy.I.funcy.lpluck ~indx ~iterable))))

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
		(setv itargs (->> expr
						  flatten
						  (filter (fn [%x] (= %x 'it)))
						  sorted))	; example: [hy.models.Symbol('it')]
		(setv pargs  (->> expr
						  flatten
						  (filter (fn [%x] (or (= %x '%1) (= %x '%2) (= %x '%3)
											   (= %x '%4) (= %x '%5) (= %x '%6)
											   (= %x '%7) (= %x '%8) (= %x '%9))))
						  sorted))	; example: [hy.models.Symbol('%1'), hy.models.Symbol('%2')]
		(setv has_pargs (> (len pargs ) 0))
		(setv has_itarg (> (len itargs) 0))
		;
		(when (and has_itarg has_pargs) (raise (SyntaxError "cannot mix 'it' and '%n' syntax in fm macro"))) ; both "it" and "%1"... are found
		(when has_itarg (return `(fn [it] ~expr)))	; only "it" are found
		(if has_pargs
			(setv maxN (int (get pargs -1 -1)))		; only "%1"... args are found
			(setv maxN 0))							; no args are found
		(setv inputs (lfor n (thru 1 maxN) (hy.models.Symbol f"%{n}")))
		(return `(fn [~@inputs] ~expr)))

	(defmacro f> [lambda_def #* args]
		(return `((fm ~lambda_def) ~@args)))

	(defmacro mapm [one_shot_fm #* args]
		(return `(map (fm ~one_shot_fm) ~@args)))

	(defmacro lmapm [one_shot_fm #* args]
		(return `(list (map (fm ~one_shot_fm) ~@args))))

	(defmacro filterm [one_shot_fm iterable]
		(return `(filter (fm ~one_shot_fm) ~iterable)))

	(defmacro lfilterm [one_shot_fm iterable]
		(return `(list (filter (fm ~one_shot_fm) ~iterable))))

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
	   `(& ~@lenses_ (lns ~func)))

	; compose lens, add setters/getters, apply

	(defmacro &+> [#* macro_args]
		(setv variable (get macro_args 0))
		(setv lenses   (butlast (rest macro_args)))
		(setv func	   (get macro_args (- 1)))
	   `((& ~@lenses (lns ~func)) ~variable))

	; construct lens, apply:

	(defmacro l> [#* macro_args]
		(setv variable	  (get macro_args 0))
		(setv lenses_args (rest macro_args))
	   `((lns ~@lenses_args) ~variable))

	(defmacro l>= [#* macro_args]
		(setv variable	  (get macro_args 0))
		(setv lenses_args (rest macro_args))
	   `(&= ~variable (lns ~@lenses_args)))

; ________________________________________________________________________/ }}}2
; assertm, gives_error_typeQ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

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
					 (print "------------------------\nError in"
                            (hy.I.termcolor.colored ~_test_expr None None ["underline"])
                            "|"
                            (hy.I.termcolor.colored (type eFull) "red")
                            (hy.I.termcolor.colored ":" "red")
                            (hy.I.termcolor.colored eFull "red"))
					 (setv _outp eFull)
					 (try ~arg1
						  (print (hy.I.termcolor.colored ">> 1st arg OK:" "green")
                                 (hy.I.termcolor.colored ~_arg1 None None ["underline"])
                                 "=" ~arg1)
						  (except [e1 Exception]
								  (print (hy.I.termcolor.colored ">> 1st arg XX:" "red")
                                         (hy.I.termcolor.colored ~_arg1 None None ["underline"])
                                         "|"
                                         (hy.I.termcolor.colored (type e1) "red")
                                         (hy.I.termcolor.colored ":" "red")
                                         (hy.I.termcolor.colored e1 "red"))))
					 (try ~arg2
						  (print (hy.I.termcolor.colored ">> 2nd arg OK:" "green")
                                 (hy.I.termcolor.colored ~_arg2 None None ["underline"])
                                 "=" ~arg2)
						  (except [e2 Exception]
								  (print (hy.I.termcolor.colored ">> 2nd arg XX:" "red")
                                         (hy.I.termcolor.colored ~_arg2 None None ["underline"])
                                         "|"
                                         (hy.I.termcolor.colored (type e2) "red")
                                         (hy.I.termcolor.colored ":" "red")
                                         (hy.I.termcolor.colored e2 "red"))))
					 eFull)))

    ; test:
    ; (assertm eq (div 2 0) (div 1 0))
    ; (assertm eq 1 (div 1 0))
    ; (assertm eq (div 1 0) 1)

	(defmacro gives_error_typeQ [expr error_type]
	   `(try ~expr
			 False
			 (except [e Exception]
					 (= ~error_type (type e)))))

; ________________________________________________________________________/ }}}2



; _____________________________________________________________________________/ }}}1
