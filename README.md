
<!-- Intro ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Wy — Hy-lang without parentheses

Wy uses indents to wrap expressions (as many other lisp without parentheses projects).

What wy also brings to the table is:
* Syntax for every possible hy opener, including macros (`(`, `#(`, `[`, `{`, `~@#(`, etc.)
* Sofisticated one-liners syntax with symbols `\`, `:`, `::`, `,`, `$`, `<$`

Let's see some examples.

Defining function in wy (example uses `:`, `L` and `\` to control expression level):

```hy
defn #^ int                     | (defn #^ int
   \fibonacci                   |     fibonacci
    L #^ int n                  |     [#^ int n]
    if : <= n 1                 |     (if (<= n 1)
      \n                        |         n
       + : fibonacci : - n 1    |         (+ (fibonacci (- n 1))
           fibonacci : - n 2    |            (fibonacci (- n 2)))))
```

One-liners examples (they show usage of `::`, `$` and `,` symbols):

```hy
setv x : range : abs -3 :: abs -10 | (setv x (range (abs -3) (abs -10)))

map $ fn [x] : + x 1 , range 0 10  | (map (fn [x] (+ x 1)) (range 0 10))
```

Wy project consists of 2 parts:
- **wy** as a **syntax layer** for Hy-lang
- **wy2hy** transpiler — it produces hy-code from source wy-code

> **Syntax layer** is a polite way to say that **wy** is not a standalone language, but just a syntax modification to hy.
> To use wy-code, you first transpile it to hy-code (using wy2hy), and then you deal with transpiled *.hy files as usual.

**wy** syntax does not change anything about hy. It does not add new functionality,
it does not change order of hy function arguments, etc.
This is intended design to provide maximum compatibility with hy.

**wy2hy** produces readable hy-code with 1-to-1 line correspondence to source wy-code.
So, when you run your transpiled *.hy file, you'll get meaningfull number lines in debug messages.

<!-- __________________________________________________________________________/ }}}1 -->
<!-- ToC ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

---

Table of Contents:
- [Wy syntax](#Wy-syntax)
  - [Basic syntax](##Basic-syntax)
  - [Condensed syntax](#Condensed-syntax)
  - [Syntax for one liners](#Syntax-for-one-liners)
  - [Other types of openers](#Other-types-of-openers)
  - [Elements that do not require continuator](#Elements-that-do-not-require-continuator)
- [wy2hy transpiler](#Using-wy2hy-transpiler)
- [Installation](#Installation)

<!-- __________________________________________________________________________/ }}}1 -->

<!-- wy: Basics ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Wy syntax

## Basic syntax

Wy has many symbols for opening various kinds of hy brackets, but to get the basics
we will focus only on the most frequently used:
- `:` opener — represents opening parenthesis `(`
- `\` continuator — suppresses automatic wrapping line in `(...)`

Here usage of `:` and `\` symbols is shown:

```hy
; ":" in the middle of the line adds parentheses,
; that are closed at the end of the line:
print x : + y z         | (print x (+ y z))

; new line by default is wrapped in () :
print                   | (print
    x                   |      (x)
    + y z               |      (+ y z))

; "\" prevents wrapping line in (),
; also syntax elements that are usually not head of expression
; (like numbers) do not require "\":
print                   | (print
   \x                   |      x
    3.0                 |      3.0
    + y z               |      (+ y z))
;   ↑ notice that for line "\x" indent is seen exactly where arrow shows

; use line consisting only of ":" to add +1 parentheses level:
:                       | (
  fn [x] : + pow 2      |   (fn [x] (pow x 2))
  3                     |   3)
```

Notice that since indent of for example `\x` counts from `x` position (not from `\` position), 
you'll have this behaviour in following cases:
```hy
y       | (y 
\x      |    x)

 y      | (y)
\x      | x
```

Wy also has special policy about empty lines — you can't have empty lines inside one expression.

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
<!-- wy: Condensed ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Condensed syntax

`:` symbol at the start of the line is internally temporarily expanded to +1 indent level:
> Term "temporarily expanded" will be used a lot here. It actually means that:
> 1. To better understand how `:` at the start of the line works (and some other symbols), it is a good mental model to "expand" it first as shown below
> 2. But since wy2hy generates 1-to-1 line correspondent hy code, final hy code is not expanded

```hy
; Example 1:

    ; ↓ implied indent will be assumed at this position
    : fn [x] : + pow 2      | ( (fn [x] (pow x 2))
      3                     |   3)

    ; code above is internally temporarily expanded to:
    :                       | (
      fn [x] : + pow 2      |   (fn [x] (pow x 2))
      3                     |   3)

; Example 2:

    : : f x     | ( ( (f x)
        3       |     3))

    ; code above is internally temporarily expanded to:
    :           | (
      :         |   (
        f x     |     (f x)
        3       |     3))
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- wy: One-liners ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Syntax for one-liners

Wy has 3 main symbols for writing one-liners: `::`, `,` and `$`.

`::` is literal `)(`, and there are many cases where it may be usefull:
```hy
print : + 1 2 :: + 3 4  |   (print (+ 1 2) (+ 3 4))

print                   |   (print
    + 1 2 :: + 3 4      |        (+ 1 2) (+ 3 4))

: f 3 :: f 4            |   ((f 3) (f 4))
; line above is internally temporarily expanded to:
:                       |   (
  f 3 :: f 4            |     (f 3) (f 4))
```

`,` is emulation of new line. Be aware that you may require using continuator `\`:
```hy
print                   |   (print
    3 , f 3 , \x        |       3 (f 3) x)

; code above is internally temporarily expanded to:
print                   |   (print
    3                   |       3
    f 3                 |       (f 3)
   \x                   |       x)
```

`$` is placing code on +1 indent level and acts differently depending on:
- if line is started with `:`
- if it does not start with `:`

And you may also need to use continuator `\`:

```hy
; Case 1 : line starts with ":"

    ; ↓ this exact position will be used as indent level for $
    : fn [x] : pow x 2 $ f 3    | ((fn [x] (pow x 2)) (f 3))
    : fn [x] : pow x 2 $ \x     | ((fn [x] (pow x 2)) x)

    ; code above is internally temporarily expanded to:
    :                           | (
      fn [x] : pow x 2          |   (fn [x] (pow x 2))
      f 3                       |   (f 3))
    :                           | (
      fn [x] : pow x 2          |   (fn [x] (pow x 2))
     \x                         |   x)

; Case 2 : line does not start with ":"

    print : + x 1 $ x
    print : + x 1 $ \y

    ; code above is internally temporarily expanded to:
    print : + x 1
        x
    print : + x 1
       \y
    ;   ↑ new indent position is created at +4 spaces
```

Final example (although very contrived) shows how symbols `:`, `::`, `,` and `$` interact.
Symbol `,` has highest priority:

```hy
: fn [x] : + : * x 3 :: / x 4 $ : fn [x] : + x 2 $ \z , print t : + x 3

; code above is internally temporarily expanded to:
:                               | (
  fn [x] : + : * x 3 :: / x 4   |   (fn [x] (+ (* x 3) (/ x 4))
  :                             |   (
    fn [x] : + x 2              |     (fn [x] (+ x 2))
   \z                           |     z))
print t : + x 3                 | (print t (+ x 3))
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- wy: Other openers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Other types of openers

We already saw how `:` works.
There are also other elements that act in the same manner (including condensed syntax and interacting with `$` and `,` symbols), but produce different brackets.

Overall in wy there are:
- bracket-openers `:`, `L`, `C`, `#:` and `#C` — represent opener brackets `(`, `[`, `{`, `#(` and `#{` respectively
- any of these 5 openers can be combined with hy symbols for macros (there are 4 of them: `` ` ``, `'`, `~` and `~@`),
  they must be combined without spaces, for example: `~@#:` is for `~@#(`
  > and of course you can use standalone hy macros symbols as usual
- for one-liners there are `::`, `LL`, `CC`, `:#:` and `C#C` symbols — they represent `)(`, `][`, `}{`, `) #(` and `} #{` respectively

> Yes, symbols `L`, `C`, `LL` and `CC` can never be used as variable names in wy.
> For now you may use `L_` and such instead.
>
> I am currently working on designing solution for this issue.

Example:
```hy
L 1 2 3 L 4 5 6 LL 7 8  |   [ 1 2 3 [4 5 6] [7 8]
 \k n C "x" 3 "y" 4     |     k n {"x" 3 "y" 4}
  L f 3 :: f 5          |     [ (f 3) (f 5) ]]

; internally seen as:   |
L                       |   [
  1 2 3 L 4 5 6 LL 7 8  |     1 2 3 [4 5 6] [7 8]
 \k n C "x" 3 "y" 4     |     k n {"x" 3 "y" 4}
  L                     |     [
    f 3 :: f 5          |       (f 3) (f 5) ]]

; be aware that due to how condensed syntax works, sometimes you may require \ after L (or C):
L x y                   |   [(x y)]
L\x y                   |   [x y]
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- wy: No continuator required ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Elements that do not require continuator

Several syntax elements (that are usually not head of s-expression) do not require continuator `\`:
```hy
func                |   (func
    1               |       1
    .1              |       .1
    -1              |       -1
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

Also, when line starts with literal bracket (or any macro-bracket), continuator `\` is also not needed:
```hy
func                |   (func
    ( x             |       ( x
    )               |       )
    [ x             |       [ x
    ]               |       ]
    { x             |       { x
    }               |       }
    ~@#{ x          |       ~@#{ x
    }               |       })
```

Above means that you can write code close to orginal hy syntax, you'll just need to:
- add occasional `\`
- refrain from using empty lines:
```hy
(print              |   (print
    \x              |       x
     3              |       3
     ;              |       ;
     (* y 3))       |       (* y 3))
```

<!-- __________________________________________________________________________/ }}}1 -->

<!-- wy2hy ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Using wy2hy transpiler

You need to have **hy** installed for w2h to work.

Usage example: run in the terminal

```
wy2hy _f your_source_name.wy
```

> Options are given via "_" prefix (instead of traditional "-") to avoid messing with hy options.

> If full filename for source file is given (like "C:\\users\\username\\proj1\\your_source_name.wy"), wy2hy will change script's current dir to dir of this file.
> This enables your transpiled code to import other project files lying in the same dir, which is intended way of using `f` and `m` options.

All possible run options (like _wm for example):
* `w` — [W]rite transpiled hy-file in the same dir as source wy-file
* `f` — same as `w`, but after writing, immediately run transpiled [F]ile
* `m` — transpile and run only from [M]emory (meaning, no file will be written on disk);
  > please be aware, that in opposition to `f` option, if any error occurs in transpiled code, debug messages will be polluted with wy2hy.hy calls, so `f` is a preffered way of running
* `s` - [S]ilent mode, won't write any transpilation status messages


<!-- __________________________________________________________________________/ }}}1 -->
<!-- Install ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Installation

```
pip install git+https://github.com/rmnavr/wy.git@0.0.1
```

<!-- __________________________________________________________________________/ }}}1 -->




