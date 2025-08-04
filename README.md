
<!-- Intro ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Wy — hy-lang without parentheses

Wy offers parentheses-less syntax for [hy lang](https://github.com/hylang/hy)
by usage of indents and set of special symbols.

Example code in wy:

```hy
defn #^ int                         | (defn #^ int
   \fibonacci [#^ int n]            |     fibonacci [#^ int n]
    if : <= n 1                     |     (if (<= n 1)
      \n                            |         n
       + : fibonacci : - n 1        |         (+ (fibonacci (- n 1))
           fibonacci : - n 2        |            (fibonacci (- n 2)))))

; one-liners:
setv x : range : abs -3 :: abs -10  | (setv x (range (abs -3) (abs -10)))
map $ fn [x] : + x 1 , range 0 10   | (map (fn [x] (+ x 1)) (range 0 10))
```

---

Wy is a **syntax layer** for hy, meaning that wy is not a standalone language, but just a syntax modification to hy.
Wy does not change anything about hy rather than removing parentheses.

To run wy code, you first transpile it into hy code using **wy2hy** transpiler, and then you deal with transpiled *.hy files as usual.

**wy2hy** produces readable hy-code with 1-to-1 line correspondence to source wy-code.
It means that running transpiled *.hy file will give meaningfull number lines in debug messages.

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Docs ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Documentation

1. [Syntax overview](https://github.com/rmnavr/wy/blob/main/docs/01_Overview.md)
2. [Basic syntax](https://github.com/rmnavr/wy/blob/main/docs/02_Basic.md) 
3. [Condensed syntax](https://github.com/rmnavr/wy/blob/main/docs/03_Condensed.md)
4. [One-liners](https://github.com/rmnavr/wy/blob/main/docs/04_One_liners.md) 
5. [List of all special symbols](https://github.com/rmnavr/wy/blob/main/docs/05_Symbols.md)

<!-- __________________________________________________________________________/ }}}1 -->
<!-- wy2hy ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Using wy2hy transpiler

Once wy is installed (see [Install](#Install) section) you can run in the terminal:

```
wy2hy your_source_name.wy
```

It will generate `your_source_name.hy` file and immediately run it.

There are also run options like for example:
```
wy2hy _wms your_source_name.wy
```
> Options are given via "_" prefix (instead of traditional "-") to avoid messing with hy options.
* `_w` — only [W]rite transpiled hy-file in the same dir as source wy-file
* `_f` (default) — same as `_w`, but after writing, immediately run transpiled [F]ile from it's dir
  > If full filename for source file is given (like "C:\\users\\username\\proj1\\your_source_name.wy"), wy2hy will change script's dir to dir of this file.
  > This enables your transpiled code to import other project files lying in the same dir, which is intended way of using `f` and `m` options.
* `_m` — transpile and run from [M]emory (meaning, no file will be written on disk)
  > 1. If any error occurs in transpiled code, debug messages will be polluted with wy2hy.hy calls
  > 2. `_m` might fail in case of tricky imports inside transpiled files
  > In general `_f` is strongly recommended over `_m`
* `_s` - [S]ilent mode, won't write any transpilation status messages

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Dependencies ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Dependencies

Tested with:
* hy 1.0.0
* hyrule 1.0.0
* funcy 2.0
* pyparsing 3.0.9
* pydantic 2.11.7
* lenses 1.2.0

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Status ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Project status

**Wy and wy2hy are fully documented and fully usable.**

> There might be some obscure edge cases that transpile improperly, which I didn't discover yet.
> Also, tested only on Windows.
> 
> Please reach out to me if you are experiencing difficulties in launching wy2hy.
> This is my first serious opensource Python/Hy project, meaning I might be unaware of various caveats in Python packaging.

There are some minor things on the TODO list:
* Features to implement:
  * Shebang line recognition
  * Rigorously test reader macro
  * Allow usage of unicode chars in names (currently unicode is recognized only in comments and quoted strings)
  * Currently TAB symbol is seen as 4 spaces wide, make it configurable
* Polishing:
  * Make error mesages meaningfull
  * Forbid user from writing meaningless code (like for example `$ <$ <$`)
  * Increase performance (200 lines of wy code transpile in ~0.3s on my 16-core laptop, which is kind of slow)
  * Remove dependency from lens and pydantic libs

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Install ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Installation

```
pip install git+https://github.com/rmnavr/wy.git@0.3.0
```

<!-- __________________________________________________________________________/ }}}1 -->

