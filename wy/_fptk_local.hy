
    ; this file is fptk 0.2.0 (it is here to have stable version)

    (require hyrule [comment])

; [GROUP] Import Full Modules ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import sys)                #_ "py base module"

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

; _____________________________________________________________________________/ }}}1
; [GROUP] Typing ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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
    (import pydantic    [validate_arguments :as validate_args]) ;;

    #_ "Int or Float"
    (setv StrictNumber (get Union #(StrictInt StrictFloat)))

    (import returns.result  [Result])
    (import returns.result  [Success])
    (import returns.result  [Failure])

    (import funcy [isnone])
    (import funcy [notnone])

; _____________________________________________________________________________/ }}}1
; [GROUP] Getters ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import  lenses [lens])

    ;; dub basics:

        (comment "hy     | macro | .     | (. xs [n1] [n2] ...) -> xs[n1][n2]... | throws error when not found")
        (comment "hy     | macro | get   | (get xs n #* keys) -> xs[n][key1]... | throws error when not found")
        (comment "hy     | macro | cut   | (cut xs start end step) -> (get xs (slice start end step)) -> List | gives empty list when none found")
        (import  hyrule [ assoc ])  #_ "(assoc xs k1 v1 k2 v2) -> (setv (get xs k1) v1 (get xs k2) v2) -> None | also possible: (assoc xs :x 1)"
        (require hyrule [ ncut ])   

    ;; one elem getters:

        (import funcy [nth])        #_ "nth(n, xs) | 0-based index; works also with dicts"
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
        (import  funcy  [lpluck_attr])  #_ "lpluck(attr_str, xs)" ;;

; _____________________________________________________________________________/ }}}1

; [GROUP] Control flow ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (comment "hy | base | if   | (if check true false)          | ")
    (comment "hy | base | cond | (cond check1 do1 ... true doT) | ")

    (require hyrule [case])
    (require hyrule [branch])
    (require hyrule [unless])
    (require hyrule [lif])

; _____________________________________________________________________________/ }}}1

; [GROUP] Compositions ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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
    (import funcy   [rcompose]) ;;

    #_ "ljuxt(f,g,...) = [f, g] applicator |"
    (import funcy [ljuxt])

    #_ "flip(f, a, b) = f(b, a) | example: (flip lmap [1 2 3] sqrt)"
    (defn flip [f a b] (f b a))

    #_ "pflip(f, a) = f(_, a) partial applicator | example: (lmap (pflip div 0.1) (thru 1 3))"
    (defn pflip [f a] (fn [%x] (f %x a)))

; _____________________________________________________________________________/ }}}1
; [GROUP] APL: n-applicators ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (require hyrule [do_n])     #_ "(do_n   n #* body) -> None |"
    (require hyrule [list_n])   #_ "(list_n n #* body) -> List |"

    #_ "nest(n, f) | f(f(f(...f)))"
    (defn nest [n f] (compose #* (list_n n f)))

    #_ "apply_n(n, f, *args, **kwargs) | f(f(f(...f(*args, **kwargs))"
    (defn apply_n [n f #* args #** kwargs] ((compose #* (list_n n f)) #* args #** kwargs))

; _____________________________________________________________________________/ }}}1
; [GROUP] APL: Threading ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (comment "py | base | map | map(f, *xss) -> iterator | ")
    (import funcy     [lmap])       #_ "lmap(f, *xss) -> List"
    (import itertools [starmap])    #_ "starmap(f, xs)" ;;

    #_ "lstarmap(f,xs) -> List |"
    (defn lstarmap [f xs] (list (starmap f xs)))

    (import functools [reduce])  #_ "reduce(f, xs[, x0]) -> value | reduce + monoid = binary-function for free becomes n-arg-function"

    (comment "py | base | zip | zip(*xss) -> iterator I guess | ")
    
    #_ "lzip(*xss) = list(zip(*xss)) |"
    (defn lzip [#* args] (list (zip #* args)))

; _____________________________________________________________________________/ }}}1
; [GROUP] APL: Filtering ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (comment "py | base | filter | filter(f or None, xs) -> filter object | when f=None, checks if elems are True")
    (import funcy [lfilter]) #_ "lfilter(f, xs) -> List"

    #_ "fltr1st(f, xs) -> Optional elem | returns first found element (or None)"
    (defn fltr1st [f xs] (next (gfor &x xs :if (f &x) &x) None))

    #_ "count_occurrences(elem, xs) -> int | rename of list.count method"
    (defn count_occurrences [elem container] (container.count elem))

; _____________________________________________________________________________/ }}}1
; [GROUP] APL: Work on lists ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import hyrule     [thru])      #_ "same as range, but with 1-based index"

    (import hyrule     [flatten])   #_ "flattens to the bottom" ;;

    #_ "lprint(lst) -> (lmap print lst) |"
    (defn lprint [lst] (lmap print lst) (return None))

    (comment "py | base | reversed | reversed(xs) -> iterator |") 

    #_ "lreversed(*args) = list(reversed(*args)) |"
    (defn lreversed [xs] (list (reversed xs)))

; _____________________________________________________________________________/ }}}1

; [GROUP] General Math ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import hyrule    [inc])
    (import hyrule    [dec])
    (import hyrule    [sign])
    (import operator  [neg])

    (defn half       [x] (/ x 2))
    (defn double     [x] (* x 2))

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

; _____________________________________________________________________________/ }}}1
; [GROUP] Trigonometry ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import math [pi])
    (import math [sin])
    (import math [cos])
    (import math [tan])
    (import math [degrees])
    (import math [radians])
    (import math [acos])
    (import math [asin])
    (import math [atan])
    (import math [atan2]) #_ "atan2(y,x) -> value | both signs are considered"
    (import math [sin])

; _____________________________________________________________________________/ }}}1
; [GROUP] Funcs from base operators ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    #_ "minus(x, y) = x - y"
    (defn minus   [x y] (- x y))

    ;; *

        #_ "mul(*args) = arg1 * arg2 * ... | rename of * operator, underlines usage for numbers"
        (defn mul     [#* args] (* #* args))

        #_ "lmul(*args) = arg1 * arg2 * ... | rename of * operator, underlines usage for strings"
        (defn lmul    [#* args] (* #* args))

        #_ "smul(*args) = arg1 * arg2 * ... | rename of * operator, underlines usage for lists"
        (defn smul    [#* args] (* #* args))

    ;; +

        #_ "plus(*args) = arg1 + arg2 + ... | rename of + operator, underlines usage for numbers"
        (defn plus    [#* args] (+ #* args))

        #_ "sconcat(*args) = arg1 + arg2 + ... | rename of + operator, underlines usage for strings"
        (defn sconcat [#* args] (+ #* args))

        #_ "lconcat(*args) = arg1 + arg2 + ... | rename of + operator, underlines usage for lists"
        (defn lconcat [#* args] (if (= (len args) 1) (first args) (+ #* args)))

; _____________________________________________________________________________/ }}}1
; [GROUP] Logic and ChecksQ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import hyrule   [xor])

    (import operator [eq])              #_ "equal"
    (import operator [ne :as neq])      #_ "non-equal"
    (import funcy    [even :as evenQ])
    (import funcy    [odd  :as oddQ])   ;;

    #_ "checks directly via (= x 0)"
    (defn zeroQ     [x] (= x 0))

    #_ "checks directly via (< x 0)"
    (defn negativeQ [x] (< x 0))

    #_ "checks directly via (> x 0)"
    (defn positiveQ [x] (> x 0))

    #_ "checks literally if (= (len xs) 0)"
    (defn zerolenQ [xs] (= (len xs) 0))

    #_ "not_(f, *args, **kwargs) = not(f(*args, **kwargs)) | "
    (defn not_ [f #* args #** kwargs] (not (f #* args #** kwargs)))

; _____________________________________________________________________________/ }}}1

; [GROUP] Strings ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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

; _____________________________________________________________________________/ }}}1
; [GROUP] Regex ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ;; Theory:
    ;;      re: match, search, findall, finditer, split, compile, fullmatch, escape
    ;;      non-escaped (commands):   .  ^  $  *  +  ? {2,4} [abc]      ( | )
    ;;      escaped (literals):      \. \^ \$ \* \+ \? \{ \} $$_bracket $_parenthesis \| \\ \' \"
    ;;      special:                 \d \D \w \W \s \S \b \B \n \r \f \v
    ;;      raw strings:             r"\d+" = "\\d+"

    (import re        [sub :as re_sub])         #_ "re_sub(rpattern, replacement, string, count=0, flags=0) |"
    (import re        [split :as re_split])     #_ "re_split(rpattern, string) |"
    (import funcy     [re_find])                #_ "re_find(rpattern, string, flags=0) -> str| returns first found"
    (import funcy     [re_test])                #_ "re_test(rpattern, string, ...) -> bool | tests string has match (not neccessarily whole string)"
    (import funcy     [re_all])                 #_ "re_all(rpattern, string, ...) -> List |"

; _____________________________________________________________________________/ }}}1
; [GROUP] Random ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import random    [choice])                 #_ "choice(xs) -> Elem | throws error for empty list"
    (import random    [randint])                #_ "randint(a, b) -> int | returns random integer in range [a, b] including both end points" 
    (import random    [uniform :as randfloat])  #_ "randfloat(a, b) -> float | range is [a, b) or [a, b] depending on rounding"
    (import random    [random :as rand01])      #_ "rand01() -> float in interval [0, 1) | "

    ;; shuffle — is mutating

; _____________________________________________________________________________/ }}}1

; [GROUP] Benchmarking ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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
        (setv _count hy.I.time.perf_counter)
        (setv n (int n))
        ;;
        (setv t0 (_count))
        (setv _outp (f))
        (do_n (dec n) (f))
        (setv t1 (_count))
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

    ;; (print (execution_time :n 100 (fn [] (get [1 2 3] 1))))

; _____________________________________________________________________________/ }}}1

	; === Macroses ===

; neg integer expr ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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

; _____________________________________________________________________________/ }}}1
; expr with head symbol ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

	; (head ...)
	(-> (defn _isExprWithHeadSymbol
			[ #^ hy.models.Expression arg
			  #^ str head
			]
			(and (= (type arg) hy.models.Expression)
				 (= (get arg 0) (hy.models.Symbol head))))
		eval_and_compile)

; _____________________________________________________________________________/ }}}1

; DEVDOC: Dot Macro Expressions ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1
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
; _____________________________________________________________________________/ }}}1
; .dottedAttr ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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

; _____________________________________________________________________________/ }}}1
; .dottedAccess ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

	; operator.add
	(-> (defn _isDottedAccess
			[ arg
			]
			(and (= (type arg) hy.models.Expression)
				 (= (get arg 0) (hy.models.Symbol "."))
				 (= (type (get arg 1)) hy.models.Symbol)
				 (!= (get arg 1) (hy.models.Symbol "None"))))
		eval_and_compile)

; _____________________________________________________________________________/ }}}1
; .dottedMth ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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

; _____________________________________________________________________________/ }}}1
; [ARCHIVE] :attr: ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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

; _____________________________________________________________________________/ }}}1

; f:: ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

	(defmacro f:: [#* macro_args]
		;
		(setv fInputsOutputs (get macro_args (slice None None 2)))
		(setv fInputs (get fInputsOutputs (slice 0 (- 1))))
		(setv fOutput (get fInputsOutputs (- 1)))
		`(of Callable ~fInputs ~fOutput))

; _____________________________________________________________________________/ }}}1
; p> ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

; ■ comment on (.mth 3 4) deconstruction ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

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

; ________________________________________________________________________/ }}}2

	; .attr				; [. None attr]			; _isDottedAttr   checks for: [. None _]
	; (.mth 1 2)		; [[. None mth] 1 2]	; _isDottedMth	  checks for: [[. None _] _]
	; operator.neg		; [. operator neg]		; _idDottetAccess checks for: [. smth _]
	; (operator.add 3)	; [[. operator add] 3]

    (defn flip [f a b] (f b a))                   ; (flip lmap [1 2 3] sqrt)

	(defmacro p> [#* args]
		;
		(setv pargs [])
		(for [&arg args]
			  (cond ; .x  -> (partial flip getattr "x")
					(_isDottedAttr &arg)
					(pargs.append `(partial flip getattr ~(str (_extractDottedAttr &arg))))
					; operator.neg
					(_isDottedAccess &arg)
					(pargs.append `(partial ~&arg))
					; (. mth 2 3) -> essentially (. obj mth 2 3)
					(_isDottedMth &arg)
					(do (pargs.append `(partial flip getattr
											~(str (get (_extractDottedMth &arg) "head")))) ; -> mth)
						(pargs.append `(partial (fn [%args %mth] (%mth (unpack_iterable  %args)))
												[~@(get (_extractDottedMth &arg) "args")])))
					; abs -> (partial abs)
					(= (type &arg) hy.models.Symbol)
					(pargs.append `(partial ~&arg))
					; (func 1 2) -> (partial func 1 2)
					; (operator.add 3) -> (partial operator.add 3)
					(= (type &arg) hy.models.Expression)
					(pargs.append `(partial ~@(cut &arg 0 None)))
					; etc -> no change
					True
					(pargs.append `(partial ~&arg))))
	   `(rcompose ~@pargs))

; _____________________________________________________________________________/ }}}1
; pluckm ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

	(defmacro pluckm [indx iterable]
		(cond ; .attr -> attr
			  (_isDottedAttr indx)
			  (return `(lpluck_attr ~(str (_extractDottedAttr indx)) ~iterable))
			  ;
			  True
			  (return `(lpluck ~indx ~iterable))))

; _____________________________________________________________________________/ }}}1
; #L (rename of hyrule #% macro) ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

	(defreader L
	  (import hyrule [flatten inc])
	  ;
	  (setv expr (.parse-one-form &reader))
	  (setv %symbols (sfor a (flatten [expr])
						   :if (and (isinstance a hy.models.Symbol)
									(.startswith a '%))
						   (-> a
							   (.split "." :maxsplit 1)
							   (get 0)
							   (cut 1 None))))
	  `(fn [;; generate all %i symbols up to the maximum found in expr
			~@(gfor i (range 1 (-> (lfor a %symbols
										 :if (.isdigit a)
										 (int a))
								   (or #(0))
								   max
								   inc))
					(hy.models.Symbol (+ "%" (str i))))
			;; generate the #* parameter only if '%* is present in expr
			~@(when (in "*" %symbols)
					'(#* %*))
			;; similarly for #** and %**
			~@(when (in "**" %symbols)
					'(#** %**))]
		 ~expr))

; _____________________________________________________________________________/ }}}1
; fm, f> ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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
			(setv maxN (int (get args (- 1) (- 1)))))
		;
		(setv inputs (lfor n (thru 1 maxN) (hy.models.Symbol f"%{n}")))
		; (print (hy.repr `(fn [~@inputs] ~expr)))
		(return `(fn [~@inputs] ~expr)))

	(defmacro f> [lambda_def #* args]
		(return `((fm ~lambda_def) ~@args)))

; _____________________________________________________________________________/ }}}1
; lns ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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

; _____________________________________________________________________________/ }}}1
; &+, &+>, l>, l>= ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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

; _____________________________________________________________________________/ }}}1

