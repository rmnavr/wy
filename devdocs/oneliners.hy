
; 1 ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1

    1   ,   joiner
    2   :   starter_bracket_opener
    3   <$  reverse applicator
    4   $   forward applicator
    5   :   mid_bracket_opener
    6   ::  
    +   \   continuator

    print : f :  g x :  h y  | (print (f (g x (h y))))
    print : f :: g x :: h y  | (print (f) (g x) (h y))
    print : f ,  g x ,  h y  | (print (f)) (g x) (h y)
    print : f <$ g x <$ h y  | (((print (f)) (g x)) (h y))
    print : f $  g x $  h y  | (print (f) (g x (h y)))



  : : : : f x : z  | <$
	        0
	      1
		2
      3
	
	: : : : f x : z  | ,
	y
  
	: : : : f x : z  | $
	  y

	: : : : f x $ z <$ k , t

  :
	  : : : : f x
	    z
		k
	t

	L L L 1 2
	    L 6 4
		L L C\x 3
		     \y 3
				C\x 7
		  L 2 3



; _____________________________________________________________________________/ }}}1

    ;   + (...) is recognized as normal hy code (and any other brackets), even multiline
    ;   + do I want indents on all Ls to be recognized? : L lmapm L pups L -> can be implemented later (for more consise code)

    $  ; closes all m-markers, all : L C and such
       ; can be also used on \-lines
       ; does not mess with s-markers



        f x : y L 1 2 3 $ + x 3
        (f x (y [1 2 3]) (+ x 3))

       \f x : y L 1 2 3 $ 3
        f x (y [1 2 3]) 3

        : f : x1 : x2 $ : y1 : y2 $ z

        : f : x1 : x2
          : y1 : y2
            z

        : f : x <$ : y1 : y2 <$ z

        : : : f : x
            : y1 : y 2
          z

        L Monad x <$ 3 <$ 4
          5

        L
          :
            :
              Monad x
              3
            4
          5


    <$ ; closes on +1 level and applicates
       ; can be also used on \-lines
       ; does not mess with s-markers

        f x <$ \y <$ \z
        (((f x) y) z)

       \f <$ \x y <$ \z
        ((f x y) z)

    ,  ; option a: can't be used on s-marker lines; option b: there can't be indent after them
       ; can be also used on \-lines
       ; does not mess with s-markers

        : p: abs neg str , L x y z

        : p: abs neg str
          L x y z

    \  ; can only be used at: 
       ;                     after ,
       ;               after <$    |
       ;          after $     |    |
       ;after last s:   |     |    |
       ;   |            |     |    |
       ;   ↓            ↓     ↓    ↓     
        : :\f x : x 3 $ \x <$ \y , \z , L 3 4 5

        : :
           \f x : x 3 $ \x <$ \y
           \z
            L 3 4 5

    f <$ x <$ y
    (((f) x) y)

    : : f : m1 $ : x : m2 $ y : m3
        z1 
      z2

    f : m1
        : x : m2
          y : m3

    L Monad x : y $ z1 : z2 <$ L : t1 : t2 $ 14 : x $ : y <$ 15

    L : : Monad x : y
            z1 : z2 
          L : t1 : t2
            14 : x
                : y
        15

    ·······························

    one-liners precendence:
    :   ; line-starters
    <$  ; (() arg)
    $   ; + virtual indent
    ,   ; same level
    :   ; mid-openers
    ::  ; ...

    Approach 1: expand grammar
    Approach 2: no expand, work inline

    lmapm : fn [x y] : + x y $ L \x y z

    : \lmapm , fn L x y $ + x y , L \x y z

    lmapm $ fn [x y] : + x y , L \x y z 

    lmapm
        fn [x y] : + x y
        [x y z]

    lmapm $ fn [x y] : + x y , print x , range_ 1 3 , 15

    . lens [1] [2] <$ \xs
    : . lens [1] [2] , \xs
    : . lens [1] [2] $ \xs


    : . lens [1] [2] (call_mut "sort") $ : print : f x , sum 5 <$ z

    : : . lens [1] [2] (call_mut "sort")
            : print : f x
            sum 5
        z


    f : g x $ lmapm (fm %1) [x y z] , 3 <$ 5

    lmapm
        fn [x y] : + x y , L \x y z

    : \lmapm , fn L x y $ + x y , L \x y z
       3

    -> t
       + x , - 3
       * 2 , / 7
      \x   ,\y


