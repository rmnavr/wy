
<!-- Intro ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Wy — Hy-lang without parentheses

Wy offers prentheses-less syntax for [Hy lang](https://github.com/hylang/hy) by usage of:
* indents
* syntax for every valid hy opener bracket
* sofisticated syntactic sugar for writing one-liners

Wy does not change anything about hy rather than removing parentheses.

Example code in wy:

```hy
defn #^ int                         | (defn #^ int
   \fibonacci                       |     fibonacci
    L #^ int n                      |     [#^ int n]
    if (<= n 1)                     |     (if (<= n 1)
      \n                            |         n
       + : fibonacci : - n 1        |         (+ (fibonacci (- n 1))
           fibonacci : - n 2        |            (fibonacci (- n 2)))))

; one-liners:
setv x : range : abs -3 :: abs -10  | (setv x (range (abs -3) (abs -10)))
map $ fn [x] : + x 1 , range 0 10   | (map (fn [x] (+ x 1)) (range 0 10))
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

Documentation:
- [Basic syntax](https://github.com/rmnavr/wy/blob/main/docs/Basic.md) 
- [Condensed syntax](https://github.com/rmnavr/wy/blob/main/docs/Condensed.md) 
- [One-liners](https://github.com/rmnavr/wy/blob/main/docs/One_liners.md) 

Table of Contents:
- [Wy syntax](#Wy-syntax)
  - [Basic syntax](#Basic-syntax)
  - [Elements that do not require continuator](#Elements-that-do-not-require-continuator)
  - [Other kidns of openers](#Other-kinds-of-openers)
  - [Condensed syntax](#Condensed-syntax)
  - [Syntax for one liners](#Syntax-for-one-liners)
- [wy2hy transpiler](#Using-wy2hy-transpiler)
- [Installation](#Installation)

<!-- __________________________________________________________________________/ }}}1 -->

<!-- wy: Basics ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Wy syntax

Wy syntax can be roughly split into 3 parts:
- Basic syntax
- Condensed syntax
- One-liners syntax

Basic syntax is already enough for writing code.

## All of wy's special symbols

Wy syntax can be split in 2 parts:

Basic syntax:
- Indent rules
- 25 various bracket openers 
  - 5 basic openers
    - `:` to represent `(`
    - `L` to represent `[`
    - `C` to represent `{`
    - `#:` to represent `#(`
    - `#C` to represent `#{`
  - 4 hy macro symbols (`` ` ``, `'`, `~` and `~@`) can be prepended to any of 5 basic openers without spaces (example: `~@#C` will represent `~@#{`),
    thus generating mentioned number 25
    > 5*(1+4) = 25
- Continuator `\`

Symbols for one-liners:
- 3 symbols that control wrapping level:
  - reverse applicator `<$`
  - applicator `$`
  - joiner `,`
- 5 double markers:
  - `::` to represent `)(`
  - `LL` to represent `][`
  - `CC` to represent `}{`
  - `:#:` to represent `) #(`
  - `C#C` to represent `} #{`

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
<!-- wy: Condensed ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Condensed syntax

> We will discuss condensed syntax by inspecting `:` opener behaviour.
> However all the same rules apply for any of 25 kinds of openers.

Condensing openers (like `:`) is considered to be a syntactic sugar,
meaning that condensed syntax is internally processed in expanded form:

```hy
: fn [x] : + pow 2      | ( (fn [x] (pow x 2))
  3                     |   3)

; internally, lines above will be processed as if they were expanded to:
:                       | (
  fn [x] : + pow 2      |   (fn [x] (pow x 2))
  3                     |   3)
```
*(by the way, this internal expansion does not mess with final numbering of generated code lines)*

### Openers behaviour depending on position

Notice that `:` behaviour is slightly different depending on it's placement:
```hy
                ; ↓↓ 2 wraps around x due to ":" at the start of the line
: x : y         | ((x (y)))
                ;     ↑ 1 wrap around y due to ":" in the middle of the line
```

Logic of such behaviour is more clear in expanded form:
```hy
                ; /--- 1st wrap is due to ":" at the start of the line
                ; | /- 2nd wrap is due to "x" being autowrapped, since it startsnhe line
                ; ↓ ↓
:               | (
  x : y         |   (x (y)))
                ;      ↑ 1 wrap around "y" due to ":" in the middle of the line
```

### Indenting in condensed syntax

You can have as many `:` at the start of the line as you like.
Just be aware that such `:` introduces new indents, which must be respected by lines that follow it:

```hy
  ; wy will see indents at these positions due to ":"
  ; at the start of the line
  ; ↓  ↓ ↓
    :  : f x : y         | (  ( (f x (y))
         3               |      3)
       4                 |    4)
```

Everything after `\` switches off condensing (and thus new indent levels):
```hy
  ; indents are created only at 2 positions:
  ; ↓  ↓
    : \: f x : y         | (  (f x (y))
       4                 |    4)
  ;    ↑
  ;    ":" at this position will not be seen as condensed

  ; expanded form:
    :                    | (
      \: f x : y         |    (f x (y))
       4                 |    4)
```

Following described logic, see how continuator `\` works with `:` (and any other) openers:
```hy
 : x : y         | ((x (y)))
 :\x : y         | ( x (y))
 : x :\y         | ( x (y))  ; \ is allowed, but surves no purpose
\: x : y         | ( x (y))  ; this is seen as single line, not as condensed line
 : x\: y         | ((x (y))  ; allowed, but surves no purpose
```

### Examples of condensed syntax

Let's get back to examples from [Other kidns of openers](#Other-kinds-of-openers) chapter
and see how they can be condensed:

```hy
; Example 1:

    L                   | [
      \x y : f 3        |   x y (f 3)
       g 4 L 2 5        |   (g 4 [2 5])]

    ; condensed:
    L \x y : f 3        | [ x y (f 3)
       g 4 L 2 5        |   (g 4 [2 5])]

; Example 2:

    `:                  | `(
       \get ~x ~indx    |    get ~x ~indx)

    ; condensed:
    `: \get ~x ~indx    | `( get ~x ~indx)
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- wy: One-liners ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Syntax for one-liners

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

One-liners in details are described in:
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



    case: multiline (hy) indenting

