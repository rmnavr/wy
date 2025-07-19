
<!-- Intro ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Wy — Hy-lang without parentheses

Wy offers prentheses-less syntax for [https://github.com/hylang/hy](Hy-lang) by usage of:
* Indents for wrapping expressions
* Syntax for every valid hy opener (like `:` for `(`, `~@#L` for `~@#[` and others)
* Sofisticated one-liners syntax via symbols like `$` and `<$`

Wy does not change anything about hy rather than removing parentheses.

Example code:

```hy
defn #^ int                        | (defn #^ int
   \fibonacci                      |     fibonacci
    L #^ int n                     |     [#^ int n]
    if (<= n 1)                    |     (if (<= n 1)
      \n                           |         n
       + : fibonacci : - n 1       |         (+ (fibonacci (- n 1))
           fibonacci : - n 2       |            (fibonacci (- n 2)))))
                                   |
setv x : range : abs -3 :: abs -10 | (setv x (range (abs -3) (abs -10)))
                                   |
map $ fn [x] : + x 1 , range 0 10  | (map (fn [x] (+ x 1)) (range 0 10))
```

---

Wy project consists of 2 parts:
1. **wy** as a **syntax layer** for Hy-lang
2. **wy2hy** transpiler — it produces hy-code from source wy-code

> **Syntax layer** term means that wy is not a standalone language, but just a syntax modification to hy.
> To run wy code, you first transpile it to hy code (using wy2hy), and then you deal with transpiled *.hy files as usual.

**wy2hy** produces readable hy-code with 1-to-1 line correspondence to source wy-code.
So, running transpiled *.hy file will give meaningfull number lines in debug messages.

<!-- __________________________________________________________________________/ }}}1 -->
<!-- ToC ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

---

Table of Contents:
- [Wy syntax](#Wy-syntax)
  - [Basic syntax](##Basic-syntax)
  - [Condensed syntax](##Condensed-syntax)
  - [Other kidns of openers](##Other-kinds-of-openers)
  - [Elements that do not require continuator](##Elements-that-do-not-require-continuator)
  - [Syntax for one liners](##Syntax-for-one-liners)
- [wy2hy transpiler](#Using-wy2hy-transpiler)
- [Installation](#Installation)

<!-- __________________________________________________________________________/ }}}1 -->

<!-- wy: Basics ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Wy syntax

## Basic syntax

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
   \x                   |      x)

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

; Previous example can be condensed in 2 lines:
: fn [x] (+ pow 2)      | ( (fn [x] (pow x 2))
  3                     |   3)

; You can have as many : at the start of the line as you like.
; Just be aware of where wy will see indents:

  ; wy will see indents at these positions
  ; ↓ ↓ ↓
    : : f x : y         | ( ( (f x (y))
        3               |     3)
      4                 |   4)
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
<!-- wy: Other openers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Other kinds of openers

### Original hy openers

Hy itself has:
- 3 kinds of closing bracket: `)`, `]` and `}`
- 5 basic kinds of opening bracket: `(`, `#(`, `[`, `{`, `#{`
- 4 macros symbols: `` ` ``, `'`, `~`, `~@`

Macros symbols can prepend opening brackets, so for example `~@#(` is a valid hy bracket.
And in total it sums up to 5*(1+4) = 25 different kinds of opening brackets.

### Wy counterparts to hy openers

To represent all of this variety, wy has 5 basic symbols:
- `:` to represent `(`
- `L` to represent `[`
- `C` to represent `{`
- `#:` to represent `#(`
- `#C` to represent `#{`

They can also be combined with 4 macros symbols (without spaces), thus covering all 25 kinds of opening brackets in hy.
For example, `~@#:` is valid wy opener.

We already covered `:`. All the same rules apply to any of 25 wy openers:
```hy
L                   | [
  \x y              |   x y
   L\z t            |   [z t]]

L \x y L z t        | [ x y [z t]]
```

Prefixing macros with `:` (and getting openers like `':` may seem to work counter-intuitively,
but logic actually stays consistent: **rules are the same for any of 25 wy openers**.
```hy
; let's say we want to generate following hy code:
`(get ~x ~indx)

; adding "`:" will generate unwanted wrapping:
`: get ~x ~indx     | `( (get ~x ~indx))

; standalone "`" is considered as continuator,
; so it won't generate enough wrapping:
` get ~x ~indx      | ` get ~x ~indx

; so, viable wy syntax is the following:
`: \get ~x ~indx    | `( get ~x ~indx)
```

### Sacrificing L and C

Symbols `L`, `C` (also `LL` and `CC`, see [one-liners chapter](##Syntax-for-one-liners))
cannot be directly used as variable names in wy.

> I know this is kind of dumb, but hey, hy has lot's of brackets.

Solution here is wrapping code inside hy brackets, since wy won't look inside them:
```hy
; Seeing this code, wy2hy will strictly follow wy rules
; and produce corresponding incorrect hy code:
setv L : + L 1    | (setv [ (+ L 1) ])

; So, in order for L to be recognized as variable (and not as "[" bracket opener),
; L needs to be inside parentheses:
(setv L (+ L 1))  | (setv L (+ L 1))
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- wy: No continuator required ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Elements that do not require continuator

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

When line starts with valid hy bracket, eather opening (like `(`, `#{`, `~@{` and such) or closing one (`)`, `]`, or `}`), continuator `\` is also not needed.
And as was already said, everything inside these bracketed expressions will be interpreted as normal hy code (without recognizing special wy symbols):
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

wy2hy will refuse to transpile if it sees incorrect brackets (for which their pair is not found):
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
<!-- wy: One-liners ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Syntax for one-liners

One-liners is advanced wy topic, that allows you to write dense code like:
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

You don't need to use one-liners if you find them cumbersome.

Overall, one-liners rely on:
- Already discussed 25 bracket openers (from `:` to `~@#C` and such)
- Already discussed continuator `\`
- 3 symbols controlling wrapping level:
  - reverse applicator `<$`
  - applicator `$`
  - joiner `,`
- 5 double markers:
  - `::` to represent `)(`
  - `LL` to represent `][`
  - `CC` to represent `}{`
  - `:#:` to represent `) #(`
  - `C#C` to represent `} #{`

One-liners in details are described in separate doc file:
[docs/ONELINERS.md](https://github.com/rmnavr/wy/blob/main/docs/ONELINERS.md)

<!-- __________________________________________________________________________/ }}}1 -->

<!-- wy2hy ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Using wy2hy transpiler

You need to have **hy** installed for **wy2hy** to work.

Usage example: run in the terminal

```
wy2hy _f your_source_name.wy
```

> Options are given via "_" prefix (instead of traditional "-") to avoid messing with hy options.


All possible run options (like `_wm` for example):
* `w` — [W]rite transpiled hy-file in the same dir as source wy-file
* `f` — same as `w`, but after writing, immediately run transpiled [F]ile from it's dir
  > If full filename for source file is given (like "C:\\users\\username\\proj1\\your_source_name.wy"), wy2hy will change script's dir to dir of this file.
  > This enables your transpiled code to import other project files lying in the same dir, which is intended way of using `f` and `m` options.
* `m` — transpile and run only [M]emory (meaning, no file will be written on disk)
  > be aware, that in opposition to `f` option, if any error occurs in transpiled code, debug messages will be polluted with wy2hy.hy calls, so `f` is a preffered way of running
* `s` - [S]ilent mode, won't write any transpilation status messages


<!-- __________________________________________________________________________/ }}}1 -->
<!-- Install ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Installation

```
pip install git+https://github.com/rmnavr/wy.git@0.0.1
```

<!-- __________________________________________________________________________/ }}}1 -->




