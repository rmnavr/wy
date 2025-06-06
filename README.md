# Wy — Hy-lang without parenthesis

```hy
defn #^ int                     |   (defn #^ int
   \fibonacci                   |       fibonacci
    L #^ int n                  |       [#^ int n]
    if : <= n 1                 |       (if (<= n 1)
      \n                        |           n
       + : fibonacci : - n 1    |           (+ (fibonacci (- n 1))
           fibonacci : - n 2    |              (fibonacci (- n 2)))))
```

Wy project consists of 2 parts:
* **wy** is a **syntax layer** for Hy-lang 
* **wy2hy** is transpiler — it produces hy-code from source wy-code.



> **wy** syntax does not change anything about hy. It does not add new functionality,
> it does not change order of hy function arguments, etc. It just makes indents (and some other symbols) to be seen as implied bracket openers (or closers), that's all.
> This is intended design to provide maximum compatibility with hy.

> **wy2hy** produces readable hy-code with 1-to-1 line correspondence to source wy-code.
> So, when you run your transpiled *.hy file, you'll get meaningfull number lines in debug messages.



