
---
Documentation:
1. [Syntax overview](https://github.com/rmnavr/wy/blob/main/docs/01_Overview.md)
2. You are here -> [Basic syntax](https://github.com/rmnavr/wy/blob/main/docs/02_Basic.md) 
3. [Condensed syntax](https://github.com/rmnavr/wy/blob/main/docs/03_Condensed.md)
4. [One-liners](https://github.com/rmnavr/wy/blob/main/docs/04_One_liners.md) 
5. [List of all special symbols](https://github.com/rmnavr/wy/blob/main/docs/05_Symbols.md)
---

<!-- Basic rules ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Basic syntax rules of wy

Basic syntax uses:
* indents
* in-line openers (for now we will only cover the most frequently used one, which is `:`)
* continuator `\`

```hy
; New line by default is wrapped in () :
print 3 4               | (print 3 4)

; Indent introduces new wrap level:
print                   | (print
    x                   |      (x)
    + y z               |      (+ y z))

; Unlike Python, new line does NOT have to start at column-0:
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

; Some syntax elements (like numbers) do not require "\" :
print                   | (print
    f x                 |      (f x)
    3.0                 |      3.0)

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

Wy will avoid looking inside expressions wrapped in valid hy brackets.
Those expressions can also be multiline.
This enables writing original hy syntax, or mixing it with wy syntax:
> Valid hy brackets are described in next chapter.

```hy
abs (+                  | (abs (+
       x                |         x                 ; x did not require "\"
       (ncut ys 1 : 3)) |         (ncut ys 1 : 3))) ; ":" was not recognized as wrapper
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
And as was already said, everything inside these bracketed expressions
will be interpreted as normal hy code:
> List of all valid hy brackets is given in [List of all special symbols](https://github.com/rmnavr/wy/blob/main/docs/05_Symbols.md)

```hy
func                |   (func
    ( L             |       ( L     ; notice that here L is variable name, not bracket opener
    )               |       )
    [ C             |       [ C     ; notice that here C is variable name, not bracket opener
    ]               |       ]
    {               |       {
      x             |         x     ; notice that continuator \ was not used here
    }               |       }
    ~@#{ x          |       ~@#{ x
    }               |       })
```

Also wy2hy will refuse to transpile if it sees incorrect brackets (for which their pair is not found):
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

To represent variety of all valid hy brackets
(summarized in [List of all special symbols](https://github.com/rmnavr/wy/blob/main/docs/05_Symbols.md)),
wy has 5 basic symbols:
- `:` to represent `(`
- `L` to represent `[`
- `C` to represent `{`
- `#:` to represent `#(`
- `#C` to represent `#{`

They can also be combined with 4 hy macros symbols (without spaces).
For example, `~@#:` is valid wy opener.

We already covered `:`. And **all the same rules apply to any of 25 wy openers**:
```hy
L                   | [
  \x y : f 3        |   x y (f 3)
   g 4 L 2 5        |   (g 4 [2 5])]
                    |
`:                  | `(
   \get ~x ~indx    |    get ~x ~indx)
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- L/C sacrifice ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Sacrificing L and C

Symbols `L`, `C` (and also `LL` and `CC`,
see [List of all special symbols](https://github.com/rmnavr/wy/blob/main/docs/05_Symbols.md))
cannot be directly used as variable names in wy.

I know this is kind of dumb, but hey, hy has lot's of various brackets.

Solution here is wrapping code inside hy brackets, since wy won't look inside them (other than checking for correct nesting):
```hy
; Seeing this code, wy2hy will strictly follow wy rules
; and produce corresponding non-working hy code:
setv L : + L 1          | (setv [(+ [1])])

; So, in order for L to be recognized as variable (as opposed to "[" bracket opener),
; L needs to be inside parentheses:
(setv L (+ L 1))        | (setv L (+ L 1))
```

<!-- __________________________________________________________________________/ }}}1 -->





