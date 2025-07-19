
---
Documentation:
1. You are here -> [Syntax overview](https://github.com/rmnavr/wy/blob/main/docs/01_Overview.md)
2. [Basic syntax](https://github.com/rmnavr/wy/blob/main/docs/02_Basic.md) 
3. [Condensed syntax](https://github.com/rmnavr/wy/blob/main/docs/03_Condensed.md)
4. [One-liners](https://github.com/rmnavr/wy/blob/main/docs/04_One_liners.md) 
5. [List of all special symbols](https://github.com/rmnavr/wy/blob/main/docs/05_Symbols.md)
---

# Wy syntax overview

Wy has 3 distinct "levels" of syntax:

1. Basic syntax *— quick to grasp and enough to write anything in wy*:
   > ```hy
   > : 
   >   fn [x] : + x 3
   >   7
   > ```

2. Condensed syntax *— syntactic sugar for adding wrapping level at head of the expression*:
   > ```hy
   > : fn [x] : + x 3
   >   7
   > ```

3. One-liners *— sofisticated syntactic sugar for indenting and wrapping*:
   > ```hy
   > fn [x] $ + x 3 , 7
   > ```

One-liners are considered to be advanced wy topics due to high amount of interactions
between different syntactic rules. Still, all the rules are consistent without exceptions,
and one-liners make wy syntax shine with it's own (resembling pointfree) syntax style.

It is recommended to first get acquainted with 
[list of all special symbols](https://github.com/rmnavr/wy/blob/main/docs/05_Symbols.md) 
of wy (not necessarily understanding everything) and then procede to: 

> Next chapter: [Basic syntax](https://github.com/rmnavr/wy/blob/main/docs/02_Basic.md) 
