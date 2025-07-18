
<!-- TODO ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->
<!-- 

    - upd ToC

-->
<!-- __________________________________________________________________________/ }}}1 -->

<!-- Intro ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Wy — Hy-lang without parentheses

Wy uses indents to wrap expressions (as many other lisp without parentheses projects).

What wy also brings to the table is:
* Syntax for every possible hy opener, including macros (`(`, `#(`, `[`, `{`, `~@#(`, etc.)
* Sofisticated one-liners syntax with symbols: `\`, `:`, `::`, `,`, `$`, `<$`

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
- `:` opener — represents new wrapper `(` level
- `\` continuator — suppresses automatic wrapping 

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
   \ y                  |      y
    3.0                 |      3.0
    + y z               |      (+ y z))
;   ↑ notice that when \ is used, indent position is exactly next symbol after it even if it is Space

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

Expressions inside any hy brackets (including macros-brackets) are seen as hy lang syntax with any modifications
(wy symbols will have no special recognition inside them):
```hy
print (+                  | (print (+ 
         x                |           x
         (ncut ys 1 : 3)) |           (ncut ys 1 : 3)))

; notice few things here:
; 1) x and y did not require continuator \
; 2) : was not recognized as bracket opener
; This is because everything inside (...) is seen as hy code
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- wy: Condensed ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Condensed syntax

`:` symbol at the start of the line is internally temporarily expanded to +1 indent level:
> Term "temporarily expanded" will be used a lot here. It actually means that:
> 1. To better understand how `:` at the start of the line works (and some other symbols), it is a good mental model to "expand" it first as shown below
> 2. But since wy2hy generates 1-to-1 line correspondent hy code, final hy code is not expanded

To grasp condensed syntax and also one-liners syntax (described in next chapter),
one must clearly understand that `:` acts sligtly different depending on it's 2 possible positions:
* `:` can be at the start of the line (this function of `:` is called "smarker" as for "starting marker")
* `:` in mid of the line ("mmarker" as for "mid marker")

> Please remember this naming of "smarker" and "mmarker" because we will use it extensively.

```hy
  ; smarkers
  ; ↓ ↓
    : : f : x : y
  ;       ↑   ↑
  ;       midmarkers
```

Some examples:

```hy
; Example 1:

  ; wy sees indents at these positions
  ; ↓ ↓
    : fn [x] : + pow 2      | ( (fn [x] (pow x 2))
      3                     |   3)

  ; code above is internally temporarily expanded to:
    :                       | (
      fn [x] : + pow 2      |   (fn [x] (pow x 2))
      3                     |   3)

; Example 2:

  ; wy sees indents at these positions
  ; ↓ ↓ ↓
    : : f x : y | ( ( (f x (y))
        3       |     3)
      4         |   4)

  ; code above is internally temporarily expanded to:
    :           | (
      :         |   (
        f x     |     (f x)
        3       |     3)
      4         |   4)
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- wy: One-liners ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Syntax for one-liners

Wy has following main symbols for writing one-liners (from highest precedence to lowest):
* `:` at the start of the line (smarker) — highest level wrapper
* `<$` — reverse applicator
* `$` — applicator
* `,` — joiner
* `:` at mid of the line (mmarker) — one line wrapper

Other important symbols are:
* `::` — literal `)(`
* `\` — continuator

Realistically, there are just several readable one-liners patterns (that will be summarized in chapter's end).
Still, one-liners have strict rules of interaction, which are good to know as a whole system.

Code examples in this chapter in most cases are not very meaningfull, still their aim is mostly to demonstrate how wy2hy will treat one-liners.
Pay attention to precedence order of symbols in the examples.

<!-- ■ General ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2 -->

### General rules

Continuator `\` is allowed only in the following positions:
```hy
   : : : \f     ; after last smarker
  \f            ; before line without smarkers
   f $ \x       ; directly after $
   f <$ \x      ; directly after <$
   f , \x       ; directly after ,

   f  $ : : \x  ; directly after last smarker after $
   f <$ : : \x  ; directly after last smarker after <$
   f ,  : : \x  ; directly after last smarker after ,
```

Symbols `,`, `$` and `<$` emulate new lines, this is why they can introduce smarkers:
```hy
  ; those are seen as smarkers
  ; ↓         ↓         ↓          ↓
    : f : x $ : g : y , : k : z <$ : m : t
  ;     ↑         ↑         ↑          ↑
  ;     those are seen as mmarkers
```

<!-- _____________________________________________________________________/ }}}2 -->
<!-- ■ :: ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2 -->

### Double mid brackets `::`
Simliest symbol is `::`, it is literally `)(`, and that's it.
There are at least 3 cases where it may be usefull:

```hy
print : + 1 2 :: + 3 4      |   (print (+ 1 2) (+ 3 4))

print                       |   (print
    + 1 2 :: + 3 4          |        (+ 1 2) (+ 3 4))

: f 3 :: f 4 :: f 5         |   ((f 3) (f 4) (f 5))
; line above is internally temporarily expanded to:
:                           |   (
  f 3 :: f 4 :: f 5         |     (f 3) (f 4) (f 5)
```

Be aware that wy2hy does NOT enforce placing `::` in correct place,
so you may end with incorrect hy code if used mindlessly:
```hy
    \x :: print             |   x )( print
```

<!-- _____________________________________________________________________/ }}}2 -->
<!-- ■ , ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2 -->

### Joiner `,`

`,` is emulation of new line. Be aware that you may require using continuator `\`:
```hy
print
    3 , f : + x 3 , \x

; code above is internally temporarily expanded to:
print
    3
    f : + x 3
   \x
```

<!-- _____________________________________________________________________/ }}}2 -->
<!-- ■ $ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2 -->

### Applicator `$`

`$` is emulation of +1 indent. Be aware that you may require using continuator `\`:
```hy
; Example 1:

    f : x $ g : y $ k : m       | (f (x) (g (y) (k (m))))

    ; code above is internally temporarily expanded to:
    f : x
        g : y
            k : m

; Example 2:

    map $ fn [x y] : + x y 3 , \xs , get yss 3

    ; code above is internally temporarily expanded to:
    lmap
        fn [x] : + x y 3
       \xs
        get yss 3
```

<!-- _____________________________________________________________________/ }}}2 -->
<!-- ■ <$ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2 -->

### Reverse applicator `<$`

`<$` wraps previous expression and applies it to given arguments.
Be aware that you may require using continuator `\`:

```hy
object1 adder <$ \x             | ((object1 adder) x)

; code above is internally temporarily expanded to:
:
  object1 adder
 \x
```

Multilevel example:
```hy
object1 adder <$ \x <$ + y 3    | (((object1 adder) x) (+ y 3))

; code above is internally temporarily expanded to:
:
  :
    object1 adder
   \x
  + y 3
 ```

<!-- _____________________________________________________________________/ }}}2 -->
<!-- ■ smarker : interaction ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{2 -->

### Interaction with smarker `:`

Remember, that smarker is `:` that starts the line (and there may be more than 1 of them at line start).

Smarker `:` has highest priority among one-liners. 
Symbols that internally emulate new lines (`,`, `$`, `<$`) do NOT expand into levels introduced by smarkers.

It is better understood in one (although very contrived and unreadable) example:
```hy
  ;       all these ":" are seen as s-markers
  ; ↓ ↓                ↓               ↓
    : : f x : y :: z $ : k : m , \t <$ : x $ 7 <$ 5

  ; first, leftmost smarkers are expanded:
    :
      :
        f x : y :: z $ : k : m , \t <$ : x $ 7 <$ 5

  ; then both <$ are expanded:
    :
      :
        : : f x : y :: z $ : k : m , \t
            : x $ 7
          5

  ; then $ are expanded:
    :
      :
        : : f x : y :: z
            : k : m , \t
            : x
              7
          5

  ; , is the last one:
    :
      :
        : : f x : y :: z
            : k : m
             \t
            : x
              7
          5
```



<!-- _____________________________________________________________________/ }}}2 -->

<!-- __________________________________________________________________________/ }}}1 -->
<!-- wy: Other openers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Other types of openers

We already saw how `:` works both as smarker and mmarker.
There are also other elements that act in the same manner (including condensed syntax and interacting with `$` and `,` symbols), but produce different brackets.

Overall in wy there are:
- bracket-openers `:`, `L`, `C`, `#:` and `#C` — represent opener brackets `(`, `[`, `{`, `#(` and `#{` respectively
- any of these 5 openers can be combined with hy symbols for macros (there are 4 of them: `` ` ``, `'`, `~` and `~@`),
  they must be combined without spaces, for example: `~@#:` is for `~@#(`
  > and of course you can use standalone hy macros symbols as usual
- for one-liners there are `::`, `LL`, `CC`, `:#:` and `C#C` symbols — they represent `)(`, `][`, `}{`, `) #(` and `} #{` respectively

> Yes, symbols `L`, `C`, `LL` and `CC` cannot be directly used as variable names in wy.
> Still, since everything wrapped in (...) and other brackets is seen as hy code,
> you can wrap L inside expression:
>
> ```hy
> ; seeing this code, wy2hy will strictly follow it's rules
> ; and produce following hy code:
> setv L 3          | (setv [3])
>
> ; so in order for L to be recognized as variable (not as "[" bracket),
> ; you'll need to wrap it in brackets, and L will be seen as variable name:
> (setv L 3)
> ```
>
> I am working on designing better solution for this issue.

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

Given rules described above, you are able to write nested lists like so:
```hy
setv xss
    L L L 1 2 3 LL 4 5 6
        L 7 8 9 LL 0 1 2
      L L 1 2 3 LL 4 5 6
        L 7 8 9 LL 0 1 2

; this will be internally temporarily expanded to:
setv xss
   L
     L
       L
         1 2 3 LL 4 5 6
       L
         7 8 9 LL 0 1 2
     L
       L
         1 2 3 LL 4 5 6
       L
         7 8 9 LL 0 1 2
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

When line starts with literal bracket (or any macro-bracket), continuator `\` is also not needed.
And everything inside expressions will be interpreted as normal hy code (without recognizing special wy symbols):
```hy
func                |   (func
    ( L             |       ( L     ; notice that here L is variable name, not bracket opener
    )               |       )
    [ C             |       [ C     ; notice that here C is variable name, not bracket opener
    ]               |       ]
    {               |       {       ; notice that continuator \ was not used here
      x             |         x
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




