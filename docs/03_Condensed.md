
---
Documentation:
1. [Syntax overview](https://github.com/rmnavr/wy/blob/main/docs/01_Overview.md)
2. [Basic syntax](https://github.com/rmnavr/wy/blob/main/docs/02_Basic.md) 
3. You are here -> [Condensed syntax](https://github.com/rmnavr/wy/blob/main/docs/03_Condensed.md)
4. [One-liners](https://github.com/rmnavr/wy/blob/main/docs/04_One_liners.md) 
5. [List of all special symbols](https://github.com/rmnavr/wy/blob/main/docs/05_Symbols.md)
---

<!-- Intro ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Condensed syntax

> We will discuss condensed syntax by inspecting `:` opener behaviour.
> However all the same rules apply for any of 25 kinds of openers.

Condensing openers (like `:`) is considered to be a syntactic sugar,
meaning that condensed syntax is internally processed in expanded form:

```hy
: fn [x] : + pow 2      | ( (fn [x] (pow x 2))
  3                     |   3)

; internally, lines above will be processed as if they were expanded to:
:                       | (
  fn [x] : + pow 2      |   (fn [x] (pow x 2))
  3                     |   3)
```
*(by the way, this internal expansion does not mess with final numbering of generated code lines)*

<!-- __________________________________________________________________________/ }}}1 -->

<!-- smarker vs mmarker ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Openers behaviour depending on position

Notice that `:` behaviour is slightly different depending on it's placement:
```hy
                ; ↓↓ 2 wraps around x due to ":" at the start of the line
: x : y         | ((x (y)))
                ;     ↑ 1 wrap around y due to ":" in the middle of the line
```

Logic of such behaviour is more clear in expanded form:
```hy
                ; /--- 1st wrap is due to ":" at the start of the line
                ; | /- 2nd wrap is due to "x" being autowrapped, since it startsnhe line
                ; ↓ ↓
:               | (
  x : y         |   (x (y)))
                ;      ↑ 1 wrap around "y" due to ":" in the middle of the line
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- indenting ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Indenting in condensed syntax

You can have as many `:` at the start of the line as you like.
Just be aware that such `:` introduces new indents, which must be respected by lines that follow it:

```hy
  ; wy will see indents at these positions due to ":"
  ; at the start of the line
  ; ↓  ↓ ↓
    :  : f x : y         | (  ( (f x (y))
         3               |      3)
       4                 |    4)
```

Everything after `\` switches off condensing (and thus new indent levels):
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

Following described logic, see how continuator `\` works with `:` (and any other) openers:
```hy
 : x : y         | ((x (y)))
 :\x : y         | ( x (y))
 : x :\y         | ( x (y))  ; \ is allowed, but surves no purpose
\: x : y         | ( x (y))  ; this is seen as single line, not as condensed line
 : x\: y         | ((x (y))  ; allowed, but surves no purpose
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- examples ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Examples of condensed syntax

Let's get back to examples from [Other kidns of openers](#Other-kinds-of-openers) chapter
and see how they can be condensed:

```hy
; Example 1:

    L                   | [
      \x y : f 3        |   x y (f 3)
       g 4 L 2 5        |   (g 4 [2 5])]

    ; condensed:
    L \x y : f 3        | [ x y (f 3)
       g 4 L 2 5        |   (g 4 [2 5])]

; Example 2:

    `:                  | `(
       \get ~x ~indx    |    get ~x ~indx)

    ; condensed:
    `: \get ~x ~indx    | `( get ~x ~indx)
```

<!-- __________________________________________________________________________/ }}}1 -->

    case: multiline (hy) indenting



