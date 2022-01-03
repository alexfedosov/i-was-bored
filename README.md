# IWasBored

"I was bored" is a toy programming language which looks like Swift and written in Swift.
I started it because I was bored, but also to learn more about lexers, parsers, ASTs and all the stuff needed to write an interpreter.

Currently, it has a parser for simple math expressions and REPL to try it out:

```

Welcome to IWasBored REPL!
Type an expression to evaluate or an empty line to exit

> 1 + 2 >= -3 + 24 / 6
(>=  (+  Optional(1.0) Optional(2.0)) (+  (-  Optional(3.0)) (/  Optional(24.0) Optional(6.0))))

```
