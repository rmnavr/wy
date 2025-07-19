
---
Documentation:
1. [Syntax overview](https://github.com/rmnavr/wy/blob/main/docs/01_Overview.md)
2. You are here -> [Basic syntax](https://github.com/rmnavr/wy/blob/main/docs/02_Basic.md) 
3. [Condensed syntax](https://github.com/rmnavr/wy/blob/main/docs/03_Condensed.md)
4. [One-liners](https://github.com/rmnavr/wy/blob/main/docs/04_One_liners.md) 
5. [List of all special symbols](https://github.com/rmnavr/wy/blob/main/docs/05_Symbols.md)
---

<!-- Intro ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Wy — Basic syntax

Table of Contents:
- [Basic rules](#Basic-syntax)
- [Elements that do not require continuator](#Elements-that-do-not-require-continuator)
  - [Other kidns of openers](#Other-kinds-of-openers)
  - [Condensed syntax](#Condensed-syntax)
  - [Syntax for one liners](#Syntax-for-one-liners)
- [wy2hy transpiler](#Using-wy2hy-transpiler)
- [Installation](#Installation)

<!-- __________________________________________________________________________/ }}}1 -->

<!-- Basic rules ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Basic rules

Basic syntax uses indents, in-line opener `:` and continuator `\`:

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

Wy also has special policy about empty lines — **you can't have empty lines inside one expression**.

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

## Original hy openers

Hy itself has:
- 3 kinds of closing bracket: `)`, `]` and `}`
- 5 basic kinds of opening bracket: `(`, `#(`, `[`, `{`, `#{`
- 4 macros symbols: `` ` ``, `'`, `~`, `~@`

Macros symbols can prepend opening brackets, so for example `~@#(` is a valid hy bracket.
And in total it sums up to 5*(1+4) = 25 different kinds of opening brackets.

## Wy counterparts to hy openers

To represent all of this variety, wy has 5 basic symbols:
- `:` to represent `(`
- `L` to represent `[`
- `C` to represent `{`
- `#:` to represent `#(`
- `#C` to represent `#{`

They can also be combined with 4 macros symbols (without spaces),
thus covering all 25 kinds of opening brackets in hy.
For example, `~@#:` is valid wy opener.

We already covered `:`. **All the same rules apply to any of 25 wy openers**:
```hy
L                   | [
  \x y : f 3        |   x y (f 3)
   g 4 L 2 5        |   (g 4 [2 5])]
                    |
`:                  | `(
   \get ~x ~indx    |    get ~x ~indx)
```

### Sacrificing L and C

Symbols `L`, `C` (also `LL` and `CC`, see [one-liners chapter](#Syntax-for-one-liners))
cannot be directly used as variable names in wy.

> I know this is kind of dumb, but hey, hy has lot's of brackets.

Solution here is wrapping code inside hy brackets, since wy won't look inside them:
```hy
; Seeing this code, wy2hy will strictly follow wy rules
; and produce corresponding non-working hy code:
setv L : + L 1          | (setv [(+ [1])])

; So, in order for L to be recognized as variable (as opposed to "[" bracket opener),
; L needs to be inside parentheses:
(setv L (+ L 1))        | (setv L (+ L 1))
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- wy: One-liners ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Syntax for one-liners

One-liners is advanced wy topic, that enables writing even more condensed code like:
```hy
; Example 1:

    map $ fn [x y] : * : + x 3 :: + y 4 , \xs ys
    ; this transpiles into:
    (map (fn [x y] (* (+ x 3) (+ y 4))) xs ys)

; Example 2:

    Constructor x <$ \y <$ \z
    ; this transpiles into:
    (((Constructor x) y) z)
```

Internally wy one-liners symbols are syntactic sugar for indenting and wrapping.
You don't need to use them if you don't want to — basic and condensed syntax is already enough for writing code.

<!-- __________________________________________________________________________/ }}}1 -->





