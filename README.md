
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

Example code from real project:

<p align="center">
<img src="https://github.com/rmnavr/wy/blob/main/examples/RL_example.png?raw=true" alt="Wy example" />
</p>

> More examples: [/examples](https://github.com/rmnavr/wy/blob/main/examples)

---

Wy is a **syntax layer** for hy, meaning that wy is not a standalone language, but just a syntax modification to hy.
Wy does not change anything about hy rather than removing parentheses.

To run wy code, you first transpile it into hy code using **wy2hy** transpiler, and then you deal with transpiled *.hy files as usual.
> Example shell command:
> ```
> wy2hy 1.wy 1.hy && hy 1.hy
> ```

**wy2hy** produces readable hy-code with 1-to-1 line correspondence to source wy-code.
It means that running transpiled *.hy file will give meaningfull number lines in error messages.

ipython plugin for wy is also available, see [wy-ipython](https://tobedone) (it adds magic commands to ipython).
> Example of calculating ipython cell:
> ```hy
> %%wy
>     setv x 3
>     print x
> ```

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
2. [wy-ipython](https://github.com/rmnavr/wy/blob/main/docs/wy_ipython.md) 

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

# Project status

**Wy and wy2hy are fully documented and fully usable.**

On the TODO list:
* **Make TAB length configurable** (currenlty TAB is considered to be 4 spaces wide)
* Test on Linux (infamous `\n` vs `\n\r` issue)
* Allow usage of unicode chars in names
* Make error mesages meaningfull
* Rigorous testing for reader macros transpiling is required
* Forbid user from writing meaningless code (like for example `$ <$ <$`)

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Changelog ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Changelog

* 26 oct 2025 (0.4.1) — added instructions for running wy in ipython
* 07 oct 2025 (0.4.0) — updated wy2hy API
* 04 aug 2025 (0.3.0) — first public release

<!-- __________________________________________________________________________/ }}}1 -->

