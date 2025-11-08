1. Syntax
2. Running wy code

# Special symbols overview
<!-- Openers ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Openers

Wy uses openers to start new wrapping level:
* `:` for `(` 
* `L` for `[` 
* `C` for `{` 
* and many others for things like `~@(`, `#{` and similar

> Yes, symbols `L` and `C` are sacrificed to be seen openers.
> There is still way to use them as name variables.

When used in the mid of the line, they are always wrapped at the end of the line:

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

;↓ ↓ new indent levels are introduced here
 : f L a b | ( (f [a b])
   g : h x |   (g (h x))
 
 ; multiple opener levels are allowed to:
 setv x    | (setv x
   L L 1 2 |   [ [ 1 2
       3 4 |       3 4]
     L 5 6 |     [ 5 6
       7 8 |       7 8]])
```


<!-- __________________________________________________________________________/ }}}1 -->
<!-- Continuators ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

## Continuators

Use `\` to prevent automatic wrapping on a new indent level.
Continuator is allowed do be used without surrounding spaces.

```hy
 f   | (f
   x |    (x))
     |
 f   | (f 
  \x |    x)

 L x y  | [ (x y)]
        |
 L\x y  | [ x y]
```

Using `\` before opener at the start of the line
prevents it from starting new indent level:
```hy
  ;↓ ↓ ↓ new indent levels are introduced here
   : : f x   |

  ;↓ ↓ new indent levels are introduced here
   :\: f x
```

<!-- __________________________________________________________________________/ }}}1 -->

