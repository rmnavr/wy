
---
wy syntax:
1. [Syntax overview](https://github.com/rmnavr/wy/blob/main/docs/01_Overview.md)
2. [Basic syntax](https://github.com/rmnavr/wy/blob/main/docs/02_Basic.md) 
3. [Condensed syntax](https://github.com/rmnavr/wy/blob/main/docs/03_Condensed.md)
4. [One-liners](https://github.com/rmnavr/wy/blob/main/docs/04_One_liners.md) 
5. [List of all special symbols](https://github.com/rmnavr/wy/blob/main/docs/05_Symbols.md)

running wy code:
1. [wy2hy transpiler](https://github.com/rmnavr/wy/blob/main/docs/wy2hy.md) 
2. [wy repl](https://github.com/rmnavr/wy/blob/main/docs/repl.md) 
---

Upon installing wy, it also installs 2 hidden modules: `repl_hy` and `repl_wy`.

# repl_hy

repl_hy is a copy of [hy-ipython](https://pypi.org/project/hy-ipython/0.0.1/).
It adds `%hy` and `%%hy` magics to ipython. It is added to wy package just for convenience.

You can send hy code to repl with:
```hy
%hy (setv x 3) (print x)
```

Or:
```hy
%%hy
    (setv x 3)
    (print x)
```

# repl_wy

repl_wy adds `%wy`, `%%wy`, `%wy_spy` and `%%wy_spy` magics to ipython.

You can send wy code to ipython via:
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

You can also use `%wy_spy` and `%%wy_spy` commands, which will spit transpiled hy code into REPL before evaluating it.

