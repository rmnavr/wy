
```hy
wy syntax                               | equivalent hy syntax
```

```hy
defn #^ int                             | (defn #^ int
   \fibonacci                           |     fibonacci
    L #^ int n                          |     [#^ int n]
    if : <= n 1                         |     (if (<= n 1)
      \n                                |         n
       + : fibonacci : - n 1            |         (+ (fibonacci (- n 1))
           fibonacci : - n 2            |            (fibonacci (- n 2)))))
```

```hy
setv x : range : abs -3 :: abs -10      | (setv x (range (abs -3) (abs -10)))
: . lens [1] (get) $ [1 2 3] , print x  | ((. lens [1] (get)) [1 2 3]) (print x)
```

# Wy — Hy-lang without parenthesis

Wy project consists of 2 parts:
* **wy** is a **syntax layer** for Hy-lang 
* **wy2hy** is transpiler — it produces hy-code from source wy-code.

> **wy** syntax does not change anything about hy. It does not add new functionality,
> it does not change order of hy function arguments, etc. It just makes indents (and some other symbols) to be seen as implied bracket openers (or closers), that's all.
> This is intended design to provide maximum compatibility with hy.

> **wy2hy** produces readable hy-code with 1-to-1 line correspondence to source wy-code.
> So, when you run your transpiled *.hy file, you'll get meaningfull number lines in debug messages.

Table of Content:
- [wy syntax](#Wy-as-a-syntax-layer)
  - [processing indents](#Processing-indents)
  - [bracket openers](#Inline-bracket-openers)
  - [one-liners syntax](#Extra-syntax-elements-for-one-liners)
- [wy2hy transpiler](#Using-wy2hy-transpiler)

# Wy as a syntax layer

*Syntax layer* is a polite way to say that Wy is not a standalone language, but just a syntax modification to hy.
To use wy-code, you first transpile it to hy-code (using wy2hy), and then you deal with transpiled *.hy files with original hy infrustructure.

## Processing indents

Indents introduce and close brackets, and continuator-symbol `\` prevents from adding opening bracket.
Be aware, that when using continuator, indent level counts from next symbol after `\` — not from symbol `\` itself:
```hy
func   | (func
    y  |    (y)
   \x  |    x
    z  |    z)
;   ↑ all lines are seen as being on the same indent level

func   | (func
    y  |    (y
    \x |      x)
    z  |    z)
;    ↑ «x» is seen as being on +1 indent level comared to «y»
```

For elements that can never be head of s-expression, continuator `\` is not necessary.
These elements are: digits, strings, keywords like `:x`, inline comments `#_`, splats `#*` `#**`, annotations `#^`:
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

Opening bracket also will NOT be added for lines starting with:
* any kind of hy-bracket (which are: `(` `#(` `#reader(` `[` `{` `#{`)
* any hy-macro-symbol `` ` ``, `'`, `~`, `~@`
* any combination of the above like `~@#(`
```hy
    print 3       | (print 3)
                  |
    ' x           | ' x
```

## Inline bracket-openers

`~@:` `L` `C`

## Extra syntax elements for one-liners

`$` `,` `::` `LL`

# Using wy2hy transpiler

You need to have **hy** installed for w2h to work.

Usage example: run in the terminal

```
hy "C:\\users\\username\\hyprojs\\wy\\wy2hy.hy" "your_source_name.wy" _wm
```

> You have to provide full adress for wy2hy.hy script, because "your_source_name.wy" will be most likely in some other dir

> Options are given via "_" prefix (instead of traditional "-") to avoid messing with hy options.

> If full filename for source file is given (like "C:\\users\\username\\proj1\\your_source_name.wy"), wy2hy will change script's current dir to dir of this file.
> This enables your transpiled code to import other project files lying in the same dir, which is the most logical way of using `f` and `m` options.

All possible run options (like _wm for example):
* `w` — [W]rite transpiled hy-file in the same dir as source wy-file
* `f` — same as `w`, but after writing, immediately run transpiled [F]ile
* `m` — transpile and run only from [M]emory (meaning, no file will be written on disk);
  > please be aware, that in opposition to `f` option, if any error occurs in transpiled code, debug messages will be polluted with wy2hy.hy calls, so `f` is a preffered way of running
* `s` - [S]ilent mode, won't write any transpilation status messages









