
; Info: hy.models for macros symbols ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

	; Same for:
	; - '
	; - `
	; - `~
	; - `~@

	1		; Integer
			'1
			'{1} 

	(1)		; Expression
			'(1)

	[1]		; List
			'[1]

	{x}		; Dict
			'{1 2}
			'{x}

	#1		; Reader macro
			'#1
			'#{1}

	#{x}	; Set
			'#{1 2}
			'#{x}

	#(x)	; Tuple
			'#(1)

; _____________________________________________________________________________/ }}}1
; Rules ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

	• HyWy only changes syntax, nothing more
	• If I need new functionality, it shall be done in hy-fptk


	____ seen as smarker ____
	|						|
	↓						↓
	: : . lens 1 2 (Each) $ : : riba
	  ↑						  ↑
	  | seen as mmarker _____ |


	linesplitters:
		: 
		$
		,

        |         ↓‾‾‾‾‾‾‾‾‾↑          ↓‾‾‾‾‾‾‾↑ (1 space is assumed)
    ■■■■|■■■■~@:■\: func $ \arg , ~@: \func $ \arg
        |    ↑___________________|

        |         ↓‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|
    ■■■■|■■■■\lmap : partial abs 3 $ \arg
        |    _____•

; _____________________________________________________________________________/ }}}1

	; terminology:
; All Dev Terms ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

	✠ is «Indent Mark»

	Wy Source code is in [Condensed Grammar] format
	1 Preparator		-> 1) expands Condensed Grammar to [Expanded Grammar]
					  	   2) adds indent marks
					  	   code is now called [Prepared Code]
	2 Parser		  	-> parses Expanded Grammar to [Lines kinds]
	3 Bracketer		  	-> counts brackets based on indent, replaces WYMarkers with HYMarkers

	WYMarkers:
	- OMarkers (opener markers) acting as:
	  - SMarkers (starter markers)	-> splits source line to [GroupStarterL + non-GroupStarterL]
	  - MMarkers (middle markers)  	-> expanded inside line
	- DMarkers (double markers)    	-> expanded inside line
	- CMarkers (cont markers)	   	-> can be used only at line start, currently there is just one cmarker: \
	* AMarkers (appl markers)	   	-> ...

	HYMarkers:
	* CTokens					   	-> HY tokens, that are regarded as linestarter
	- HyOpeners					   	-> same as OMarkers, but with :LC replaced to ([{					

	Lines kinds of Expanded Grammar:
	- GroupStarterL			-> «	 :»				// OMarkers act as SMarkers only at GroupStarterL
	- ContinuationL		  
	  - lines starting with CTokens		-> «	 'x»
	  - lines starting with CMarker   	-> «	\x» 
	- ImpliedOpenerL		-> «func x»			  
	- OnlyOCommentL		  	-> «	 ; comment»		// required because it passes through indent level
	- EmptyL			  	-> « »					// acts as indent closer

}])
; _____________________________________________________________________________/ }}}1
; CMarkers/CTokens ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

	; symbol ↓ marks indent level

	; CMarkers (continuator marker):

					   ↓
	   \anything	-> anything

	; CTokens (when line starts with CToken, line is regarded as continuator):

		↓
		---------	
		1			
		.1			
		"string"	
		:keyword	
		#^			
		#*			
		#**			
		' x			
		` x			
		~ x			
		~@ x		
		( ... x)	
		[ ... x]	
		{ ... x}	
		#( ... x)	
		#{ ... x}	
		; ↑ same for opener brackets with ` ' ` ~@
		)			
		]			
		}			

; _____________________________________________________________________________/ }}}1
; OMarkers (= SM/MM), DMarkers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

	; «↓» is position of indent 1
	; «x» is position of indent 2

	OMs:	OMs:
	as SM	as MM	DMarkers
	---		---		--------	; equiv Hy_Openers

	↓
	: x		:		::			;  (		) (
	L x		L		LL			;  [		] [
	C x		C					;  { 
	#: x	#:					; #( 
	#C x	#C					; #{ 

	↓
	': x	':					; '(
	'L x	'L					; '[
	'C x	'C					; '{
	'#: x	'#:					; '#(
	'#C x	'#C					; '#{

	~: x	~:					; ~(
	~L x	~L					; ~[
	~C x	~C					; ~{
	~#: x	~#:					; ~#(
	~#C x	~#C					; ~#{

	~@: x	~:					; ~(
	~@L x	~L					; ~[
	~@C x	~C					; ~{
	~@#: x	~#:					; ~#(
	~@#C x	~#C					; ~#{

	`: x	`:					; `(
	`L x	`L					; `[
	`C x	`C					; `{
	`#: x	`#:					; `#(
	`#C x	`#C					; `#{

; _____________________________________________________________________________/ }}}1

	; parser:
; Parser Atoms ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

	unused		,

	numbers		1234567890
				-1.2
				1.3e2
				1.3e+2
				1.3E-2
				.3
				10
				-92.3E+3

	wy_markers	omarkers (acting as smarkers/mmarkers):
					: L C #: #C
					': 'L 'C '#: '#C
					`: `L `C `#: `#C
					~: ~L ~C ~#: ~#C
					~@: ~@L ~@C ~@#: ~@#C

				dmarkers:
					:: LL

				continuators:
					\

				hymacro:
					' ` ~@ ~

	brackets	 ( )  ; hy_openers + closers
				 [ ]
				 { }
				#( )
				#{ }

				+ all ` ' ~ ~@ variants

	words		ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_
				1234567890
				$.-=+&*<>!/|
				%^?
                ; some examples:
				f:: p> mth>

	keywords	:pupos

	unpackers	#* #**

	annotation	#^ (of Tuple str str)

	icomment	#_ (ololo)

	ocomment	; comment ololo

	string		"olol;22 : o"	
				f"ololo"		; this means that stringQ token check should be based on last symbol, not on first 
				b"olo\"lo\""
				r"ololo"

; _____________________________________________________________________________/ }}}1

    ; wy in REPL

