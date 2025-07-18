
<!-- Intro ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Syntax for one-liners

Wy has following main symbols for writing one-liners (from highest precedence to lowest):
* `:` at the start of the line (smarker) — highest level wrapper
* `<$` — reverse applicator
* `$` — applicator
* `,` — joiner
* `:` at mid of the line (mmarker) — one line wrapper

Other important symbols that have their special rules are:
* `::` — literal `)(`
* `\` — continuator

Realistically, there are just several readable one-liners patterns (that will be summarized in chapter's end).
Still, one-liners have strict rules of interaction, which are good to know as a whole system.

Code examples in this chapter in most cases are not very meaningfull, still their main goal is to demonstrate how wy2hy will treat one-liners.
Also, please pay high attention to precedence order of symbols in the examples.

<!-- __________________________________________________________________________/ }}}1 -->

<!-- General rules ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# General rules

Symbols `,`, `$` and `<$` emulate new lines, this is why they can introduce smarkers in middle of the line:
```hy
  ; those are seen as smarkers
  ; ↓         ↓         ↓          ↓
    : f : x $ : g : y , : k : z <$ : m : t
  ;     ↑         ↑         ↑          ↑
  ;     those are seen as mmarkers
```

Continuator `\` is allowed only in the following positions:
```hy
   : : : \f     ; after last smarker
  \f            ; before line without smarkers
   f $ \x       ; directly after $
   f <$ \x      ; directly after <$
   f , \x       ; directly after ,

   f  $ : : \x  ; directly after last smarker after $
   f <$ : : \x  ; directly after last smarker after <$
   f ,  : : \x  ; directly after last smarker after ,

   ; space after \ is allowed:
   : \   f <$ \   x
```

You'll see those rules in action in examples below.

<!-- __________________________________________________________________________/ }}}1 -->
<!-- :: ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Double mid brackets `::`
Simliest symbol is `::`, it is literally `)(`, and that's it.
There are at least 3 cases where it may be usefull:

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
<!-- smarker : interaction ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Interaction of one-liners

Remember precedence order of one-liners:
1. Smarker (which is `:` that starts the line, and there may be more than 1 of them at line start) has highest priority.
2. Then `<$`, `$`, `,` and mmarker `:` 
3. `\` and `::` have their own rules, that are "orthogonal" to precedence order logic

There are 2 rules that help understanding how symbols internally emulating new lines (`,`, `$`, `<$`) interact with smarker:
1. Symbols `,`, `$` and `<$` do NOT expand into additional wrapping levels represented by smarkers
2. Code after `,`, `$` and `<$` symbols can introduce new smarker in the middle of the line (see [General rules (for one-liners)](#General-rules))

All of that can be understood in one (although very contrived and mostly unreadable) example:
```hy
  ;       all these ":" are seen as s-markers
  ; ↓ ↓                ↓               ↓
    : : f x : y :: z $ : k : m , \t <$ : x $ 7 <$ 5

  ; first, leftmost smarkers are expanded:
    :
      :
        f x : y :: z $ : k : m , \t <$ : x $ 7 <$ 5

  ; then both <$ are expanded:
    :
      :
        : : f x : y :: z $ : k : m , \t
            : x $ 7
          5

  ; then $ are expanded:
    :
      :
        : : f x : y :: z
            : k : m , \t
            : x
              7
          5

  ; , is the last one:
    :
      :
        : : f x : y :: z
            : k : m
             \t
            : x
              7
          5
```



<!-- __________________________________________________________________________/ }}}1 -->
