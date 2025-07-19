
---
Documentation:
1. [Syntax overview](https://github.com/rmnavr/wy/blob/main/docs/01_Overview.md)
2. [Basic syntax](https://github.com/rmnavr/wy/blob/main/docs/02_Basic.md) 
3. [Condensed syntax](https://github.com/rmnavr/wy/blob/main/docs/03_Condensed.md)
4. [One-liners](https://github.com/rmnavr/wy/blob/main/docs/04_One_liners.md) 
5. You are here -> [List of all special symbols](https://github.com/rmnavr/wy/blob/main/docs/05_Symbols.md)
---

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
  - 4 hy macro symbols (`` ` ``, `'`, `~` and `~@`) can be prepended to any of
    5 basic openers without spaces (example: `~@#C` will represent `~@#{`),
    thus generating mentioned number 25
- Continuator `\`

One-liners:
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
> This is deliberate design decision, explained in [Basic syntax](https://github.com/rmnavr/wy/blob/main/docs/02_Basic.md) doc

