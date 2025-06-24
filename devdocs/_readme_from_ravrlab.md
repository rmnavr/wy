---
title: "Wy — Hy-lang without parenthesis"
date: 2025-06-01
description: "(in the process)"
en_menu: true
---

<!-- Intro ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

Wy project consists of 2 parts:
* **wy** is a **syntax layer** for Hy-lang 
* **wy2hy** is transpiler — it produces hy-code from source wy-code.

> **wy** syntax does not change anything about hy. It does not add new functionality,
> it does not change order of hy function arguments, etc. It just makes indents (and some other symbols) to be seen as implied bracket openers (or closers), that's all.
> This is intended design to provide maximum compatibility with hy.

> **wy2hy** produces readable hy-code with 1-to-1 line correspondence to source wy-code.
> So, when you run your transpiled *.hy file, you'll get meaningfull number lines in debug messages.

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Example ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Code Example

{{< columns >}}
With **wy2hy** this **wy** code \...
```python
defn #^ int                     |   (defn #^ int
   \fibonacci                   |       fibonacci
    L #^ int n                  |       [#^ int n]
    if : <= n 1                 |       (if (<= n 1)
      \n                        |           n
       + : fibonacci : - n 1    |           (+ (fibonacci (- n 1))
           fibonacci : - n 2    |              (fibonacci (- n 2)))))
```
<--->
\... will be transpiled to this hy-code:
```hy
(defn #^ int
    fibonacci
    [#^ int n]
    (if (<= n 1)
        n
        (+ (fibonacci (- n 1))
           (fibonacci (- n 2)))))
```
{{< /columns >}}


<!-- __________________________________________________________________________/ }}}1 -->

# Details — Syntax elements

For general syntax:

<!-- Indent ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

{{< collapsible head="**Indent**" >}}

```hy
func        |   (func
   \x y     |        x y)

func        |   (func
    x       |       (x)
    y       |       (y)
   \z       |       z)
```

{{< /collapsible >}}

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Linestarters ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

{{< collapsible head="**Inline indenters**" >}}

* `:` `L` `C` are essentially `(` `[` `{` (respectively)
  > This marks the stupidest syntax design decision in the history of programming:
  > letters `L` and `C` (also `LL`, see below) are sacrificed and can't be used standalone in Wy.
  > It means you can't name variables like `setv L 1`, but you can still access attributes like `rectangle.L` or use it in strings like `"L"`
  > I can only suggest using smth like `L_` for variables names for now.

* also `#:` `#C` are `#(` `#{`
* all possible hy macro-symbols like `~@` can be combined with bracket-openers like: `~@#:`
* `\` forces line to be continuation-line, also marks new indent position
  > This marks second most stupidest syntax design decision in the history of programming:
  > ... no-indent-files will have limits (TODO) ...
* All hy brackets and macro-symbols are usable as-is

{{< /collapsible >}}

<!-- __________________________________________________________________________/ }}}1 -->
<!-- \ Continuator ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

{{< collapsible head="**Continuator \\**" >}}

> `\` is continuator. It means no opener bracket will be introduced in compilation. Also, some other things
> (digits, strings, keywords, annotations `#^`, comments `#_`, splats `#*` `#**`,
> standalone macros marks `~@` `~` `ʼ` `'` and any brackets possibly with `#` and macro-marks like `~@#(`)
> are auto-continued.

```hy
    print               |   (print
        1.7             |       1.7
        f"smth"         |       f"smth"
        dict            |       (dict 
            :x 3        |           :x 3)
        #_ "123"        |       #_ "123"
        #* list1        |       #* list1
        #** dict1       |       #** dict1)
                        |
    setv                |   (setv
        #^ int x 3      |       #^ int x 3)
```


{{< columns >}}
With **wy2hy** this **wy** code \...
```python
    x 3
    1.7
    f"smth"
    dict 
        :x 3
    #_ "123"

```
<--->
\... will be transpiled to this hy-code:
```hy
(defn #^ int
    fibonacci
    [#^ int n]
    (if (<= n 1)
        n
        (+ (fibonacci (- n 1))
           (fibonacci (- n 2)))))
```
{{< /columns >}}

{{< /collapsible >}}

<!-- __________________________________________________________________________/ }}}1 -->

For one-liners:

<!-- One-liners ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

* `::` is essentially `)(`
* `LL` is essentially `][`
* `,` puts lines to the same indent level
* `$` is kind of «applicator» — it places code coming after it to +1 indent level (but you will be forbidden to write code at +1 level after line with applicator)

<!-- __________________________________________________________________________/ }}}1 -->








