
---
wy syntax:
1. [Syntax overview](https://github.com/rmnavr/wy/blob/main/docs/01_Overview.md)
2. [Basic syntax](https://github.com/rmnavr/wy/blob/main/docs/02_Basic.md) 
3. [Condensed syntax](https://github.com/rmnavr/wy/blob/main/docs/03_Condensed.md)
4. [One-liners](https://github.com/rmnavr/wy/blob/main/docs/04_One_liners.md) 
5. [List of all special symbols](https://github.com/rmnavr/wy/blob/main/docs/05_Symbols.md)

running wy code:
1. [wy2hy transpiler](https://github.com/rmnavr/wy/blob/main/docs/wy2hy.md) 
2. [wy in ipython](https://github.com/rmnavr/wy/blob/main/docs/ipywy.md) 
---

<!-- syntax ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Wy syntax overview

Wy can be written in 3 increasingly more terse styles:

1. [Basic syntax](https://github.com/rmnavr/wy/blob/main/docs/02_Basic.md):
   > ```hy
   > :                      | (
   >   fn [x] : + x 3       |   (fn [x] (+ x 3))
   >  \y                    |   y)
   > ```

   Uses special symbols:
   * Openers like `:` that represent new wrapping level starting with `(`
   * Continuator `\` that prevents automatic wrapping

2. [Condensed syntax](https://github.com/rmnavr/wy/blob/main/docs/03_Condensed.md):
   > ```hy
   > : fn [x] : + x 3       | ( (fn [x] (+ x 3))    
   >  \y                    |   y)
   > ```

   Has different rules for:
   * condensing `:` (those ones that are placed at the start of the line)
   * non-condensing `:` (those ones that are placed in the mid of the line)

3. [One-liners](https://github.com/rmnavr/wy/blob/main/docs/04_One_liners.md) syntax: 
   > ```hy
   > fn [x] : + x 3 <$ \y   | ((fn [x] (+ x 3)) y)
   > ```

   Uses symbols `$`, `<$` and `,` to represent wrapping and indenting.

   Also there is `::` and similar symbols to represent things like `)(`:
   > ```hy
   > print : + 1 2 :: + 1 3 | (print (+ 1 2) (+ 1 3))
   > ```

<!-- __________________________________________________________________________/ }}}1 -->
<!-- symbols ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾\ {{{1 -->

# Wy symbols overview

In total Wy uses:
* 25 bracket openers:
  * `:` for `(`
  * `L` for `[`
  * `C` for `{`
  * and 22 more like: `#:` for `#(`, or `~@:` for `~@(`
* 1 continuator `\`
* 3 one-liner symbols: `$`, `<$` and `,`
* 5 double markers like `::` to represent `)(`

Yes, symbols `L` and `C` (and some others) are sacrificed to be seen as openers.
> To use them as name variables, put them in a valid hy-expression like (setv L 3),
> since wy parses valid hy-expressions as-is.

This is described in details in:
[List of all special symbols](https://github.com/rmnavr/wy/blob/main/docs/05_Symbols.md)

<!-- __________________________________________________________________________/ }}}1 -->

---

> \>\> Next chapter: [Basic syntax](https://github.com/rmnavr/wy/blob/main/docs/02_Basic.md) 

