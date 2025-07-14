
<!-- NEW: Syntax, Basics ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Wy syntax

Wy has many symbols for opening various kinds of hy brackets, but to get the basics 
for now we will focus only on the most frequently used:
- `:` opener — represents opening parenthesis `(` 
- `\` continuator — suppresses automatic wrapping line in `(...)`

## Basic syntax

Here we see usage of `:` and `\` symbols:

```hy
    ; ":" in the middle of the line adds parentheses,
    ; that are closed at the end of the line:
    print x : + y z         | (print x (+ y z))

    ; new line by default is wrapped in () :
    print                   | (print
        x                   |      (x)
        + y z               |      (+ y z))

    ; "\" prevents wrapping line in () :
    print                   | (print
       \x                   |      x
        + y z               |      (+ y z))
    ;   ↑ notice that for line "\x" indent is seen exactly where arrow shows

    ; use single ":" to add +1 parentheses level:
    :                       | (
      fn [x] : + pow 2      |   (fn [x] (pow x 2))
      3                     |   3)
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- NEW: Syntax, Condensed ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Condensed syntax

`:` symbol at the start of the line is internally temporily expanded to +1 indent level:
> Term "temporarily expanded" will be used a lot here. It actually means that:
> 1. To better understand how `:` at the start of the line works, it is a good mental model to "expand" it first as shown below
> 2. But since wy2hy generates 1-to-1 line correspondent hy code, final hy code is not expanded

```hy
; Example 1:

    ; ↓ implied indent will be assumed at this position
    : fn [x] : + pow 2      | (fn [x] (pow x 2)
      3                     |  3)

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
<!-- NEW: Syntax, One-liners ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Syntax for one-liners

Wy has 3 main symbols for writing one-liners: `::`, `,` and `$`.

`::` is literal `)(`, and there are 2 main cases where it may be usefull:
```hy
    print : + 1 2 :: + 3 4  |   (print (+ 1 2) (+ 3 4))

    print                   |   (print
        + 1 2 :: + 3 4      |        (+ 1 2) (+ 3 4))
```

`,` is emulation of new line. Be aware that you may require using continuator `\`:
```hy
    print                   |   (print
        3 , 4 , \x y, f 3   |       3 4 x y (f 3))

    ; code above is internally temporarily expanded to:
    print                   |   (print
        3                   |       3
        4                   |       4
       \x y                 |       x y
        f 3                 |       (f 3))
```

`$` is placing code on +1 indent level and acts differently depending on:
- if line is started with `:`
- if it does not started with `:`
You may also need to use continuator `\`:

```hy
; Case 1 : line starts with ":"

;     ↓ this exact position will be used as indent level for $
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
;       ↑ new indent position is created at +4 spaces 
```

Final example that shows how symbols `:`, `::`, `,` and `$` interact.
Notice that `,` symbol has highest priority:

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
<!-- NEW: Syntax, Examples ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->


<!-- __________________________________________________________________________/ }}}1 -->




<!-- wy: one-liners ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Syntax elements for one-liners

There are 4 symbols to be discussed: `::`, `LL`, `,` and `$`


`,` is emulation of new line (while actually staying on the same line):
```hy
    print
        3 , 4

;   temporarily expanded internally as:

    print
        3
        4
```

Be aware that you may require using continuator `\` after `,`:
```hy
    print       |   (print
        \x , y  |       x (y))

;   y is parenthesized because above code is
;   temporarily expanded internally as:

    print       |   (print
       \x       |       x
        y       |       (y))
```

`$` is placing code on +1 indent level and acts differently if line is started with bracket-opener (like `:`) or if it does not.

Case when line starts with bracket-opener:
```hy
    : fn [x] (pow x 2) $ 3

;   temporarily expanded internally as:
    :
      fn [x] (pow x 2)
      3
```

And when it does not:
```hy
    print : + x 3 $ 4

;   temporarily expanded internally as:
    print : + x 3
        4
;       ↑
;       will be placed at +4 spaces indent
```

<!-- __________________________________________________________________________/ }}}1 -->





<!-- Intro ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Wy — Hy-lang without parentheses

```hy
defn #^ int                             | (defn #^ int
   \fibonacci                           |     fibonacci
    L #^ int n                          |     [#^ int n]
    if : <= n 1                         |     (if (<= n 1)
      \n                                |         n
       + : fibonacci : - n 1            |         (+ (fibonacci (- n 1))
           fibonacci : - n 2            |            (fibonacci (- n 2)))))
```

```hy
setv x : range : abs -3 :: abs -10      | (setv x (range (abs -3) (abs -10)))
: . lens [1] (get) $ [1 2 3] , print x  | ((. lens [1] (get)) [1 2 3]) (print x)
```

Wy project consists of 2 parts:
* **wy** is a **syntax layer** for Hy-lang
* **wy2hy** is transpiler — it produces hy-code from source wy-code.

> **wy** syntax does not change anything about hy. It does not add new functionality,
> it does not change order of hy function arguments, etc. It just makes indents (and some other symbols) to be seen as implied bracket openers (or closers), that's all.
> This is intended design to provide maximum compatibility with hy.

> **wy2hy** produces readable hy-code with 1-to-1 line correspondence to source wy-code.
> So, when you run your transpiled *.hy file, you'll get meaningfull number lines in debug messages.

Table of Contents:
- [wy syntax](#Wy-as-a-syntax-layer)
  - [processing indents](#Processing-indents)
  - [bracket openers](#Inline-bracket-openers)
  - [one-liners syntax](#Extra-syntax-elements-for-one-liners)
- [wy2hy transpiler](#Using-wy2hy-transpiler)
- [Installation](#Installation)

<!-- __________________________________________________________________________/ }}}1 -->

<!-- wy: all symbols ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Wy as a syntax layer

*Syntax layer* is a polite way to say that Wy is not a standalone language, but just a syntax modification to hy.
To use wy-code, you first transpile it to hy-code (using wy2hy), and then you deal with transpiled *.hy files with original hy infrustructure.

## Wy syntax symbols

This chapter summarizes all symbols that have special recognition in **wy**.
Detailed descriptions of symbol is given below in corresponding chapters.

Main symbols:
- continuator `\` — suppresses automatic opener parentheses
- bracket-openers `:`, `L`, `C`, `#:` and `#C` — opener brackets `(`, `[`, `{`, `#(` and `#{` respectively
  > openers at the beginning and at the mid of the line will have different structural meaning
- hy uses symbols `` ` ``, `'`, `~` and `~@` for macros;
  in wy they may be combined with any of aforementioned 5 openers (with no spaces), for example: `~@#:` is for `~@#(`
  > and of course you can use standalone (those without brackets) hy macros symbols as usual

Symbols usefull for one-liners:
- `::` and `LL` — seen as `)(` and `][` respectively (there is no `CC` symbol as one might expect)
- `,` — separates expressions of the same level
- `$` — marks inline "+1 indent" level

<!-- __________________________________________________________________________/ }}}1 -->
<!-- wy: indents ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Processing indents

Indents introduce and close parentheses, and continuator-symbol `\` prevents from adding opening bracket.
Be aware, that when using continuator, indent level counts from next symbol after `\` — not from symbol `\` itself:
```hy
func    | (func
    y   |    (y)
   \x   |    x
    z   |    z)
;   ↑ all lines are seen as being on the same indent level

func    | (func
    y   |    (y
    \x  |      x
     t  |      (t))
    z   |    z)
;    ↑ x is seen as being on +1 indent level comared to y;
;      (wy sees indend level exactly where arrow shows)
```

Several syntax elements (that are usually not head of s-expression) do not require continuator `\`:
```hy
    func                |   (func
        1               |       1
        .1              |       .1
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
                        |   ; this is obviously meaningless hy code,
                        |   ; but it shows how wy syntax works
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
                        |
                        |   ; this is obviously meaningless hy code,
                        |   ; but it shows how wy syntax works
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- wy: smarkers vs mmarkers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Bracket-openers at different positions

There are 5 bracket-openers (`:`, `L`, `C`, `#:` and `#C`) and any of them can be prefixed with hy macro-symbols (`` ` ``, `'`, `~` and `~@`).
Their behaviour depends on their position, which can be:
- at the start of the line
- in the middle of the line

For simplicity we will focus on `:` bracket-opener, but described behaviour is the same for other bracket-openers.

At start of the line `:` is expanded to give +1 indent level.
```hy
;     this is where wy  |
;     will see indent   |
;     ↓
    : fn [x] (pow x 2)  | ( (fn [x] (pow x 2)
      3                 |   3)
                        |
;     internally wy     |
;     will temporarily  |
;     expand above to:  |
    :                   | (
      fn [x] (pow x 2)  |   (fn [x] (pow x 2)
      3                 |   3)
```

In the middle of the line `:` does NOT introduce new indent level, it will always close at the END OF THE LINE:
```hy
    print : + x y           | (print (+ x y)
          7                 |        7)

    print : + x : abs 3     | (print (+ x (abs 3))
          7                 |        7)
```

Same rules apply to other openers:
```hy
    L 1 2 3 L 4 5 6     |   [ 1 2 3 [4 5 6]
      7 8 : + 2 3       |     7 8 (+ 2 3)]

;     internally seen   |
;     as:               |
    L                   |   [
      1 2 3 L 4 5 6     |     1 2 3 [4 5 6]
      7 8 9             |     7 8 9]
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




