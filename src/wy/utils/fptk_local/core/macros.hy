
; Import, Export ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

	(import  wy.utils.fptk_local.core.from_hyrule [rest butlast flatten])
	(require wy.utils.fptk_local.core.from_hyrule [-> ->> of comment])
	(import  operator)

    (export :macros [ def:: f::
                      fm f> mapm lmapm filterm lfilterm
                      => =>> p:
                      pluckm lpluckm getattrm
                      lns &+ &+> l> l>=
                      timing assertm gives_error_typeQ
                    ])

; _____________________________________________________________________________/ }}}1

; === Helpers (precompiled functions) ===

; INFO: Dot Macro Expressions ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1
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
; Info on importing ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

	; when only importing (import wy.utils.fptk_local [f>]), f> is required to have fm internally, and it can be called as:
	; 
	; -> hy.R.wy.utils.fptk_local.fm				-> ✗ does not work in dev file
	;								   ✓ works from outside projs (it is essentially call to installed lib)
	;								   ✓ this is how it is done in hyrule (I think this is due to their hy_init.hy importing everything)
	;										 
	;	 fm							-> [✓ ✗] works from dev file
	;	 hy.R.wy.utils.fptk_local_macros.fm		-> [✓ ✗] works from dev file
	;	 hy.R.wy.utils.fptk_local.wy.utils.fptk_local_macros.fm	-> [✗ ✗] does not work anywhere

; _____________________________________________________________________________/ }}}1
; 
; expr type checkers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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

; _____________________________________________________________________________/ }}}1
;
; [ARCHIVE] ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

	; leftover from lns macro:

        ;(_isAttrAccess &arg)
        ;(setv (get args &i) (hy.models.Symbol (_extractAttrName &arg)))

	; leftover from pluckm macro:

        ; (_isAttrAccess indx)
        ; (return `(lpluck_attr ~(_extractAttrName indx) ~iterable)))

    ; :attr:

        ;(-> (defn #^ bool
        ;		_isAttrAccess
        ;		[ arg
        ;		]
        ;		(setv arg_str (str arg))
        ;		(and (= (type arg) hy.models.Keyword)
        ;			 (> (len arg_str) 2)
        ;			 (= (get arg_str (- 1)) ":")))
        ;	eval_and_compile)

        ;(-> (defn #^ str
        ;		_extractAttrName
        ;		[ arg
        ;		]
        ;		(cut (str arg) 1 (- 1)))
        ;	eval_and_compile)

    ; f>

        ;(defmacro f> [lambda_def #* args]
        ;	(return `((hy.R.wy.utils.fptk_local.fm ~lambda_def) ~@args)))

; _____________________________________________________________________________/ }}}1

; === Macros ===

; def:: ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

; ■ info ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

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

; ________________________________________________________________________/ }}}2

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

; _____________________________________________________________________________/ }}}1
; f:: ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

	(defmacro f:: [#* macro_args]
		;
		(setv fInputsOutputs (get macro_args (slice None None 2)))
		(setv fInputs (get fInputsOutputs (slice 0 (- 1))))
		(setv fOutput (get fInputsOutputs (- 1)))
		`(of Callable ~fInputs ~fOutput))

; _____________________________________________________________________________/ }}}1
; fm, f>, (l)mapm, (l)filterm ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

	(defmacro fm [#* exprs]
		(setv itargs (->> exprs
						  flatten
						  (filter (fn [%x] (= %x 'it)))
						  sorted))	; example: [hy.models.Symbol('it')]
		(setv pargs  (->> exprs
						  flatten
						  (filter (fn [%x] (or (= %x '%1) (= %x '%2) (= %x '%3)
											   (= %x '%4) (= %x '%5) (= %x '%6)
											   (= %x '%7) (= %x '%8) (= %x '%9))))
						  sorted))	; example: [hy.models.Symbol('%1'), hy.models.Symbol('%2')]
		(setv has_pargs (> (len pargs ) 0))
		(setv has_itarg (> (len itargs) 0))
		;
		(when (and has_itarg has_pargs) (raise (SyntaxError "cannot mix 'it' and '%n' syntax in fm macro"))) ; both "it" and "%1"... are found
		(when has_itarg (return `(fn [it] ~@exprs)))	; only "it" are found
		(if has_pargs
			(setv maxN (int (get pargs -1 -1)))		; only "%1"... args are found
			(setv maxN 0))							; no args are found
		(setv inputs (lfor n (range 1 (+ maxN 1)) (hy.models.Symbol f"%{n}")))
		(return `(fn [~@inputs] ~@exprs)))

	(defmacro f> [one_shot_fm #* args]
		(return `((fm ~one_shot_fm) ~@args)))

	(defmacro mapm [one_shot_fm #* args]
		(return `(map (fm ~one_shot_fm) ~@args)))

	(defmacro lmapm [one_shot_fm #* args]
		(return `(list (map (fm ~one_shot_fm) ~@args))))

	(defmacro filterm [one_shot_fm iterable]
		(return `(filter (fm ~one_shot_fm) ~iterable)))

	(defmacro lfilterm [one_shot_fm iterable]
		(return `(list (filter (fm ~one_shot_fm) ~iterable))))

; _____________________________________________________________________________/ }}}1
; =>, =>> ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    ;'3              ; new       hy.models.Integer 
    ;'"key"          ; new       hy.models.String
    ;'[smth]         ; new       hy.models.List
    ;
    ;'func           ;           hy.models.Symbol
    ;'.attr          ; new       _isDottedAttr    _extractDottedAttr
    ;'(.mth)         ;           _isDottedMth     _extractDottedMth
    ;'op.neg         ;           _isDottedAccess
    ;'(op.neg 1 2)   ;           hy.models.Expression
    ;'(func 1 2)     ;           hy.models.Expression
    ;
    ;'(f> (print it)); special recognition: =>> doesn't require special; => places args at the end (i.e. not right after f>)

    (defmacro => [head #* args]
        (setv outp head)  ; obj
		(for [&arg args]
			  (cond ; 1
                    (= (type &arg) hy.models.Integer)
					(setv outp `(get ~outp ~&arg))
                    ; "key"
                    (= (type &arg) hy.models.String)
					(setv outp `(get ~outp ~&arg))
                    ; func
                    (= (type &arg) hy.models.Symbol)
					(setv outp `(~&arg ~outp))
                    ; [3] ["key"]
                    (= (type &arg) hy.models.List)
                    (setv outp `(get ~outp ~@&arg))
                    ; .x 
					(_isDottedAttr &arg)
                    (setv outp `(. ~outp ~(_extractDottedAttr &arg)))
					; (.mth 2 3) 
					(_isDottedMth &arg)
                    (do (setv nm (get (_extractDottedMth &arg) "head")) 
                        (setv ag (get (_extractDottedMth &arg) "args"))
                        (setv outp `(. ~outp (~nm ~@ag))))
					; operator.neg 
					(_isDottedAccess &arg) 
					(setv outp `(~&arg ~outp))
                    ; (f> (print it))
                    (_isExprWithHeadSymbol &arg "f>")
                    (do (setv nm (get &arg 0))
                        (setv ag (cut &arg 1 None))
                        (setv outp `(~nm ~@ag ~outp)))  
					; '(smth arg1 arg2) ; also works for: (op.neg arg1 arg2)
                    (= (type &arg) hy.models.Expression) ; should be checked almost last, because _isDotted... are Exprs too
                    (do (setv nm (get &arg 0))
                        (setv ag (cut &arg 1 None))
                        (setv outp `(~nm ~outp ~@ag)))
                    ; normally never executed:
                    True 
					(setv outp `(~&arg ~outp))))
        (return outp))

    (defmacro =>> [head #* args]
        (setv outp head)  ; obj
		(for [&arg args]
			  (cond ; 1
                    (= (type &arg) hy.models.Integer)
					(setv outp `(get ~outp ~&arg))
                    ; "key"
                    (= (type &arg) hy.models.String)
					(setv outp `(get ~outp ~&arg))
                    ; func
                    (= (type &arg) hy.models.Symbol)
					(setv outp `(~&arg ~outp))
                    ; [3] ["key"]
                    (= (type &arg) hy.models.List)
                    (setv outp `(get ~outp ~@&arg))
                    ; .x 
					(_isDottedAttr &arg)
                    (setv outp `(. ~outp ~(_extractDottedAttr &arg)))
					; (.mth 2 3) 
					(_isDottedMth &arg)
                    (do (setv nm (get (_extractDottedMth &arg) "head")) 
                        (setv ag (get (_extractDottedMth &arg) "args"))
                        (setv outp `(. ~outp (~nm ~@ag))))
					; operator.neg 
					(_isDottedAccess &arg) 
					(setv outp `(~&arg ~outp))
					; '(smth arg1 arg2) ; also works for: (op.neg arg1 arg2)
                    (= (type &arg) hy.models.Expression) ; should be checked almost last, because _isDotted... are Exprs too
                    (do (setv nm (get &arg 0))
                        (setv ag (cut &arg 1 None))
                        (setv outp `(~nm ~@ag ~outp)))  
                    ; normally never executed:
                    True 
					(setv outp `(~&arg ~outp))))
        (return outp))

; _____________________________________________________________________________/ }}}1
; p: ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

; ■ comment on (.mth 3 4) reassembly into partial ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2

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

	(defmacro p: [#* args]
		(setv pargs [])
		(for [&arg args]
			  (cond ; 1
                    (= (type &arg) hy.models.Integer)
					(pargs.append `(hy.I.funcy.partial (fn [x] (get x ~&arg))))
                    ; "key"
                    (= (type &arg) hy.models.String)
					(pargs.append `(hy.I.funcy.partial (fn [x] (get x ~&arg))))
                    ; [3] ["key"]
                    (= (type &arg) hy.models.List)
                    (pargs.append `(hy.I.funcy.partial (fn [x] (get x ~@&arg))))
                    ; .x  -> (partial flip getattr "x")
					(_isDottedAttr &arg)
					(pargs.append `(hy.I.funcy.partial (fn [x] (getattr x ~(str (_extractDottedAttr &arg))))))
					; operator.neg
					(_isDottedAccess &arg)
					(pargs.append `(hy.I.funcy.partial ~&arg))
					; (. mth 2 3) -> essentially (. SLOT mth 2 3)
					(_isDottedMth &arg)
					(do (pargs.append `(hy.I.funcy.partial (fn [f x y] (f y x)) getattr
											~(str (get (_extractDottedMth &arg) "head")))) ; -> mth)
						(pargs.append `(hy.I.funcy.partial (fn [%args %mth] (%mth (unpack_iterable	%args)))
												[~@(get (_extractDottedMth &arg) "args")])))
					; function -> (partial function)
					(= (type &arg) hy.models.Symbol)
					(pargs.append `(hy.I.funcy.partial ~&arg))
                    ; f>
					(_isExprWithHeadSymbol &arg "f>") 
					(do (setv body (get &arg 1))
                        (setv ags  (cut &arg 2 None))
                        (pargs.append `(hy.I.funcy.partial (fm ~body) ~@ags)))
					; (func 1 2)       -> (partial func 1 2)
					; (operator.add 3) -> (partial operator.add 3)
					(= (type &arg) hy.models.Expression)
					(pargs.append `(hy.I.funcy.partial ~@(cut &arg 0 None)))
					; normally should never be called:
					True
					(pargs.append `(hy.I.funcy.partial ~&arg))))
	   `(hy.I.funcy.rcompose ~@pargs))

; _____________________________________________________________________________/ }}}1
; (l)pluckm, getattrm ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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

; _____________________________________________________________________________/ }}}1
; lns ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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
; &+ &+> l> l>= ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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

; _____________________________________________________________________________/ }}}1
; assertm, gives_error_typeQ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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

    ;; test:
    ;; (assertm eq (div 2 0) (div 1 0))
    ;; (assertm eq 1 (div 1 0))
    ;; (assertm eq (div 1 0) 1)

	(defmacro gives_error_typeQ [expr error_type]
	   `(try ~expr
			 False
			 (except [e Exception]
					 (= ~error_type (type e)))))

; _____________________________________________________________________________/ }}}1
; timing ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    (defmacro timing [#* exprs]
        `(do (setv _time_getter hy.I.time.perf_counter)
             (setv f (fn [] ~@exprs))
             (setv t0 (_time_getter))
             (setv outp (f))
             (setv t1 (_time_getter))
             #((- t1 t0) outp)))

; _____________________________________________________________________________/ }}}1


