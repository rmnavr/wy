
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
- 5+1 basic kinds of opening bracket ...
  * `(` — expression
  * `#(` — tuple
  * `[` — list
  * `{` — dict
  * `#{` — set
  * `#[` — this one is special, since it is used only as a part of bracketed string like `#[FOO[ ... ]FOO]`
- ... that can be prepended (without spaces) by any of 4 macros symbols:
  * `` ` ``
  * `'`
  * `~`
  * `~@`

So for example `~@#( ... [#(...) ... ])` will be recognized by Wy as a valid hy-expression.

In total it sums up to (1+4)*(5+1) = 30 different kinds of opening brackets.

<!-- __________________________________________________________________________/ }}}1 -->
<!-- wy ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# All of wy special symbols

Basic syntax and also condensed syntax rely on:
- Indent rules
- 25 various bracket openers (they all obey the same rules):
  - 5 basic openers...
    - `:` to represent `(`
    - `L` to represent `[`
    - `C` to represent `{`
    - `#:` to represent `#(`
    - `#C` to represent `#{`
  - ... that can be prepended (without spaces) by any of 4 hy macros symbols:
    * `` ` ``
    * `'`
    * `~`
    * `~@`
- Continuator `\`

So for example `~@#C` will represent `~@#{`.

Notice that wy does not use `#L` for `#[`, you'll have to use `#[ ... ]` form in hy-syntax (and wy2hy will not care what's inside it)

In total it sums up to (1+4)*5 = 25 different kinds of wy openers.

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

Space-less syntax like `#rmacro:` is not specially recognized by wy.
Use `#rmacro :` or `#rmacro(` instead.

Note on hy's recognition of sets:
> In hy 1.0.0 `#{1}` is for some reason seen as reader macro `#1` (instead of set `#{1}`),
> however `#{1 1}` is seen as a set `#{1}` as it should be. I'm not sure, but it looks like hy's bug.
>
> Anyway, when wy2hy sees `#{1}` or `#C 1`, it transpiles as usual, producing `#{1}`.
> What hy makes of it — is on hy's consciousness.

<!-- __________________________________________________________________________/ }}}1 -->
<!-- L/C sacrifice ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Sacrificing L, C and other symbols

Symbols `L`, `C`, `LL` and `CC` cannot be normally used as variable names in wy syntax,
since they are transpiled into brackets.

> I know this is meh, but hey.

Intended universal workaround is wrapping them inside hy expressions, since wy parses them as is:
```hy
setv L : + L 1   | (setv [(+ [1])])  ; not as desired
(setv L (+ L 1)) | (setv L (+ L 1))  ; as desired
```

Another case.
Inside `ncut`-macro `:` is used to produce slices, but in wy it will be transpiled into `(` opener.
Solution is the same — wrap it in hy expression

```hy
ncut x :       | (ncut x ())   ; not as desired
(ncut x :)     | (ncut x :)    ; as desired
```

Although since `1:2` are recognized as is (see [Basic syntax](https://github.com/rmnavr/wy/blob/main/docs/02_Basic.md)),
you can avoid using hy wrapping in such cases:
ncut x 1:2     | (ncut x 1:2)  ; as desired
ncut x :2      | (ncut x :2)   ; as desired

<!-- __________________________________________________________________________/ }}}1 -->

