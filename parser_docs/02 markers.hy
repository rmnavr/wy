
; macros in hy ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

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

    ; «↓» is indent 1
    ; «.» is indent 2

        bgnM	midOpen midSplit    ; seen as
        ---     ---     --------

        ↓
        : .	    :	    ::		;  (    
        L .	    L	    LL		;  [ 
        C .	    C  	    		;  { 
        #: .    #: 	    		; #( 
        #C .    #C 	    		; #{ 

        ↓
        #m: . 	#m:			    ; #m(

        ↓
        ': .    ': 	    		; '(
        'L .    'L 	    		; '[
        'C .    'C 	    		; '{
        '#:	.   '#:	    		; '#(
        '#C	.   '#C	    		; '#{

        ~: .    ~: 	    		; ~(
        ~L .    ~L 	    		; ~[
        ~C .    ~C 	    		; ~{
        ~#: .   ~#:	    		; ~#(
        ~#C .   ~#C	    		; ~#{

        ~@: .   ~: 	    		; ~(
        ~@L .   ~L 	    		; ~[
        ~@C .   ~C 	    		; ~{
        ~@#: .  ~#:	    		; ~#(
        ~@#C .  ~#C	    		; ~#{

        `: .	`: 	    		; `(
        `L .	`L 	    		; `[
        `C .	`C 	    		; `{
        `#: .	`#:	    		; `#(
        `#C .	`#C	    		; `#{

    ; «↓» is indent 1

        ↓
       \ 				        ; continuator          ↓
        1                       ; essentially seen as \1
        "string"                ; essentially seen as \"string"
        '      			        ; essentially seen as \'
        `      			        ; essentially seen as \`
        ~                       ; essentially seen as \~
        ~@                      ; essentially seen as \~@

