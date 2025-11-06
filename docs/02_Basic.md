
---
wy syntax:
1. [Syntax overview](https://github.com/rmnavr/wy/blob/main/docs/01_Overview.md)
2. [Basic syntax](https://github.com/rmnavr/wy/blob/main/docs/02_Basic.md) 
3. [Condensed syntax](https://github.com/rmnavr/wy/blob/main/docs/03_Condensed.md)
4. [One-liners](https://github.com/rmnavr/wy/blob/main/docs/04_One_liners.md) 
5. [List of all special symbols](https://github.com/rmnavr/wy/blob/main/docs/05_Symbols.md)

running wy code:
1. [wy2hy transpiler](https://github.com/rmnavr/wy/blob/main/docs/wy2hy.md) 
2. [wy repl](https://github.com/rmnavr/wy/blob/main/docs/repl.md) 
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

; Use line consisting only of ":" to add +1 wrapping level:
:                       | (
  fn [x] : + pow 2      |   (fn [x] (pow x 2))
  3                     |   3)

; "\" prevents automatic wrapping of line in ():
print                   | (print
    f : + y 4           |      (f (+ y 4))
   \f : + x 3           |      f (+ x 3)
    t                   |      (t)
   \z                   |      z)

; Some syntax elements (like numbers) do not require "\"
; (you may still use it nontherless):
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

```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Empty Lines ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

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

However you still can have empty lines inside valid multiline hy expressions and miltiline strings (see below).

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Hy expressions ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Recognition of valid hy expressions

Wy will avoid looking inside expressions wrapped in valid hy brackets (`(...)`, `~@#{...}` and such).
> List of all valid hy brackets is given in [List of all special symbols](https://github.com/rmnavr/wy/blob/main/docs/05_Symbols.md)

Also:
* indents inside multiline hy expression do not mess with wy code at all
* you can have empty lines inside hy expressions

So this syntax is correct:
```hy
abs   (+            | (abs   (+
                    |                       ; notice empty line
     x              |       x               ; notice that x did not require "\"
   (ncut ys 1 : 3)) |     (ncut ys 1 : 3))) ; notice that ":" was not recognized as wrapper
print x             | (print x)
```

While outside hy expressions such indents won't compile:
```
  abs
 3  ; this will throw indent error
```

To understand how multiline hy expressions behave in indented world of wy, imagine them
being forcefully placed one one line (like joining several lines with `\n` symbol). 
For example, this is how transpiler sees hy expression above:
```hy
(+ <\n><\n>     x <\n>   (ncut ys 1 : 3))
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
<!-- Strings ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Strings

All 4 kinds of python strings are recognized by parser (which are: `"string"`, `f"string"`, `b"string"` and `r"string"`)

Multiline strings are parsed same as hy expressions, so this is a valid code:
```hy
    print " smth
        smth

     smth"
```

Formated strings are parsed as is, meaning you should use hy syntax inside them:
```hy
    f"{(* k 1.5) :.2f}"` ; this is correct
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
<!-- No continuator required ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Elements that do not require continuator

Several syntax elements (that are usually not head of s-expression) do not require continuator `\`
(you can still place it, although not required):
- valid hy expressions (example: `#{"x" 3 "y" 4}`)
- all 4 kinds of strings: `"string"`, `f"string"`, `b"string"`, `r"string"`
- valid hy numbers — anything starting with `±N` (examples: `-1.0E+7`, `0xFF`, `1_000E7`, `+2,000,000E-6+3J`)
- keywords — anything starting with `:`, like `:x` (obviously excluding wy openers like `:`)
- 4 sugar symbols: `#*` `#**` `#_` `#^`
- hy macro-ed words — anything starting with `'`, `` ` ``, `~` or `~@` (obviously excluding wy openers like `~@L`)
- reader macros — anything starting with `#` (obviously excluding wy openers like `#:`)

```hy
func                |   (func
    (+ x 3)         |       (+ x 3)   ; valid hy expression
    f"string"       |       f"string" ; string
    -1.0            |       -1.0      ; valid hy number
    :z              |       :z        ; keyword
    #**             |       #**       ; sugar symbol
    'x              |       'x        ; hy macro-ed words
    ~ y             |       ~ y)      ; hy macro and word
                    |
                    |   ; this is obviously incorrect hy code,
                    |   ; but it shows how wy2hy works
```

<!-- __________________________________________________________________________/ }}}1 -->

> \>\> Next chapter: [Condensed syntax](https://github.com/rmnavr/wy/blob/main/docs/03_Condensed.md)


