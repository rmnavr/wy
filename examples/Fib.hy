
    (import hyrule [thru])
    (require hyrule [->>])
    (import funcy [lmap])

    (defn #^ int
        fibonacci
        [ #^ int n]
        (if (<= n 1)
           n
           (+ (fibonacci (- n 1 ))
               (fibonacci (- n 2)))))

    (print "Result:") (print (->> (thru 1 5) (lmap fibonacci)))

