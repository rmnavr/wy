
    ; this file is fptk 0.2.2.dev1 (it is here to have stable version)
    ; - mods were made

; funcs ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (require hyrule [comment])

; ■ [GROUP] Import Full Modules ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

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
    (import funcy)              #_ "3rd party"

; ________________________________________________________________________/ }}}2
; ■ [GROUP] Typing ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (require hyrule [of])

    (import dataclasses [dataclass])
    (import enum        [Enum])
    (import abc         [ABC])
    (import abc         [abstractmethod])
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

    (import pydantic    [BaseModel])
    (import pydantic    [StrictInt])
    (import pydantic    [StrictStr])
    (import pydantic    [StrictFloat])
    (import pydantic    [validate_arguments :as validate_args]) #_ "decorator for type-checking function arguments (but not return type)"

    #_ "Int or Float"
    (setv StrictNumber (get Union #(StrictInt StrictFloat)))

    (import returns.result  [Result])
    (import returns.result  [Success])
    (import returns.result  [Failure])

    (import funcy [isnone])
    (import funcy [notnone])

; ________________________________________________________________________/ }}}2
; ■ [GROUP] Getters ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (import  lenses [lens])

    ;; dub basics:

        (comment "hy     | macro | .     | (. xs [n1] [n2] ...) -> xs[n1][n2]... | throws error when not found")
        (comment "hy     | macro | get   | (get xs n #* keys) -> xs[n][key1]... | throws error when not found")
        (import funcy [nth])        #_ "nth(n, xs) -> Optional elem | 0-based index; works also with dicts"
        (comment "py     | base  | slice | (slice start end step) | ")
        (comment "hy     | macro | cut   | (cut xs start end step) -> (get xs (slice start end step)) -> List | gives empty list when none found")
        (import  hyrule [ assoc ])  #_ "(assoc xs k1 v1 k2 v2 ...) -> (setv (get xs k1) v1 (get xs k2) v2) -> None | also possible: (assoc xs :x 1)"
        (require hyrule [ ncut ])   

    ;; one elem getters:

        (import funcy [first])      #_ "first(xs) -> Optional elem |"
        (import funcy [second])     #_ "second(xs) -> Optional elem |" ;;

        #_ "third(xs) -> Optional elem |"
        (defn third      [xs] (if (<= (len xs) 2) (return None) (return (get xs 2))))

        #_ "fourth(xs) -> Optional elem |"
        (defn fourth     [xs] (if (<= (len xs) 3) (return None) (return (get xs 3))))

        #_ "beforelast(xs) -> Optional elem |"
        (defn beforelast [xs] (if (<= (len xs) 1) (return None) (return (get xs -2))))

        (import funcy [last])       #_ "last(xs) -> Optional elem" 

    ;; list getters:

        #_ "rest(xs) -> List | drops 1st elem of list"
        (defn rest       [xs] (get xs (slice 1 None)))

        #_ "rest(xs) -> List | drops last elem of list"
        (defn butlast    [xs] (get xs (slice None -1)))

        #_ "drop(n, xs) -> List | drops from start/end of the list"
        (defn drop       [n xs] (if (>= n 0) (cut xs n None) (cut xs None n)))

        #_ "take(n, xs) -> List | takes from start/end of the list"
        (defn take       [n xs] (if (>= n 0) (cut xs None n) (cut xs (+ (len xs) n) None)))

        #_ "pick(ns, xs) -> List | throws error if idx doesn't exist; also works with dicts keys"
        (defn pick       [ns xs] (lfor &n ns (get xs &n)))

        (import  funcy  [lpluck])       #_ "lpluck(key, xs) | works also with dicts"
        (import  funcy  [lpluck_attr])  #_ "lpluck(attr_str, xs) |" ;;

; ________________________________________________________________________/ }}}2
; ■ [GROUP] index-1-based getters ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (import hyrule [thru :as range_])      #_ "range_(start, end, step) -> List | same as range, but with 1-based index"

    #_ "get_(xs, n1, n2, ...) -> elem | same as get, but with 1-based index (will throw error for n=0)"
    (defn get_ [xs #* ns]
        (setv ns_plus1 
            (lfor &n ns
                (do (when (= &n 0) (raise (Exception "n=0 can't be used with 1-based getter")))
                    (if (and (intQ &n) (>= &n 1))
                        (dec &n)
                        &n)))) ;; this line covers both &n<0 and &n=dict_key        
        (return (get xs #* ns_plus1)))

    #_ "nth_(n, xs) -> Optional elem | same as nth, but with 1-based index (will throw error for n=0)"
    (defn nth_ [n xs] 
        (when (dictQ xs) (return (nth n xs)))
        (when (=  n 0) (raise (Exception "n=0 can't be used with 1-based getter")))
        (when (>= n 1) (return (nth (dec n) xs)))
        (return (nth n xs))) ;; this line covers both n<0 and n=dict_key

    #_ "slice_(start, end, step) | same as slice, but with 1-based index (it doesn't understand None and 0 for start and end arguments)"
    (defn slice_
        [ start
          end
          [step None]
        ]
        (cond (>= start 1) (setv _start (dec start))
              (<  start 0) (setv _start start)
              (=  start 0) (raise (Exception "start=0 can't be used with 1-based getter"))
              True         (raise (Exception "start in 1-based getter is probably not an integer")))
        ;;
        (cond (=  end -1) (setv _end None)
              (>= end  1) (setv _end end)
              (<  end -1) (setv _end (inc end))
              (=  end  0) (raise (Exception "end=0 can't be used with 1-based getter"))
              True        (raise (Exception "end in 1-based getter is probably not an integer")))
        (return (slice _start _end step)))

    #_ "cut_(xs, start, end, step) -> List | same as cut, but with 1-based index (it doesn't understand None and 0 for start and end arguments)"
    (defn cut_ [xs start end [step None]] (get xs (slice_ start end step)))

; ________________________________________________________________________/ }}}2

; ■ [GROUP] Control flow ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (comment "hy | base | if   | (if check true false)          | ")
    (comment "hy | base | cond | (cond check1 do1 ... true doT) | ")

    (require hyrule [case])
    (require hyrule [branch])
    (require hyrule [unless])
    (require hyrule [lif])

; ________________________________________________________________________/ }}}2

; ■ [GROUP] Compositions ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

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

    (import funcy   [ljuxt]) #_ "ljuxt(f,g,...) = [f, g] applicator |" ;;

    #_ "flip(f, a, b) = f(b, a) | example: (flip lmap [1 2 3] sqrt)"
    (defn flip [f a b] (f b a))

    #_ "pflip(f, a) = f(_, a) partial applicator | example: (lmap (pflip div 0.1) (thru 1 3))"
    (defn pflip [f a] (fn [%x] (f %x a)))

; ________________________________________________________________________/ }}}2
; ■ [GROUP] APL: n-applicators ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (require hyrule [do_n])     #_ "(do_n   n #* body) -> None |"
    (require hyrule [list_n])   #_ "(list_n n #* body) -> List |"

    #_ "nest(n, f) | f(f(f(...f)))"
    (defn nest [n f] (compose #* (list_n n f)))

    #_ "apply_n(n, f, *args, **kwargs) | f(f(f(...f(*args, **kwargs))"
    (defn apply_n [n f #* args #** kwargs] ((compose #* (list_n n f)) #* args #** kwargs))

; ________________________________________________________________________/ }}}2
; ■ [GROUP] APL: Threading ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (comment "py | base | map | map(f, *xss) -> iterator | ")
    (import funcy     [lmap])       #_ "lmap(f, *xss) -> List"
    (import itertools [starmap])    #_ "starmap(f, xs)" ;;

    #_ "lstarmap(f,xs) -> List |"
    (defn lstarmap [f xs] (list (starmap f xs)))

    (import functools [reduce])  #_ "reduce(f, xs[, x0]) -> value | reduce + monoid = binary-function for free becomes n-arg-function"

    (comment "py | base | zip | zip(*xss) -> iterator I guess | ")
    
    #_ "lzip(*xss) = list(zip(*xss)) |"
    (defn lzip [#* args] (list (zip #* args)))

; ________________________________________________________________________/ }}}2
; ■ [GROUP] APL: Filtering ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (comment "py | base | filter | filter(f or None, xs) -> filter object | when f=None, checks if elems are True")
    (import funcy [lfilter]) #_ "lfilter(f, xs) -> List"

    #_ "fltr1st(f, xs) -> Optional elem | returns first found element (or None)"
    (defn fltr1st [f xs] (next (gfor &x xs :if (f &x) &x) None))

    #_ "count_occurrences(elem, xs) -> int | rename of list.count method"
    (defn count_occurrences [elem container] (container.count elem))

; ________________________________________________________________________/ }}}2
; ■ [GROUP] APL: Work on lists ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (import hyrule     [flatten])   #_ "flattens to the bottom" ;;

    #_ "lprint(lst) -> (lmap print lst) |"
    (defn lprint [lst] (lmap print lst) (return None))

    (comment "py | base | reversed | reversed(xs) -> iterator |") 

    #_ "lreversed(*args) = list(reversed(*args)) |"
    (defn lreversed [xs] (list (reversed xs)))

; ________________________________________________________________________/ }}}2

; ■ [GROUP] General Math ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (import hyrule    [inc])
    (import hyrule    [dec])
    (import hyrule    [sign])
    (import operator  [neg])

    #_ "(half x) = (/ x 2)"
    (defn half       [x] (/ x 2))

    #_ "(double x) = (* x 2)"
    (defn double     [x] (* x 2))

    #_ "(squared x) = (pow x 2)"
    (defn squared    [x] (pow x 2))

    #_ "reciprocal(x) = 1/x literally |"
    (defn reciprocal [x] (/ 1 x))

    (import math [sqrt])
    (import math [dist])    #_ "dist(v1, v2) -> float | ≈ √((v1x-v2x)² + (v1y-v2y)² ...)"
    (import math [hypot])   #_ "hypot(x, y, ...) | = √(x² + y² + ...)" ;;

    #_ "normalize(vector) -> vector | returns same vector if it's norm=0"
    (defn normalize [v0]
        (setv norm (hypot #* v0))
        (if (!= norm 0) (return (lmap (pflip div norm) v0)) (return v0)))

    (import operator [truediv :as div])
    (import math     [prod :as product])

    (import math     [exp])

    (import math     [log]) #_ "log(x, base=math.e)" ;;

    #_ "ln(x) = math.log(x, math.e) | coexists with log for clarity"
    (defn ln [x] (log x))

    (import math     [log10])

; ________________________________________________________________________/ }}}2
; ■ [GROUP] Trigonometry ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (import math [pi])
    (import math [sin])
    (import math [cos])
    (import math [tan])
    (import math [degrees])
    (import math [radians])
    (import math [acos])
    (import math [asin])
    (import math [atan])
    (import math [atan2]) #_ "atan2(y, x) -> value | both signs are considered"
    (import math [sin])

; ________________________________________________________________________/ }}}2
; ■ [GROUP] Base operators to functions ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

        #_ "minus(x, y) = x - y |"
        (defn minus [x y] (- x y))

    ;; *

        #_ "mul(*args) | multiplication as a monoid (will not give error when used with 0 or 1 args)"
        (defn mul [#* args] (reduce operator.mul args 1))

        #_ "lmul(*args) = arg1 * arg2 * ... | rename of * operator, underlines usage for list"
        (defn lmul [#* args] (* #* args))

        #_ "smul(*args) = arg1 * arg2 * ... | rename of * operator, underlines usage for string"
        (defn smul [#* args] (* #* args))

    ;; +

        #_ "plus(*args) | addition as a monoid (will not give error when used with 0 or 1 args)"
        (defn plus [#* args] (reduce operator.add args 0))

        #_ "sconcat(*args) | string concantenation as a monoid (will not give error when used with 0 or 1 args)"
        (defn sconcat [#* args] (reduce (fn [%s1 %s2] (+ %s1 %s2)) args ""))

        #_ "lconcat(*args) | list concantenation as a monoid (will not give error when used with 0 or 1 args)"
        (defn lconcat [#* args] (reduce (fn [%s1 %s2] (+ %s1 %s2)) args []))

; ________________________________________________________________________/ }}}2
; ■ [GROUP] Logic and ChecksQ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (import hyrule   [xor])

    (import operator [eq])              #_ "equal"
    (import operator [ne   :as neq])    #_ "non-equal"
    (import funcy    [even :as evenQ])
    (import funcy    [odd  :as oddQ])   ;;

    #_ "| checks directly via (= x 0)"
    (defn zeroQ     [x] (= x 0))

    #_ "| checks directly via (< x 0)"
    (defn negativeQ [x] (< x 0))

    #_ "| checks directly via (> x 0)"
    (defn positiveQ [x] (> x 0))

    #_ "| checks literally if (= (len xs) 0)"
    (defn zerolenQ [xs] (= (len xs) 0))

    #_ "(istype tp x) -> (= (type x) tp) |"
    (defn oftypeQ [tp x] (= (type x) tp))

    #_ "(oflenQ xs n) -> (= (len xs) n) |"
    (defn oflenQ [xs n] (= (len xs) 3))

    (defn intQ   [x] (= (type x) int))
    (defn floatQ [x] (= (type x) float))
    (defn dictQ  [x] (= (type x) dict))

    (import funcy [is_list  :as listQ ])  #_ "listQ(seq)  | checks if seq is list"
    (import funcy [is_tuple :as tupleQ])  #_ "tupleQ(seq) | checks if seq is tuple"

    #_ "fnot(f, *args, **kwargs) = not(f(*args, **kwargs)) | "
    (defn fnot [f #* args #** kwargs] (not (f #* args #** kwargs)))

; ________________________________________________________________________/ }}}2

; ■ [GROUP] Strings ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (defn strlen [text] (len text))

    #_ "str_join(seq, sep='') | rearrangement of funcy.str_join"
    (defn str_join [seq [sep ""]]
        (if (bool sep)
            (funcy.str_join sep seq)
            (funcy.str_join seq)))

    #_ "str_replace(string, old, new, count=-1) ; rename of string.replace method"
    (defn str_replace [string old new [count -1]] (string.replace old new count))

    (defn #^ str  lowercase [#^ str string] (string.lower))

    #_ "endswith(string, ending) -> bool ; rename of string.endswith method"
    (defn #^ bool endswith  [#^ str string #^ str ending] (string.endswith ending))

    (defn #^ str  strip     [#^ str string] (string.strip))
    (defn #^ str  lstrip    [#^ str string] (string.lstrip))
    (defn #^ str  rstrip    [#^ str string] (string.rstrip))

; ________________________________________________________________________/ }}}2
; ■ [GROUP] Regex ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

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
; ■ [GROUP] Random ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (import random    [choice])                 #_ "choice(xs) -> Elem | throws error for empty list"
    (import random    [randint])                #_ "randint(a, b) -> int | returns random integer in range [a, b] including both end points" 
    (import random    [uniform :as randfloat])  #_ "randfloat(a, b) -> float | range is [a, b) or [a, b] depending on rounding"
    (import random    [random :as rand01])      #_ "rand01() -> float | generates random number in interval [0, 1) "

    ;; shuffle — is mutating

; ________________________________________________________________________/ }}}2

; ■ [GROUP] IO ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    (import os.path [exists :as file_existsQ]) #_ "file_existsQ(filename) | also works on folders" ;;

    #_ "read_file(file_name, encoding='utf-8') -> str | reads whole file content "
    (defn read_file
        [ #^ str file_name
          #^ str [encoding "utf-8"]
        ]
        (with [file (open file_name "r" :encoding encoding)] (setv outp (file.read)))
        (return outp))

    #_ "write_file(text, file_name, mode='w', encoding='utf-8') | modes: 'w' - (over)write, 'a' - append, 'x' - exclusive creation"
    (defn write_file
        [ #^ str text
          #^ str file_name
          #^ str [mode "w"]
          #^ str [encoding "utf-8"]
        ]
        (with [file (open file_name mode :encoding encoding)] (file.write text)))

; ________________________________________________________________________/ }}}2
; ■ [GROUP] Benchmarking ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

    #_ "w_e_t(f, n=1, tUnit='ns', msg='') -> avrg_time_of_1_run_in_seconds, pretty_string, f_result | f_result is from 1st function execution"
    (defn #^ (of Tuple float str Any)
        with_execution_time
        [ #^ Callable f
          *
          #^ int      [n     1]
          #^ str      [tUnit "ns"]      #_ "s/ms/us/ns"
          #^ str      [msg   ""]
        ]
        "returns tuple: 1) str of test result 2) function execution result"
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
        (setv line_02_n     (str_replace f"average of {n :,} runs" "," "'"))
        (setv line_02_timeN f"test duration: {seconds :.3f} s")
        ;;
        (setv _prompt (sconcat line_01 "\n"
                               line_02_time1 " as " line_02_n " // " line_02_timeN))
        (return [_time_1_s _prompt _outp]))
    ;;
    ;; (print (execution_time :n 100 (fn [] (get [1 2 3] 1))))

    #_ "use dt_printer('msg1', 'msg2', ...) normally, use dt_printer(fresh_run=True, 'msg1', ...) to reset timer"
    (defn dt_print
        [ #* args
          [fresh_run False]
          [last_T    [None]]
        ]
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

; ■ neg integer expr ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

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
; ■ expr with head symbol ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

	; (head ...)
	(-> (defn _isExprWithHeadSymbol
			[ #^ hy.models.Expression arg
			  #^ str head
			]
			(and (= (type arg) hy.models.Expression)
				 (= (get arg 0) (hy.models.Symbol head))))
		eval_and_compile)

; ________________________________________________________________________/ }}}2

; ■ DEVDOC: Dot Macro Expressions ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2
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
; ■ .dottedAttr ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

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
; ■ .dottedAccess ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

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
; ■ .dottedMth ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

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
; ■ [ARCHIVE] :attr: ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

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

	; === Macroses ===


; ■ f:: ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

	(defmacro f:: [#* macro_args]
		;
		(setv fInputsOutputs (get macro_args (slice None None 2)))
		(setv fInputs (get fInputsOutputs (slice 0 (- 1))))
		(setv fOutput (get fInputsOutputs (- 1)))
		`(of Callable ~fInputs ~fOutput))

; ________________________________________________________________________/ }}}2
; ■ p: ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

; ■ ■ comment on (.mth 3 4) deconstruction ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{3

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

    (defn flip [f a b] (f b a))                   ; (flip lmap [1 2 3] sqrt)

	(defmacro p: [#* args]
		;
		(setv pargs [])
		(for [&arg args]
			  (cond ; .x  -> (partial flip getattr "x")
					(_isDottedAttr &arg)
					(pargs.append `(partial flip getattr ~(str (_extractDottedAttr &arg))))
					; operator.neg
					(_isDottedAccess &arg)
					(pargs.append `(partial ~&arg))
					; (. mth 2 3) -> essentially (. SLOT mth 2 3)
					(_isDottedMth &arg)
					(do (pargs.append `(partial flip getattr
											~(str (get (_extractDottedMth &arg) "head")))) ; -> mth)
						(pargs.append `(partial (fn [%args %mth] (%mth (unpack_iterable  %args)))
												[~@(get (_extractDottedMth &arg) "args")])))
					; abs -> (partial abs)
					(= (type &arg) hy.models.Symbol)
					(pargs.append `(partial ~&arg))
	                ; (fn/fm ...) -> no change
                    (or (_isExprWithHeadSymbol &arg "fn")
                        (_isExprWithHeadSymbol &arg "fm")
                        (_isExprWithHeadSymbol &arg "f>"))
                    (pargs.append &arg)
					; (func 1 2) -> (partial func 1 2)
					; (operator.add 3) -> (partial operator.add 3)
					(= (type &arg) hy.models.Expression)
					(pargs.append `(partial ~@(cut &arg 0 None)))
					; (etc ...) -> (partial etc ...)
					True
					(pargs.append `(partial ~&arg))))
	   `(rcompose ~@pargs))


; ________________________________________________________________________/ }}}2
; ■ pluckm, getattrm ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

	(defmacro pluckm [indx iterable]
		(cond ; .attr -> "attr"
			  (_isDottedAttr indx)
			  (return `(lpluck_attr ~(str (_extractDottedAttr indx)) ~iterable))
			  ;
			  True
			  (return `(lpluck ~indx ~iterable))))

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
; ■ fm, f>, lmapm ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

	; recognizes %1..%9 as arguments
	; nested fm calls will not work as intended

	(defmacro fm [expr]
		(import hyrule [flatten thru])
		;
		(setv models (flatten expr))
		(setv args (filter (fn [%x] (= (type %x) hy.models.Symbol)) models))	; Symbols
		(setv args (filter (fn [%x] (and (= (get %x 0) "%")						; "%_"
										 (= (len %x) 2)))
									args))
		(setv args (filter (fn [%x] (and (.isdigit (get %x 1))					; "%1..%9"
										 (!= "0" (get %x 1))))
									args))
		(setv args (sorted args))
		(if (= (len args) 0)
			(setv maxN 0)
			(setv maxN (int (get args -1 -1))))
		;
		(setv inputs (lfor n (thru 1 maxN) (hy.models.Symbol f"%{n}")))
		; (print (hy.repr `(fn [~@inputs] ~expr)))
		(return `(fn [~@inputs] ~expr)))

	(defmacro f> [lambda_def #* args]
		(return `((fm ~lambda_def) ~@args)))

    (defmacro lmapm [one_shot_fm #* args]
		(return `(list (map (fm ~one_shot_fm) ~@args))))


; ________________________________________________________________________/ }}}2
; ■ lns ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

	(defmacro lns [#* macro_args]
		(import hyrule [rest])
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
; ■ &+, &+>, l>, l>= ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

	; compose lens, add setters/getters

	(defmacro &+ [#* macro_args]
		(import hyrule [rest butlast])
		;
		(setv lenses (butlast macro_args))
		(setv func	 (get macro_args (- 1)))
	   `(& ~@lenses (lns ~func)))

	; compose lens, add setters/getters, apply

	(defmacro &+> [#* macro_args]
		(import hyrule [rest butlast])
		;
		(setv variable (get macro_args 0))
		(setv lenses   (butlast (rest macro_args)))
		(setv func	   (get macro_args (- 1)))
	   `((& ~@lenses (lns ~func)) ~variable))

	; construct lens, apply:

	(defmacro l> [#* macro_args]
		(import hyrule [rest])
		;
		(setv variable	  (get macro_args 0))
		(setv lenses_args (rest macro_args))
	   `((lns ~@lenses_args) ~variable))

	(defmacro l>= [#* macro_args]
		(import  hyrule [rest])
		;
		(setv variable	  (get macro_args 0))
		(setv lenses_args (rest macro_args))
	   `(&= ~variable (lns ~@lenses_args)))

; ________________________________________________________________________/ }}}2


; _____________________________________________________________________________/ }}}1
    
