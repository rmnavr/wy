
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

Upon installing wy, it also installs 2 hidden modules: `ipy_hy` and `ipy_wy`.

<!-- wy ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# ipy_wy

ipy_wy adds `wy` and `wy_spy` magics to ipython.

To execute wy code in ipython:
1. Load ipy_wy in ipython:
   ```hy
   %load_ext ipy_wy
   ```
2. You can now send wy code to ipython.

   Single line:
   ```hy
   %wy setv x 3 , print x
   ```
   *(notice that `,` here is just wy's one-liner symbol)*

   Multiline:
   ```hy
   %%wy
       setv x 3
       print x
   ```

You can also use `%wy_spy` and `%%wy_spy` commands,
which will print transpiled hy code before evaluating it.

> %wy magic was tested in environment that is accessed by command (on Windows):
> ```
> C:\\minconda3\\Scripts\\activate.bat C:\\minoconda3 && ipython
> ```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- hy ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# ipy_hy

ipy_hy adds `hy_` magic to ipython.
It is included in wy package just for convenience.

> ipy_hy is a copy of [hy-ipython](https://pypi.org/project/hy-ipython/0.0.1/), which
> adds `hy` magic. So in case you have hy-ipython installed, wy won't mess with it,
> since it uses `hy_` instead of `hy`

To execute hy code in ipython:
1. Load ipy_hy in ipython:
   ```hy
   %load_ext ipy_hy
   ```
2. You can now send hy code to ipython.

   Single line:
   ```hy
   %hy_ (setv x 3) (print x)
   ```

   Multiline:
   ```hy
   %%hy_
       (setv x 3)
       (print x)
   ```

<!-- __________________________________________________________________________/ }}}1 -->

# Known issue regarding sets

hy-ipython (and thus ipy_hy and ipy_wy) internally uses
`hy.read` to send code to ipython.
And there is small hy.read bug in hy 1.0.0 regarging sets.

When sending hy-code `#{1}` to ipython via hy-ipython
(internally it will call `(hy.read "#{1}")`),
it will be seen as reader macro `#1` instead of set `#{1}`.
> By the way, `#{1 1}` has no such problem — it is seen as set `#{1}` as it should be.

Anyway, when wy2hy sees `#{1}` or `#C 1`, it transpiles it to usual `#{1}`,
and what hy (or hy.read) makes of it — is on their consciousness.
