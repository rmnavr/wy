    
    defn _macro2 LL bubr
        L\#^ bool testQ
         \#^ str  msg
         \#* lines
        when testQ
            print "==" msg "=="
            lmap : fn [%x] : print ">" %x
                 lines
            print ""
