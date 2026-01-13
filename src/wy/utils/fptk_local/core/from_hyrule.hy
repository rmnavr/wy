
    ; this is limited set of funcs/macros from hyrule 1.0.1 library (with minimal changes);
    ; required to speed up startup time of fptk lib

; Import, Export ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (import itertools       [islice tee])
    (import collections.abc [Iterable])

    (export :objects  [ assoc flatten
                        rest butlast ] ;; these are iter-versions, used in from_hyrule.hy and macros.hy, but not in funcs.hy
            :macros   [ of comment
                        ncut
                        case unless lif branch
                        -> ->> as-> doto
                        do_n list_n
                      ])

; _____________________________________________________________________________/ }}}1

; Macrotools ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defmacro def_gensyms [#* symbols]
      `(setv ~@(gfor
        sym symbols
        x [sym `(hy.gensym '~sym)]
        x)))

; _____________________________________________________________________________/ }}}1
; Collections ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn assoc [coll #* kvs #** kwargs]
      "usage: (assoc collection idx value)
       returns None"
      (when (% (len kvs) 2)
        (raise (ValueError "`assoc` takes an odd number of arguments (not counting `#** kwargs`)")))
      (for [[k v] (by2s kvs)]
        (setv (get coll k) v))
      (for [[k v] (.items kwargs)]
        (setv (get coll k) v)))

    (defn by2s [x]
      (setv x (iter x))
      (while True
        (try
          (yield #((next x) (next x)))
          (except [StopIteration]
            (break)))))

    ; ==================================

    (defn rest [coll] (islice coll 1 None))

    (defn butlast [coll]
      (drop_last 1 coll))

    (defn drop_last [n coll]
      (setv [copy1 copy2] (tee coll))
      (gfor [x _] (zip copy1 (islice copy2 n None)) x))

    ; ==================================

    (defmacro ncut [seq key1 #* keys]
      `(get ~seq ~(if keys
                   `#(~@(map _parse_indexing #(key1 #* keys)))
                   (_parse_indexing key1))))

    (defn _parse_indexing [sym]
        (cond
          (and (isinstance sym hy.models.Expression) (= (get sym 0) :))
            `(slice ~@(cut sym 1 None))

          (and (isinstance sym #(hy.models.Keyword hy.models.Symbol))
                (in ":" (str sym)))
            (try
               `(slice ~@(lfor
                 index (.split (str sym) ":")
                 (when index (int index))))
               (except [ValueError] sym))
          True
            sym))

; _____________________________________________________________________________/ }}}1
; Iterables ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defn flatten [coll]
      "recursively flattens"
      (_flatten coll []))

    (defn _flatten [coll result]
      (if (coll? coll)
        (for [x coll]
          (_flatten x result))
        (.append result coll))
      result)

    (defn coll? [x]
      (and
        (isinstance x Iterable)
        (not (isinstance x #(str bytes)))))

; _____________________________________________________________________________/ }}}1
; Argmove ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (eval_and_compile
      (defn _dotted [node]
        "Helper function to turn '.name forms into '(.name) forms"
        (if (and (isinstance node hy.models.Expression)
                 (= (get node 0) '.))
          `(~node)
          node)))

    (defmacro -> [head #* args]
      (setv ret head)
      (for [node args
           :setv node (_dotted node)]
        (setv ret (if (isinstance node hy.models.Expression)
                      `(~(get node 0) ~ret ~@(rest node))
                      `(~node ~ret))))
      ret)

    (defmacro ->> [head #* args]
      (setv ret head)
      (for [node args
           :setv node (_dotted node)]
        (setv ret (if (isinstance node hy.models.Expression)
                      `(~@node ~ret)
                      `(~node ~ret))))
      ret)

    ; ==================================

    (defmacro as-> [head name #* rest]
      `(do (setv
             ~name ~head
             ~@(sum (gfor  x rest [name x]) []))
         ~name))

    (defmacro doto [form #* expressions]
      (def_gensyms f)
      (defn build_form [expression]
        (setv expression (_dotted expression))
        (if (isinstance expression hy.models.Expression)
          `(~(get expression 0) ~f ~@(rest expression))
          `(~expression ~f)))
      `(do
         (setv ~f ~form)
         ~@(map build_form expressions)
         ~f))

; _____________________________________________________________________________/ }}}1
; Control ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defmacro list_n [count-form #* body]
      (def_gensyms l)
      `(do
        (setv ~l [])
        ~(_do-n count-form [`(.append ~l (do ~@body))])
        ~l))

    ;; ================================

    (defmacro unless [test #* body]
      `(when (not ~test) ~@body))

    ;; ================================

    (defmacro case [key #* rest_]
      (_case key rest_))

    (defn _case [key rest_]
      ; The implementation is quite similar to `branch`, but we evaluate
      ; the key exactly once.
      (when (% (len rest_) 2)
        (raise (TypeError "each test-form needs a result-form")))
      (def_gensyms x)
      `(do
        (setv ~x ~key)
        (cond ~@(sum
          (gfor [test-value result] (by2s rest_) [
            (if (= test-value 'else)
              'True
              `(= ~x ~test-value))
            result])
          []))))

    ;; ================================

    (defmacro lif [#* args]
      (_lif args))

    (defn _lif [args]
      (cond
        (= (len args) 1)
          (get args 0)
        args (do
          (setv [condition result #* rest_] args)
          `(if (is_not None ~condition False)
            ~result
            ~(_lif rest_)))))

    ;; ================================

    (defmacro branch [tester #* rest_]
      (_branch tester rest_))

    (defn _branch [tester rest_]
      (when (% (len rest_) 2)
        (raise (TypeError "each case-form needs a result-form")))
      `(let [it None]
        (cond ~@(sum
          (gfor [case result] (by2s rest_) [
            (if (= case 'else)
              'True
              `(do
                (setv it ~case)
                ~tester))
            result])
          []))))

    ;; ================================

    (defmacro do_n [count-form #* body]
      (_do_n count-form body))

    (defn _do_n [count-form body]
      (def_gensyms count)
      `(do
        (setv ~count ~count-form)
        (for [~(hy.gensym)
            (if (= ~count Inf)
              (hy.I.itertools.repeat None)
              (range ~count))]
          ~@body)))

; _____________________________________________________________________________/ }}}1
; Misc ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defmacro of [base #* args]
      (if
        (not args)
        base
        (if (= (len args) 1)
            `(get ~base ~@args)
            `(get ~base #(~@args)))))

    (defmacro comment [#* body] None)

; _____________________________________________________________________________/ }}}1

