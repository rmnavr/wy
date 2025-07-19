
---
Documentation:
1. [Syntax overview](https://github.com/rmnavr/wy/blob/main/docs/01_Overview.md)
2. [Basic syntax](https://github.com/rmnavr/wy/blob/main/docs/02_Basic.md) 
3. [Condensed syntax](https://github.com/rmnavr/wy/blob/main/docs/03_Condensed.md)
4. [One-liners](https://github.com/rmnavr/wy/blob/main/docs/04_One_liners.md) 
5. You are here -> [List of all special symbols](https://github.com/rmnavr/wy/blob/main/docs/05_Symbols.md)
---

<!-- hy ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Original hy openers

Hy itself has:
- 3 kinds of closing bracket: `)`, `]` and `}`
- 5 basic kinds of opening bracket: `(`, `#(`, `[`, `{`, `#{`
- 4 macros symbols: `` ` ``, `'`, `~`, `~@`

Macros symbols can prepend (without spaces) opening brackets, so for example `~@#(` is a valid hy bracket.
And in total it sums up to 5*(1+4) = 25 different kinds of opening brackets.

<!-- __________________________________________________________________________/ }}}1 -->
<!-- wy ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# All of wy special symbols

Basic syntax and also condensed syntax rely on:
- Indent rules
- 25 various bracket openers:
  - 5 basic openers
    - `:` to represent `(`
    - `L` to represent `[`
    - `C` to represent `{`
    - `#:` to represent `#(`
    - `#C` to represent `#{`
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

> Yes, literal "L", "C" and others are used as special symbols.
> This is deliberate design decision, explained in [Basic syntax](https://github.com/rmnavr/wy/blob/main/docs/02_Basic.md)

<!-- __________________________________________________________________________/ }}}1 -->

