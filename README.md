
<!-- Intro ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Wy — hy-lang without parentheses

Wy offers parentheses-less syntax for [hy lang](https://github.com/hylang/hy)
by usage of indents and set of special symbols.

Wy does not change anything about hy rather than removing parentheses.

Wy uses **wy2hy** transpiler to produce *.hy files from *.wy files.
You then treat generated *.hy files just like normal *.hy files.

Example code in wy (left column):

```hy
defn #^ int                         | (defn #^ int
   \fibonacci [#^ int n]            |     fibonacci [#^ int n]
    if : <= n 1                     |     (if (<= n 1)
      \n                            |         n
       + : fibonacci : - n 1        |         (+ (fibonacci (- n 1))
           fibonacci : - n 2        |            (fibonacci (- n 2)))))

; special Wy feature — one-liners:
setv x : range : abs -3 :: abs -10  | (setv x (range (abs -3) (abs -10)))
map $ fn [x] : + x 1 , range 0 10   | (map (fn [x] (+ x 1)) (range 0 10))
```

Code from real project:

<p align="center">
<img src="https://github.com/rmnavr/wy/blob/main/examples/RL_example.png?raw=true" alt="Wy example" />
</p>

> More examples: [/examples](https://github.com/rmnavr/wy/blob/main/examples)

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Features ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Features overview

Don't be afraid to try Wy:
* wy2hy produces hy-code with **1-to-1 line correspondence** to source wy-code:
  * You'll get meaningfull number lines in trace messages when raising exceptions in transpiled *.hy files
  * If you decide that Wy is not your cup of tea, just take your transpiled *.hy files and continue from there
* wy2hy produces **user-friendly error messages** when transpilation fails
* Wy works with all 25 kinds of hy parenthesis (including those that are used for macros)
* You can freely mix Wy and Hy code (wy2hy transpiles correct hy expressions as-is)
* All the edge cases (that I could think of) are covered in the testing suite
* Wy and wy2hy are fully documented

Also:
* Wy comes with `%wy` magic for ipython/Jupyter 
* Wy-code can be called directly from Python (by importing `transpile_wy2hy` function)

What not to like?

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Caveats ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Awaited QoL features

There are still some features on the TODO list:
* Make TAB length configurable (currently TAB is hardcoded to be 4 spaces wide)
  > for now convert tabs to spaces before transpiling
  > if you want tabs to be of another lengths
* Allow unicode chars in names
  > unicode symbols are currently only allowed inside strings and comments
* Forbid unmatched hy brackets and unmatched double-quotas
  > currently parser may behave unexpectedly when those are found
* Add shebang line recognition

<!-- __________________________________________________________________________/ }}}1 -->

<!-- Docs ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Documentation

wy syntax:
1. [Syntax overview](https://github.com/rmnavr/wy/blob/main/docs/01_Overview.md)
2. [Basic syntax](https://github.com/rmnavr/wy/blob/main/docs/02_Basic.md) 
3. [Condensed syntax](https://github.com/rmnavr/wy/blob/main/docs/03_Condensed.md)
4. [One-liners](https://github.com/rmnavr/wy/blob/main/docs/04_One_liners.md) 
5. [List of all special symbols](https://github.com/rmnavr/wy/blob/main/docs/05_Symbols.md)

running wy code:
1. [wy2hy transpiler](https://github.com/rmnavr/wy/blob/main/docs/wy2hy.md) 
2. [wy repl](https://github.com/rmnavr/wy/blob/main/docs/repl.md) 

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Install ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Installation

```
pip install git+https://github.com/rmnavr/wy.git@main
```

Dependencies (with versions tested):
* python 3.9
* ipython 8.0
* hy 1.0.0
* hyrule 1.0.0
* funcy 2.0
* pyparsing 3.0.9
* pydantic 2.11.7
* lenses 1.2.0
* termcolor 3.1.0

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Changelog ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Changelog

* Version 0.5.0 (05 nov 2025)
  * for user:
    * added meaningfull error messages for wy2hy
    * added `%hy_`, `%wy` and `%wy_spy` magics to ipython
    * updated wy2hy API
  * internally:
    * updated parser
    * added testing suite for backend and frontend
    * written devdoc on app Architecture
* Version 0.3.0 (04 aug 2025)
  * first public release

<!-- __________________________________________________________________________/ }}}1 -->


