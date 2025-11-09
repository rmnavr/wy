
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

Upon installing wy, it also silently installs 2 hidden modules: `ipy_hy` and `ipy_wy`.

# ipy_wy

ipy_wy adds `wy` and `wy_spy` magics to ipython.

Load ipy_wy in ipython:
```hy
%load_ext ipy_wy
```
You can now send wy code to ipython via:
```hy
%wy setv x 3 , print x
```
*(notice that `,` here is just wy's one-liner symbol)*

Or:
```hy
%%wy
    setv x 3
    print x
```

You can also use `%wy_spy` and `%%wy_spy` commands,
which will also print transpiled hy code before evaluating it.

> %wy magic was tested in environment that accessed by command (on Windows):
> ```
> C:\\minconda3\\Scripts\\activate.bat C:\\minoconda3 && ipython
> ```

# ipy_hy

ipy_hy adds `hy_` magic to ipython.
It is included in wy package just for convenience.

> ipy_hy is a copy of [hy-ipython](https://pypi.org/project/hy-ipython/0.0.1/), which 
> adds `hy` magic. So in case you have hy-ipython installed, wy won't mess with it,
> since it uses `hy_` instead of `hy`


Load ipy_hy in ipython:
```hy
%load_ext ipy_hy
```

You can now send hy code to ipy with:
```hy
%hy_ (setv x 3) (print x)
```

Or:
```hy
%%hy_
    (setv x 3)
    (print x)
```

