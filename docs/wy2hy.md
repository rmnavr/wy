
---
wy syntax:
1. [Syntax overview](https://github.com/rmnavr/wy/blob/main/docs/01_Overview.md)
2. [Basic syntax](https://github.com/rmnavr/wy/blob/main/docs/02_Basic.md) 
3. [Condensed syntax](https://github.com/rmnavr/wy/blob/main/docs/03_Condensed.md)
4. [One-liners](https://github.com/rmnavr/wy/blob/main/docs/04_One_liners.md) 
5. [List of all special symbols](https://github.com/rmnavr/wy/blob/main/docs/05_Symbols.md)

running wy code:
1. [wy2hy transpiler](https://github.com/rmnavr/wy/blob/main/docs/wy2hy.md) 
2. [wy-ipython](https://github.com/rmnavr/wy/blob/main/docs/wy_ipython.md) 
---

# wy2hy transpiler

Once wy is installed, you acquire `wy2hy` executable (usually placed at some place like `../conda/Scripts`).

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
```

<!-- __________________________________________________________________________/ }}}1 -->

