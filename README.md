
<!-- Intro ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Wy — hy-lang without parentheses

Wy offers parentheses-less syntax for [hy lang](https://github.com/hylang/hy)
by usage of indents and set of special symbols.

Example code in wy (left column):

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

Example code from real project:

<p align="center">
<img src="https://github.com/rmnavr/wy/blob/main/examples/RL_example.png?raw=true" alt="Wy example" />
</p>

> More examples: [/examples](https://github.com/rmnavr/wy/blob/main/examples)


<!-- __________________________________________________________________________/ }}}1 -->
<!-- Features ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Features overview

Wy is a **syntax layer** for hy, meaning that wy is not a standalone language,
but just a syntax modification to hy.
Wy does not change anything about hy rather than removing parentheses.

Wy uses **wy2hy** transpiler to produce *.hy files from *.wy files.
You then treat generated *.hy files just like normal *.hy files.

Notable features:
* wy2hy produces hy-code with **1-to-1 line correspondence** to source wy-code
  (you'll get meaningfull number lines in trace messages when raising exceptions in transpiled *.hy files)
* wy2hy also produces **user-friendly error messages** when transpilation fails (or
  when CLI args are provided incorrectly)
* Wy comes with `%wy` magic for ipython/Jupyter 
* Wy-code can be called directly from Python (by importing `transpile_wy2hy` function)
* You can mix wy and hy code: wy2hy parses correct hy expressions as-is (without poking inside them)
* Wy covers all the syntax quirks of hy, including 25 kinds of parenthesis (yes, there are so many)

Also:
* Wy and wy2hy are fully documented
* Testing suite is in place, so most edge cases are covered

What not to like?

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
* hy 1.0.0
* hyrule 1.0.0
* funcy 2.0
* pyparsing 3.0.9
* pydantic 2.11.7
* lenses 1.2.0
* termcolor 3.1.0

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Status ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# On the TODO list

* Make TAB length configurable (currently TAB is hardcoded to be 4 spaces wide)
  > for now convert tabs to spaces before transpiling
  > if you want tabs to be of another lengths
* Add features to parser:
  * Allow unicode chars in names (currently parser ignores them)
  * Forbid orphan brackets (currently parser ignores them)
  * Add shebang line recognition
* Testing in other enveronments is required
  (currently tested only on Windows 10 in conda and ipython)

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
    * written DevDoc on app Architecture
* Version 0.3.0 (04 aug 2025)
  * first public release

<!-- __________________________________________________________________________/ }}}1 -->


