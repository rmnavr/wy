1. Syntax
2. Running wy code

# Syntax overview
<!-- Openers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Openers

Wy uses openers to start new wrapping level:
* `:` for `(`
* `L` for `[`
* `C` for `{`
* and many other openers with intuitive syntax like: `#:` for `#(`, or `~@:` for `~@(`

Yes, symbols `L` and `C` (and some others) are sacrificed to be seen openers.
> To use them as name variables, put them in a hy-expr like (setv L 3).
> More on that — later.

When used in the mid of the line, openers wrap at the end of the line:

```hy
 f : g x       | (f (g x))
 f L a b       | (f [a b])
 f C "k1" v1   | (f {"k1" v1})
```

When used at the start of the line, they introduce new indent level:

```hy
 :         | (
   f L a b |   (f [a b])
   g : h x |   (g (h x))

 ; which can be condensed into:

;↓  ↓ new indent levels are introduced here
 #: f L a b | #( (f [a b])
    g : h x |    (g (h x))

 ; multiple opener levels are allowed to:
 setv x    | (setv x
   L L 1 2 |   [ [ 1 2
       3 4 |       3 4]
     L 5 6 |     [ 5 6
       7 8 |       7 8]])
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Empty Lines ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Empty lines policy

**You can't have empty lines inside one expression**.
> With exception to multiline strings and hy-expressions, see below.

```hy
; Code below will be seen as 3 distinct s-expressions:

print x     |   (print x)
            |
    + z y   |       (+ z y)
            |
    + k n   |       (+ k n)

; Use comment line (at any indent level) to unite them in single expression:

print x     | (print x
    ;       |     ;
    + z y   |     (+ z y)
;           | ;
    + k n   |     (+ k n))
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Continuator ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Continuator

Use continuator `\` to prevent automatic wrapping on a new indent level.
Continuator is allowed to be used without surrounding spaces.

```hy
 f   | (f
   x |    (x))
     |
 f   | (f
  \x |    x)
```

Another example:
```hy
 ; since this expression ...
 L x y  | [ (x y)]

 ; ... has wrapping logic equivalent to this ...
 L      | [
   x y  |   (x y)]

 ; ... you may be actually
 ; required to use continuator:
 L\x y  | [ x y]
```

Using `\` before some opener at the start of the line
prevents it from starting new indent level (forcing it to wrap at line end):
```hy
 : : f x | ( ( (f x)))
 :\: f x | ( (f x))
```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- Indents ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Indents

New expression does NOT have to start at column-0:
```hy
print 1   | (print 1)
          |
  print 2 |   (print 2)
```

Empty line (or EOF) closes whole indent block.
Add comment-line to prevent it from closing (indent level of comment doesn't matter).
```hy
print 1   | ( (print 1)
  ; cmnt  |   ; cmnt
      ;           ;
  print 2 |   (print 2))
          |
  print 3 |   (print 3)
```


When using multi-symbol openers (like `':`), indent is seen at it's first symbol:
```hy
; ↓    ↓  ↓ new indent levels are introduced here
  ~@#: ': x ~y | ~@#( '( (x ~y)
          k    |         (k))
       2       |      2)
  z            | (z)
```

When using continuator \, it's position doesn't exactly matter,
because new level is introduced at a next element after it.
```hy
print                   | (print
   \x                   |      x
\   y                   |      y
  \ z                   |      z)
;   ↑ new indent level is introduced here
;     regardless of \ exact position
```

Notice how described indent rule for continuator \ works in the following example:
```hy
y                       | (y
\x                      |    x)
                        |
  y                     | (y)
\ x                     |  x
```

<!-- __________________________________________________________________________/ }}}1 -->
