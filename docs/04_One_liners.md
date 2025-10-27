
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

<!-- Pre Intro ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# One-liners

One-liners is advanced wy topic, that enables writing even more condensed code like:

```hy
; Example 1:

    map $ fn [x y] : * : + x 3 :: + y 4 , \xs ys

    ; this transpiles into:
    (map (fn [x y] (* (+ x 3) (+ y 4))) xs ys)

; Example 2:

    : Constructor x <$ \y <$ \z
      5

    ; this transpiles into:
    ((((Constructor x) y) z)
      5)
```

Internally wy one-liners symbols are just syntactic sugar for indenting and wrapping.
You don't need to use them if you don't want to — basic and condensed syntax is already enough for writing code.

<!-- __________________________________________________________________________/ }}}1 -->

<!-- Intro ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Syntax for one-liners

Wy has following symbols for writing one-liners (from highest precedence to lowest):
* `:` (and other openers) at the start of the line — highest level wrapper
* `<$` — reverse applicator
* `$` — applicator
* `,` — joiner
* `:` (and other openers) at mid of the line — single line wrapper

Other important symbols that have their special rules are:
* `\` — continuator
* `::` (and other similar) — literal `)(`

> Those "other openers" and "other similar" are described in [List of all special symbols](https://github.com/rmnavr/wy/blob/main/docs/05_Symbols.md)

Realistically, there are just several readable one-liners patterns.
Still, one-liners have strict rules of interaction, which are good to know as a whole system.

Code examples in this chapter in most cases are not very meaningfull, still their main goal is to demonstrate how wy2hy will treat one-liners.

<!-- __________________________________________________________________________/ }}}1 -->
<!-- General rules ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# General rules

Symbols `,`, `$` and `<$` emulate new lines, this is why they can introduce condensed openers in middle of the line:
```hy
  ; those are seen as condensed openers (they will be expanded at some level)
  ; ↓         ↓         ↓          ↓
    : f : x $ : g : y , : k : z <$ : m : t
  ;     ↑         ↑         ↑          ↑
  ;     those are seen as normal openers (they will NOT be expanded on new lines)
```

Continuator `\` is allowed only in the following positions:
```hy
   : :\: f      ; right after condensed opener (every opener after it will be seen as non-condensed opener)
  \f            ; at line start
   f $ \x       ; directly after $
   f <$ \x      ; directly after <$
   f , \x       ; directly after ,

; this placement of \ is illegal (since it makes no sense):
   : x \ y

;       will be seen as condensed opener
;       ↓
   f  $ : \: x  ; openers coming after $  and preceading \ will be seen as condensed openers
   f <$ : \: x  ; openers coming after <$ and preceading \ will be seen as condensed openers
   f ,  : \: x  ; openers coming after ,  and preceading \ will be seen as condensed openers

   ; space after \ is allowed:
   : \   f <$ \   x
```

You'll see those rules in action in examples below.

<!-- __________________________________________________________________________/ }}}1 -->
<!-- , ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Joiner `,`

`,` is emulation of new line. Be aware that you may require using continuator `\`:
```hy
print
    3 , f : + x 3 , \x

; code above is internally temporarily expanded to:
print
    3
    f : + x 3
   \x
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- $ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Applicator `$`

`$` is emulation of +1 indent. Be aware that you may require using continuator `\`:
```hy
; Example 1:

    f : x $ g : y $ k : m       | (f (x) (g (y) (k (m))))

    ; code above is internally temporarily expanded to:
    f : x
        g : y
            k : m

; Example 2:

    map $ fn [x y] : + x y 3 , \xs , get yss 3

    ; code above is internally temporarily expanded to:
    lmap
        fn [x] : + x y 3
       \xs
        get yss 3
```

> Writing indented lines after lines with $ is not recommended (it will be completely forbidden in future releases).
> 
> Example:
> ```hy
> f $ x
>     y
> 
> ; line with "y" is indented after line with "$" — in this case
> ; wy2hy does not guarantee to produce meaningfull hy code,
> ; because it is unclear how to interpret it
> ```
>

<!-- __________________________________________________________________________/ }}}1 -->
<!-- <$ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Reverse applicator `<$`

`<$` wraps previous expression and applies it to given arguments.
Be aware that you may require using continuator `\`:

```hy
object1 adder <$ \x             | ((object1 adder) x)

; code above is internally temporarily expanded to:
:
  object1 adder
 \x
```

Multilevel example:
```hy
object1 adder <$ \x <$ + y 3    | (((object1 adder) x) (+ y 3))

; code above is internally temporarily expanded to:
:
  :
    object1 adder
   \x
  + y 3
 ```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- :: ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Double mid brackets `::`
Simpliest one-liner symbol is `::`, it is literally `)(`, and that's it. No other special rules apply.
There are several cases where it may be usefull:

```hy
print : + 1 2 :: + 3 4      |   (print (+ 1 2) (+ 3 4))

print                       |   (print
    + 1 2 :: + 3 4          |        (+ 1 2) (+ 3 4))

: f 3 :: f 4 :: f 5         |   ((f 3) (f 4) (f 5))
; line above is internally temporarily expanded to:
:                           |   (
  f 3 :: f 4 :: f 5         |     (f 3) (f 4) (f 5)
```

Be aware that wy2hy does NOT enforce placing `::` in correct place,
so you may end with incorrect hy code if used mindlessly:
```hy
\x :: print                 |   x )( print
```

There are also `LL`, `CC`, `:#:` and `C#C` symbols — they represent `][`, `}{`, `) #(` and `} #{` respectively.
And they all act in the same manner as described for `::`.

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Interactions ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Closing various openers

Notice that one-liners symbols like `$` will successfully close not only `:` levels, but also `L`, `C` (and others) as expected:
```hy
    map : fn [x y] L y x $ xs ys    | (map (fn [x y] [y x]) xs ys)

    ; line above will be internally temporarily expanded to:
    map : fn [x y] L y x
        xs ys
```


# Interactions of one-liners

Remember precedence order of one-liners:
1. One or more `:` at the start of the line (seen as condensed `:`) have highest priority.
2. Then respectively `<$`, `$`, `,` and mmarker `:` 
3. `\` and `::` have their own rules, that are "orthogonal" to precedence order logic

There are 2 rules that help understanding how symbols internally emulating new lines (`,`, `$`, `<$`) interact with condensed openers (like `:`) :
1. Symbols `,`, `$` and `<$` do NOT expand into additional wrapping levels represented by condensed openers
2. Code after `,`, `$` and `<$` symbols can introduce new condensed openers in the middle of the line (see [General rules (for one-liners)](#General-rules))

All of that can be understood in one (although very contrived and mostly unreadable) example:
```hy
  ; all these ":" are seen as condensed openers
  ; ↓ ↓                ↓               ↓
    : : f x : y :: z $ : k : m , \t <$ : x $ 7 <$ 5
  ;         ↑              ↑
  ;         those are seen as normal (non-condensing) openers

  ; first, leftmost condensed openers are expanded:
    :
      :
        f x : y :: z $ : k : m , \t <$ : x $ 7 <$ 5

  ; then both <$ are expanded (along with their newly created condensed openers):
    :
      :
        : : 
            f x : y :: z $ : k : m , \t
            : 
              x $ 7
          5

  ; then $ are expanded (along with their newly created condensed openers):
    :
      :
        : : 
            f x : y :: z
                : 
                  k : m , \t
            : 
              x
                7
          5

  ; , is the last one:
    :
      :
        : : 
            f x : y :: z
                : 
                  k : m
                 \t
            : 
              x
                7
          5
```



<!-- __________________________________________________________________________/ }}}1 -->

> \>\> Next chapter: [List of all special symbols](https://github.com/rmnavr/wy/blob/main/docs/05_Symbols.md)
