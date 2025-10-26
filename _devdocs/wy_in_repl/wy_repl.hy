
    (import wy [convert_wy2hy])

    ; you just need to replace this example string with actual WY code:
    (hy.eval (hy.read_many (convert_wy2hy "print 3\nprint 4")))
    ; this way you can send it directly to REPL via %%hy with hy-ipython

    ; I actually also make it print converted code:
    (setv __wy (convert_wy2hy "demo code"))
    (print "===WY2HY===")
    (print __wy)
    (print "===========")
    (hy.eval (hy.read_many __wy))


