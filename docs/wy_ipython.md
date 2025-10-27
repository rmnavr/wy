
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


# wy_ipython

wy_ipython adds `%wy`, `%%wy`, `%wy_spy` and `%%wy_spy` magics to ipython.

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

# Devnote: sending wy code to ipython via hy-ipython

[hy-ipython](https://pypi.org/project/hy-ipython/0.0.1/) adds `%hy` and `%%hy` magic to ipython
(it works with hy 1.0.0, despite doc asking for exactly 0.24).

Having hy-ipython, wy code can be sent to ipython via:
```hy
%%hy
(import wy [convert_wy2hy])

(hy.eval (hy.read_many (convert_wy2hy "
    print 3
    print 4
")))
```

Just be aware that if your code contains `"` or `\`, those need to be escaped.

> For example this wy code:
> ```hy
>     setv x "smth"
>    \x
> ```
> should be passed like this:
> ```hy
> %%hy
> (wy2REPL "
>     setv x \"smth\"
>    \\x
> ")
> ```

All of that can be neatly organized in hotkey (in Vim and similar).
