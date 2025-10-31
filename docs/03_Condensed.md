
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

<!-- Intro ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Condensed syntax

Openers (like `:`) when they begin the line are considered to be **condensed**.
Condensing is syntactic sugar, meaning that condensed openers are internally processed in expanded form:

```hy
: fn [x] : + pow 2      | ( (fn [x] (pow x 2))
  3                     |   3)

; internally, lines above will be processed as if they were expanded to:
:                       | (
  fn [x] : + pow 2      |   (fn [x] (pow x 2))
  3                     |   3)
```

All the same rules apply to other openers:
```hy
~@: f y                 | ~@((f y))

; internally, lines above will be processed as if they were expanded to:
~@:                     | ~@(
    f y                 |     (f y))
```

This internal expansion does not mess with final numbering of generated code lines.

<!-- __________________________________________________________________________/ }}}1 -->
<!-- smarker vs mmarker ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Openers behaviour depending on position

Notice that `:` behaviour is different depending on it's placement:
```hy
                ; ↓↓ 2 wraps around x due to ":" at the start of the line
: x : y         | ((x (y)))
                ;     ↑ 1 wrap around y due to ":" in the middle of the line
```

Logic of such behaviour is more clear in expanded form:
```hy
                ; /--- 1st wrap is due to ":" at the start of the line
                ; | /- 2nd wrap is due to "x" being autowrapped, since it starts the line
                ; ↓ ↓
:               | (
  x : y         |   (x (y)))
                ;      ↑ 1 wrap around "y" due to ":" in the middle of the line
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- indenting ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Indenting in condensed syntax

You can have as many `:` at the start of the line as you like.
Just be aware that such `:` introduce new indents, which must be respected by lines that follow it:

```hy
  ; wy will see indents at these positions due to ":"
  ; at the start of the line
  ; ↓  ↓ ↓
    :  : f x : y         | (  ( (f x (y))
         3               |      3)
       4                 |    4)
```

Continuator `\` switches off condensing (and thus new indent levels) for symbols to the right:
```hy
  ; indents are created only at 2 positions:
  ; ↓  ↓
    : \: f x : y         | (  (f x (y))
       4                 |    4)
  ;    ↑
  ;    ":" at this position will not be seen as condensed

  ; expanded form:

    :                    | (
      \: f x : y         |    (f x (y))
       4                 |    4)
```

One more example of how `\` interacts with `:`:
```hy
 : x :\y         | ((x (y))) ; this line has one ":" condensed
\: x : y         | ( x (y))  ; this is seen as a single line, no condensing is happening
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- examples ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Examples with other openers

Let's get back to examples from [Basic syntax](https://github.com/rmnavr/wy/blob/main/docs/02_Basic.md) chapter
and see how they can be condensed:

```hy
; Example 1:

    L                   | [
      \x y : f 3        |   x y (f 3)
       g 4 L 2 5        |   (g 4 [2 5])]

    ; condensed:
    L \x y : f 3        | [ x y (f 3)
       g 4 L 2 5        |   (g 4 [2 5])]

    ; notice that without continuator "\"
    ; we would get unwanted extra wrapping:
    L  x y : f 3        | [ (x y (f 3))
       g 4 L 2 5        |   (g 4 [2 5])]

; Example 2:

    `:                  | `(
       \get ~x ~indx    |    get ~x ~indx)

    ; condensed:
    `: \get ~x ~indx    | `( get ~x ~indx)

    ; notice that without continuator "\"
    ; we would get unwanted extra wrapping:
    `: get ~x ~indx    | `( (get ~x ~indx))
```

<!-- __________________________________________________________________________/ }}}1 -->

> \>\> Next chapter: [One-liners](https://github.com/rmnavr/wy/blob/main/docs/04_One_liners.md) 




