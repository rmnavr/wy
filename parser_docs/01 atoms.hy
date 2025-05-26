
    unused      ,

    numbers     1234567890
                -1.2
                1.3e2
                1.3e+2
                1.3E-2
                .3
                10
                -92.3E+3

    skymarks    continuators
                    \ ' ` ~ ~@    

                starters/mid
                    : L C #: #C
                    ': 'L 'C '#: '#C
                    `: `L `C `#: `#C
                    ~: ~L ~C ~#: ~#C
                    ~@: ~@L ~@C ~@#: ~@#C
                    #word: #word:

                doublemid
                    :: LL

    words       ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_
                1234567890
                $.-=+&*<>!/|
                %^?
                f:: p> mth>

    keywords    :pupos

    unpackers   #* #**

    annotation  #^ (of Tuple str str)

    icomment    #_ (ololo)
    ocomment    ; comment ololo

    brackets     (bracket)
                 [bracket]
                 {bracket}
                #(bracket)
                #{bracket}

    string      "olol;22 : o"   
                f"ololo"        ; this means that stringQ token check should be based on last symbol, not on first 
                b"olo\"lo\""
                r"ololo"

