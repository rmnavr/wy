
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

<!-- __________________________________________________________________________/ }}}1 -->
<!-- wy2hy ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Using wy2hy transpiler

Once wy is installed, you acquire `wy2hy` executable
(usually placed at some place like `../conda/Scripts`).

## wy2hy doc

Transpiling single file:
```
usage:

  wy2hy file.wy [file.hy] [-stdout] [-silent]

  file.wy    source for transpilation
  [file.hy]  optional target name (if not given, will be inherited from source name)
  [-stdout]  do not produce *.hy file, print directly to stdout instead
  [-silent]  suppresses transpilation messages (has no effect on -stdout option)

examples:

  wy2hy user_file.wy          // transpile to user_file.hy (inherits name from *.wy file)
  wy2hy 1.wy output/1.hy      // transpile to output/1.hy
  wy2hy user_file.wy -stdout  // print transpilation result to stdout
```

Transpiling several files:
```
usage:
  wy2hy file1.wy [file1.hy] file2.wy [file2.hy] ... [-silent]

  - when *.hy files are not provided, their names will be inherited from source name

examples:
  wy2hy 1.wy 2.wy 3.wy          // will be transpiled to: 1.hy, 2.hy and 3.hy
  wy2hy 1.wy 2.wy aa/2.hy 3.wy  // will be transpiled to: 1.hy, aa/2.hy, 3.hy
```

`-silent` option suppresses transpilation messages.
It will have no effect when used with `-stdout`.

## Usage workflow

Obvious quick way to run *.wy files is to chain 2 commands in shell:
```
    wy2hy 1.wy && hy 1.hy 
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Status ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Project status

**Wy and wy2hy are fully documented and fully usable.**

On the TODO list:
* **Make TAB length configurable** (currenlty TAB is considered to be 4 spaces wide)
* Allow usage of unicode chars in names
* Make error mesages meaningfull
* Rigorous testing for reader macros transpiling is required
* Forbid user from writing meaningless code (like for example `$ <$ <$`)

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Changelog ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Changelog

* 07 oct 2025 (0.4.0) — updated wy2hy API
* 04 aug 2025 (0.3.0) — first public release

<!-- __________________________________________________________________________/ }}}1 -->

