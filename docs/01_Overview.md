
---
Documentation:
1. You are here -> [Syntax overview](https://github.com/rmnavr/wy/blob/main/docs/01_Overview.md)
2. [Basic syntax](https://github.com/rmnavr/wy/blob/main/docs/02_Basic.md) 
3. [Condensed syntax](https://github.com/rmnavr/wy/blob/main/docs/03_Condensed.md)
4. [One-liners](https://github.com/rmnavr/wy/blob/main/docs/04_One_liners.md) 
5. [List of all special symbols](https://github.com/rmnavr/wy/blob/main/docs/05_Symbols.md)
---

# Wy syntax overview

Wy has 2 distinct "levels" of syntax:

1. Basic syntax *— quick to grasp and enough to write anything in wy*:
   > ```hy
   > :                      | (
   >   fn [x] : + x 3       |   (fn [x] (+ x 3))
   >   7                    |   7)
   > ```

   Here 2 special symbols were used:
   - `:` — opener that represent new wrapping level starting with `(`
   - `\` — continuator that supresses automatic wrapping

2. Condensed syntax and one-liners *— syntactic sugar for indenting and wrapping*:
   > ```hy
   > : fn [x] : + x 3       | ( (fn [x] (+ x 3))    
   >   7                    |   7)
   > 
   > fn [x] : + x 3 <$ 7    | ((fn [x] (+ x 3)) 7)
   > ```

   Symbols `$`, `<$` and `,` are used to control indenting and wrapping.

Aside from aforementioned symbols, overall wy has about 35 special symbols.
Wy sacrifices `L` and `C` to be recognized as `[` and `{` wrappers respectively.
This is described in: [List of all special symbols](https://github.com/rmnavr/wy/blob/main/docs/05_Symbols.md)

> There are so many of wy symbols, because hy itself has 25 various kinds of brackets.
> Wy has 25 wy openers derived from them, and the all obey the same rules.

---

> \>\> Next chapter: [Basic syntax](https://github.com/rmnavr/wy/blob/main/docs/02_Basic.md) 
