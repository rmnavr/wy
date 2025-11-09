
---
wy syntax:
1. [Syntax overview](https://github.com/rmnavr/wy/blob/main/docs/01_Overview.md)
2. [Basic syntax](https://github.com/rmnavr/wy/blob/main/docs/02_Basic.md)
3. [Condensed syntax](https://github.com/rmnavr/wy/blob/main/docs/03_Condensed.md)
4. [One-liners](https://github.com/rmnavr/wy/blob/main/docs/04_One_liners.md)
5. [List of all special symbols](https://github.com/rmnavr/wy/blob/main/docs/05_Symbols.md)

running wy code:
1. [wy2hy transpiler](https://github.com/rmnavr/wy/blob/main/docs/wy2hy.md)
2. [wy in ipython](https://github.com/rmnavr/wy/blob/main/docs/ipywy.md) 
---

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
   \4.0                 |      4.0)


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

; Also, increasing indent after continuation line is forbidden:
print                   |
   \x                   |
      f x               | <will not transpile>
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Empty Lines ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Empty lines policy

Wy has special policy about empty lines — **you can't have empty lines inside one expression**
(with exception to valid hy-expressions and strings, which are always parsed as-is).

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
<!-- Whitespace ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Whitespace policy

Continuator is the only wy special symbol that can be used without surrounding spaces:
```hy
 :\: x | ( (x)) ; recognized as ':', '\', ':' and 'x'
```

Every other wy special element need to be spaced — or it will
be recognized as a normal hy word (since hy allows for ASCII chars in names):
```hy
 x : y   | (x (y))  ; recognized as word 'x', opener ':' and word 'y'
 x:y     | (x:y)    ; recognized as one word 'x:y'
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Hy expressions + Strings ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Multiline elements (hy-expressions and strings)

Wy parses valid hy-expressions (with valid bracket balancing) as-is, without looking inside them.
This allows for mixing wy and hy code.

Same is also true for strings.

This entails following rules:
* Indents of multiline hy-expressions/strings do not mess with wy code
  (just place very first symbol of hy-expression/string correctly)
* You can have empty lines inside hy-expressions/strings, they will NOT close indent blocks

```hy
;     ↓ this is the only indent-level introduced by hy-expression
plus  (+            | (plus  (+
                    |                       ; notice that empty line didn't close indent block
     x              |       x               ; notice that x did not require "\"
   (ncut ys 1 : 3)) |     (ncut ys 1 : 3))  ; notice that ":" was not recognized as wy-wrapper
      f z           |        (f z))
print x             | (print x)

print "multiline    | (print "multiline
   string           |    string
                    |
      string more   |       string more
    more string"    |     more string")
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- fStrings ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Formatted strings

Formated strings are parsed as is, meaning you should use hy syntax
when having expressions inside them:
```hy
    f"{(* k 1.5) :.2f}"` ; this is correct

    f"{* k 1.5 :.2f}"`   ; this will be transpiled wihout changes,
                         ; so you'll end up having incorrect hy code
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Other openers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Other kinds of openers

Other openers obey the same rules.
Just be aware, that indent in openers like `':` counts from first symbol:

```hy
    L                   | [
      \x y : f 3        |   x y (f 3)
       g 4 L 2 5        |   (g 4 [2 5])]

;   ↓   ↓ this is where wy will see indent levels
    ':                  | '(
       \get ~x ~indx    |     get ~x ~indx)
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- No continuator required ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Elements that do not autowrap

When line starts with elements, that by hy logic can never be head of s-expression,
they will not be auto-wrapped, so continuator `\` may be omitted.

Code below gives full list of such elements:
```hy
func          | (func
    #(+ x 3)  |     #(+ x 3)  ; valid hy expression
    "string"  |     "string"  ; string
    r"string" |     r"string" ; formatted string
    b"string" |     b"string" ; byte string
    f"string" |     f"string" ; formatted string
    -1.0      |     -1.0      ; number (anything starting with ±digit)
    :z 3      |     :z 3      ; keyword
    #* m      |     #* m      ; sugar symbol (args unpacker)
    #rmacro   |     #rmacro   ; reader macro
    'x        |     'x        ; hy macro-ed words
    ;         |     ;       
    + 1 2     |     (+ 1 2)   ; everything else is autowrapped
    smth      |     (smth))   

func          | (func
   \1         |      1        ; adding '\' before non-autowrapped '1'
    2         |      2)       ; is allowed although it does nothing
```

Everything else is autowrapped, including:
* `±NaN` and `Inf` (they are NOT seen as numbers by wy logic)
* `True`, `False` and `None`

Notice, that by this logic:
* `::z` is keyword, no auto-wrapping
* `#*_` is reader macro, no auto-wrapping
* Things like `$a`, `&b`, `^c`, `-f`, `,1`, `_1` are all words
* `1:` will be seen as a number in wy (it will not be auto-wrapped), although it is not a valid number in hy
  > may be changed in future releases
* wy words can never have `\` in their name, for example `x\y` 
  is seens as continuator between 2 words: `x`, `\` and `y`

<!-- __________________________________________________________________________/ }}}1 -->

