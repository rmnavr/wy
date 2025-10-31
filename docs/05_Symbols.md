
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

<!-- hy ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Original hy openers

Hy itself has:
- 3 kinds of closing bracket: `)`, `]` and `}`
- 5 basic kinds of opening bracket:
  * `(` — expression
  * `#(` — tuple
  * `[` — list
  * `{` — dict
  * `#{` — set
- 4 macros symbols: `` ` ``, `'`, `~`, `~@`
- Also, `#[` is used as bracketed strings (like `#[=[ ... ]=]`)

Macros symbols can prepend (without spaces) to opening brackets, so for example `~@#(` is a valid hy bracket.
In total it sums up to 5*(1+4) = 25 different kinds of opening brackets.

<!-- __________________________________________________________________________/ }}}1 -->
<!-- wy ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# All of wy special symbols

Basic syntax and also condensed syntax rely on:
- Indent rules
- 25 various bracket openers (they all obey the same rules):
  - 5 basic openers
    - `:` to represent `(`
    - `L` to represent `[`
    - `C` to represent `{`
    - `#:` to represent `#(`
    - `#C` to represent `#{`
	- notice that wy does not use `#L` for `#[`, you'll have to use `#[` directly (and wy2hy will not care what's inside it)
  - 4 hy macro symbols can be prepended to any of 5 basic openers without spaces (example: `~@#C` will represent `~@#{`),
    thus generating 25 various openers
- Continuator `\`

One-liners use:
- 3 symbols that control wrapping level:
  - reverse applicator `<$`
  - applicator `$`
  - joiner `,`
- 5 double markers:
  - `::` to represent `)(`
  - `LL` to represent `][`
  - `CC` to represent `}{`
  - `:#:` to represent `) #(`
  - `C#C` to represent `} #{`

Reader macros like `#rmacro` will be recognized just like normal words (i.e. literally as `#rmacro`).
Space-less syntax like `#rmacro:` is not specially recognized by wy. Use `#rmacro :` or `#rmacro(` instead.

<!-- __________________________________________________________________________/ }}}1 -->
<!-- L/C sacrifice ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Sacrificing L and C

Symbols `L`, `C` (and also `LL` and `CC` and similar) cannot be normally used as variable names in wy syntax.

> I know this is kind of dumb design, but hey, hy has lot's of various brackets.

However, since wy does not look inside expressions with original hy syntax, you can have `L` and friends there:
```hy
; Seeing this code, wy2hy will strictly follow wy rules
; and produce corresponding non-working hy code:
setv L : + L 1          | (setv [(+ [1])])

; In order for L to be recognized as variable (as opposed to "[" bracket opener),
; L needs to be inside parentheses, since wy2hy does not modify anything inside parentheses:
(setv L (+ L 1))        | (setv L (+ L 1))
```

Another common usage of original hy syntax might be using of `ncut` macro (it uses `:` for slicing):
```hy
; Seeing this code, wy2hy will strictly follow wy rules
; and produce corresponding non-working hy code:
ncut x 1:2:3            | (ncut x 1(2(3)))

; Wrap ncut with parentheses to produce correct code:
(ncut x 1:2:3)          | (ncut x 1:2:3)
```

<!-- __________________________________________________________________________/ }}}1 -->

