
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


