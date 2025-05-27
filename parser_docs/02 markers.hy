
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

    ; «↓» is position of indent 1
    ; «x» is position of indent 2

        bgnM	midOpen midSplit    ; seen as
        ---     ---     --------

        ↓
        : x	    :	    ::		;  (    
        L x	    L	    LL		;  [ 
        C x	    C  	    		;  { 
        #: x    #: 	    		; #( 
        #C x    #C 	    		; #{ 

        ↓
        #m: x 	#m:			    ; #m(

        ↓
        ': x    ': 	    		; '(
        'L x    'L 	    		; '[
        'C x    'C 	    		; '{
        '#:	x   '#:	    		; '#(
        '#C	x   '#C	    		; '#{

        ~: x    ~: 	    		; ~(
        ~L x    ~L 	    		; ~[
        ~C x    ~C 	    		; ~{
        ~#: x   ~#:	    		; ~#(
        ~#C x   ~#C	    		; ~#{

        ~@: x   ~: 	    		; ~(
        ~@L x   ~L 	    		; ~[
        ~@C x   ~C 	    		; ~{
        ~@#: x  ~#:	    		; ~#(
        ~@#C x  ~#C	    		; ~#{

        `: x	`: 	    		; `(
        `L x	`L 	    		; `[
        `C x	`C 	    		; `{
        `#: x	`#:	    		; `#(
        `#C x	`#C	    		; `#{

    ; «↓» is indent 1

        ↓

        1                       ; regarged as continuator
        .1                      ; regarged as continuator
        "string"                ; regarded as continuator

       \ 				        ; continuator          
        '      			        ; continuator
        `      			        ; continuator
        ~                       ; continuator
        ~@                      ; continuator

