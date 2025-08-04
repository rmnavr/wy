
---
Documentation:
1. [Syntax overview](https://github.com/rmnavr/wy/blob/main/docs/01_Overview.md)
2. You are here -> [Basic syntax](https://github.com/rmnavr/wy/blob/main/docs/02_Basic.md) 
3. [Condensed syntax](https://github.com/rmnavr/wy/blob/main/docs/03_Condensed.md)
4. [One-liners](https://github.com/rmnavr/wy/blob/main/docs/04_One_liners.md) 
5. [List of all special symbols](https://github.com/rmnavr/wy/blob/main/docs/05_Symbols.md)
---

Basic syntax uses:
* indents
* inline openers (we will focus for now mostly on `:`)
* continuator `\`

<!-- Indenting ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Basic indenting

```hy
; New line by default is wrapped in () :
print 3 4               | (print 3 4)

; Indent introduces new wrap level:
print                   | (print
    x                   |      (x)
    + y z               |      (+ y z))

; New line does NOT have to start at column-0:
    print 3 4           |      (print 3 4)

; ":" in the middle of the line adds parentheses,
; that are closed at the end of the line:
print x : + y z         | (print x (+ y z)
    3                   |      3)

; "\" prevents automatic wrapping of line in ():
print                   | (print
    f : + y 4           |      (f (+ y 4))
   \f : + x 3           |      f (+ x 3)
    t                   |      (t)
   \z                   |      z)

; Some syntax elements (like numbers) do not require "\" (you may still use it nontherless):
print                   | (print
    f x                 |      (f x)
    3.0                 |      3.0
    4.0                 |      4.0)

; When \ is used, indent position is seen at next printable symbol after it,
; so there is a little bit of stylistic freedom of where to place \
print                   | (print
   \x                   |      x
\   y                   |      y
  \ z                   |      z)
;   ↑
;   this is where wy will see indent level for all 3 "\"-prefixed lines

; Notice how described indent rule for \ works in following example:
y                       | (y
\x                      |    x)
                        |
  y                     | (y)
\ x                     |  x

; Use line consisting only of ":" to add +1 wrapping level:
:                       | (
  fn [x] : + pow 2      |   (fn [x] (pow x 2))
  3                     |   3)
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Empty Lines ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Empty lines policy

Wy has special policy about empty lines — **you can't have empty lines inside one expression**.

```hy
; Code below will be seen as 3 distinct s-expressions:

print x     |   (print x)
            |
    + z y   |       (+ z y)
            |
    + k n   |       (+ k n)

; Use comment line (at any indent level) to unite them in single expression:

print x     |   (print x
    ;       |       ;
    + z y   |       (+ z y)
    ;       |       ;
    + k n   |       (+ k n))
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Hy expressions ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Recognition of valid hy expressions

Wy will avoid looking inside expressions wrapped in valid hy brackets (`(...)`, `~@#{...}` and such).
Those expressions can also be multiline. This enables writing original hy syntax, or mixing it with wy syntax:
> List of all valid hy brackets is given in [List of all special symbols](https://github.com/rmnavr/wy/blob/main/docs/05_Symbols.md)

```hy
abs (+                  | (abs (+
       x                |         x                 ; notice that x did not require "\"
       (ncut ys 1 : 3)) |         (ncut ys 1 : 3))) ; notice that ":" was not recognized as wrapper
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- No continuator required ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Elements that do not require continuator

Several syntax elements (that are usually not head of s-expression) do not require continuator `\`:
```hy
func                |   (func
    -1.0            |       -1.0
    "string"        |       "string"
    :keyword        |       :keyword
    #^              |       #^
    #*              |       #*
    #**             |       #**
    ' x             |       ' x
    ` x             |       ` x
    ~ x             |       ~ x
    ~@ x            |       ~@ x)
                    |
                    |   ; this is obviously incorrect hy code,
                    |   ; but it shows how wy2hy works
```

When line starts with valid hy bracket, eather opening (like `(`, `#{`, `~@{` and such)
or closing one (`)`, `]`, or `}`), continuator `\` is also not needed.
And as was already said, everything inside these bracketed expressions will be interpreted as normal hy code:

```hy
func                |   (func
    ( L             |       ( L     ; notice that here L is variable name, not bracket opener
    )               |       )
    [ C             |       [ C     ; notice that here C is variable name, not bracket opener
    ]               |       ]
    {               |       {
      x             |         x     ; notice that continuator \ was not required here
    }               |       }
    ~@#{ x          |       ~@#{ x
    }               |       })
                    |
                    |   ; this is obviously incorrect hy code,
                    |   ; but it shows how wy2hy works
```

Also wy2hy will refuse to transpile if it'll see incorrect brackets (for which their pair is not found):
```hy
; this will give error:
func
    ( x

; this will give error:
func
    x
    )
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Other openers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Other kinds of openers

All other openers
(summarized in [List of all special symbols](https://github.com/rmnavr/wy/blob/main/docs/05_Symbols.md))
obey the same rules:

```hy
    L                   | [
      \x y : f 3        |   x y (f 3)
       g 4 L 2 5        |   (g 4 [2 5])]

;   ↓ this is where wy will see indent level
    `:                  | `(
       \get ~x ~indx    |    get ~x ~indx)
```

<!-- __________________________________________________________________________/ }}}1 -->

> \>\> Next chapter: [Condensed syntax](https://github.com/rmnavr/wy/blob/main/docs/03_Condensed.md)




