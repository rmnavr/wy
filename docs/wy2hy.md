
---
wy syntax:
1. [Syntax overview](https://github.com/rmnavr/wy/blob/main/docs/01_Overview.md)
2. [Basic syntax](https://github.com/rmnavr/wy/blob/main/docs/02_Basic.md) 
3. [Condensed syntax](https://github.com/rmnavr/wy/blob/main/docs/03_Condensed.md)
4. [One-liners](https://github.com/rmnavr/wy/blob/main/docs/04_One_liners.md) 
5. [List of all special symbols](https://github.com/rmnavr/wy/blob/main/docs/05_Symbols.md)

running wy code:
1. [wy2hy transpiler](https://github.com/rmnavr/wy/blob/main/docs/wy2hy.md) 
2. [wy in ipython](https://github.com/rmnavr/wy/blob/main/docs/ipywy.md) 
---

# wy2hy transpiler

Once wy is installed, you acquire `wy2hy` executable
(usually placed at some place like `../conda/Scripts`).

<!-- wy2hy ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Using wy2hy

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

<!-- __________________________________________________________________________/ }}}1 -->
<!-- workflow ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Running wy files

Obvious quick way to run *.wy files is to chain 2 commands in shell:
```
    wy2hy 1.wy && hy 1.hy 

    wy2hy main.wy sub1.wy sub2.wy && hy main.hy 
```

When transpilation of at least one file fails, wy2hy exits with sys.exit(1),
thus avoiding evaluating older version of transpiled *.hy file
if it exists (this is indended behaviour of `&&` in shell).

<!-- __________________________________________________________________________/ }}}1 -->

# Calling wy transpiler from hy/py

<!-- details ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

You can use several functions to call wy transpilation from hy (or py).
They all run the same transpilation, but have different behaviour
regarding error messages.

```hy

    (import wy [ transpile_wy2hy ])

    (transpile_wy2hy   ; will raise function call trace
        "x <$ y")      ; when error is encountered

    ; ---------------------------------------------------

    (import wy [ run_wy2hy_transpilation ])
    (import wy [ successQ unwrapS unwrapE ])

    (setv result
        (run_wy2hy_transpilation   
             "x <$ y"
             :silent True))

    ; - It actually returns Result monad lol
    ; - with silent=False will immediately print 
    ;   user-friendly error message when encountered

    ; You don't have to understand how Result monad works,
    ; just use this code to extract data:
    (if (successQ result)
        (unwrapS result)          ; extracts correct (S is for "Success") HyCode as a string
        (. (unwrapE result) msg)) ; extracts user-friendly msg (E is for "Error") as a string

    ; ---------------------------------------------------

    (import wy [ print_wy2hy_steps ])

    (print_wy2hy_steps "x <$ y"
                       :pretty_errors True))

    ; will produce readable result of each transpilation step;
    ; will print eather function call trace (when pretty_errors=False)
    ; or user-friendly message (same as for run_wy2hy_transpilation)
    ; on error

```

<!-- __________________________________________________________________________/ }}}1 -->

