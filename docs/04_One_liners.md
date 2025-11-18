
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

<!-- Intro ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# One-liners intro

One-liners is advanced wy topic, that enables writing even more condensed code like:

```hy
; Example 1:

    map $ fn [x y] : * : + x 3 :: + y 4 , \xs ys
    ;   ↑                               ↑
    ; those 2 symbols are main separators here;
    ; focusing on them should make this readable

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
You don't need to use them if you don't want to — basic and condensed syntax are already enough for writing code.

One-liners do not have set-in-stone usage patterns.
They do obey strict rules described below, but there are usually many ways to express the same thing.
Like for example all those lines produce the same code:
```hy
  ((fn [x y] (+ x y)) xs ys)     ; hy-code parsed as-is
  fn [x y] (+ x y) <$ \xs ys     ; reasonably readable one-liner
  : \: fn [x y] : + x y , \xs ys ; correct, but has bad readability
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Overview ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Syntax overview for one-liners

Wy has following symbols for writing one-liners (from highest precedence to lowest):
* `:` (and other openers) at the start of the line — highest level wrapper
* `<$` — reverse applicator
* `$` — applicator
* `,` — joiner
* `:` (and other openers) at mid of the line — single line wrapper

Precedence order is crucial when several one-liner symbols are used on the same line.

Symbols that have special rules which are "orthogonal" to precedence rules:
* `\` — continuator
* `::` (and other similar) — literal `)(`

<!-- __________________________________________________________________________/ }}}1 -->

# Description of individual one-liner symbols
<!-- , ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Joiner `,`

Joiner `,` is emulation of new line.

Be aware that you may require using continuator `\`:
```hy
print                   | (print
    3 , f : + x 3 , \x  |      3 (f (+ x 3)) x)

; code above is internally temporarily expanded to:
print                   | (print
    3                   |      3
    f : + x 3           |      (f (+ x 3))
   \x                   |      x)
```


<!-- __________________________________________________________________________/ }}}1 -->
<!-- $ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Applicator `$`

Applicator `$` is emulation of +1 indent.
Be aware that you may require using continuator `\`:
```hy
f $ g x       | (f (g x))
f $ g x $ h y | (f (g x (h y))

; last line is internally temporarily expanded to:
f
  g x
      h y
```

Using applicator with continuation expression (to the left of `$`) is forbidden:
```hy

; this is correct:
  f $ g x   | (f (g x))

; this is correct:
  f $\a b   | (f a b)

; this is incorrect:
 \f $ g x   | <will not transpile>
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- <$ ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Reverse applicator `<$`

`<$` wraps previous expression and applies it to given arguments.
Be aware that you may require using continuator `\`:

```hy
object1 adder <$ \x  | ((object1 adder) x)

; code above is internally temporarily expanded to:
:
  object1 adder
 \x
```

Multilevel example is little bit less streightforward than for `,` and `$`:
```hy
object1 adder <$ \x <$ + y 3    | (((object1 adder) x) (+ y 3))

; code above is internally temporarily expanded to:
:
  :
    object1 adder
   \x
  + y 3
```

You can even have `<$` with no expression to the right:
```hy
  f <$     | ((f))
  f <$ <$  | (((f)))
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- :: ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Double mid brackets (`::` and others)
Simpliest one-liner symbol is `::`, and it is literally `)(`, and that's it.
No other special rules apply.
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

Wy2hy does NOT fully check if `::` is in correct place,
so you may end up with incorrect hy code if used without caution:
```hy
\x :: print                 |   x )( print
```

There are also `LL`, `CC`, `:#:` and `C#C` symbols — they represent `][`, `}{`, `) #(` and `} #{` respectively.
And they all act in the same manner as described for `::`.

<!-- __________________________________________________________________________/ }}}1 -->

# General one-liners rules
<!-- Indenting after one-liner ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Rules for indenting

Lines coming directly after lines with `<$`, `$` or `,` symbol can't start with increased indents:
```hy
; correct syntax:
: f , 3  | ( (f) 3
  z      |   (z))

; correct syntax:
: f , 3  | ( (f) 3
  : x    |   ( (x)))

; incorrect syntax
: f , 3  | <will not transpile>
   z     | 

; correct syntax:
: f 3    | ( (f 3
   z     |   (z))
```

This rule exists because allowing such indent in many cases
would make user intent ambiguous.

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Closing var openers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Closing various openers

As expected, one-liners symbols like `$` will successfully close not only `:` levels, but also `L`, `C` (and others):
```hy
    map : fn [x y] L y x $ xs ys    | (map (fn [x y] [y x]) xs ys)

    ; line above will be internally temporarily expanded to:
    map : fn [x y] L y x
        xs ys
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Whitespace ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Whitespace policy

Same as mentioned in [Basic syntax](https://github.com/rmnavr/wy/blob/main/docs/02_Basic.md),
one-liner symbols have to be surrounded by spaces, but continuator does not have to:
```hy
 \x <$\y | (x y)     ; recognized as expected

 x <$ y  | ((x) (y)) ; recognized as expected
 x<$y    | x<$y      ; parser sees it as a single word 'x<$y'

 1,000   | 1000      ; parser sees it as a valid hy number '1,000'

 1 , 000 | 1 000     ; parser sees it as number '1', joiner ',' and number '000'
```

Space before/after `\` and one-liner symbols is allowed,
although it has no direct effect on indenting:
```hy
; those 3 lines will have the same indenting behaviour:
    : \   f <$ \   x
    :   \ f    <$ \x
    : \   f  <$\x
  ; ↑     ↑
  ; only positions of these 2 symbols matter in this case
```

<!-- __________________________________________________________________________/ }}}1 -->

# Interactions of one-liners
<!-- Simple interactions ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

Remember precedence order of one-liners:

Precedence order:
* condensed `:` — highest priority
* `<$`
* `$`
* `,`
* non-condensed `:` — lowest priority

## Simple examples

Joiner:
```hy
: fn [x] : + x 3 , \y   | ((fn [x] (+ x 3)) y)

; code above is internally temporarily expanded to:
:                 ; condensed ':' has higher priority than ','
  fn [x] : + x 3  ; non-condensed ':' has lower priority than ','
 \y
```

Applicator:
```hy
  map $ fn [x y] : + x y 3 , \xs , get yss 3

  ; code above is internally temporarily expanded to:
  lmap                    ; '$' has higher priority than ','
      fn [x y] : + x y 3  ; ',' has higher priority than non-condensed ':'
     \xs
      get yss 3
```

Reverse applicator:
```hy
  object <$ 3 , 4  | ( (object) 3 4)
  object <$ f $ 4  | ( (object) (f 4))

; code above is internally temporarily expanded to:

  : object
    3 , 4
  : object
    f $ 4

  ; and then to:

  : object
    3
    4
  : object
    f
       4
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- SMarkers inside one-liners ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Condensed openers inside one-liners

Since symbols `,`, `$` and `<$` emulate new lines,
they can introduce condensed openers in the middle of the line:
```hy
  ; those are seen as condensed openers (they will be expanded at some level)
  ; ↓         ↓         ↓          ↓
    : f : x $ : g : y , : k : z <$ : m : t
  ;     ↑         ↑         ↑          ↑
  ;     those are seen as normal openers (they will NOT be expanded on new lines)
```

This is important because during temporary expansion phase,
condensed openers are of highest priority, and non-condensed are of lowest priority.
See it in action in next example.

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Monstrosity interaction ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## One monstrosity of example

This is how precedence is applied step by step:
```hy

    condensed openers
    ↓         ↓         ↓          ↓
    : a : b $ : c : d , : e : f <$ : h : i
        ↑         ↑         ↑          ↑
        non-condensed openers

    ; this is final result
    ( ( (a (b) ( (c (d)) ( (e (f))))) ( (h (i)))))

  ; 1) first, expansion of leftmost condensed opener is done:

    :
      a : b $ : c : d , : e : f <$ : h : i

  ; 2) then expansion of <$

    :
      : a : b $ : c : d , : e : f
        : h : i

    :
      :
        a : b $ : c : d , : e : f
        :
          h : i

  ; 3) then expansion of $

    :
      :
        a : b
          : c : d , : e : f
        :
          h : i

    :
      :
        a : b
          :
            c : d , : e : f
        :
          h : i

  ; 4) then expansion of ,

    :
      :
        a : b
          :
            c : d
            : e : f
        :
          h : i

    :
      :
        a : b
          :
            c : d
            :
              e : f
        :
          h : i

  ; And then there is nothing more left to expand
```

<!-- __________________________________________________________________________/ }}}1 -->

> \>\> Next chapter: [List of all special symbols](https://github.com/rmnavr/wy/blob/main/docs/05_Symbols.md)

