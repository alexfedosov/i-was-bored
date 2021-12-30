# IWasBored

"I was bored" is a toy programming language which looks like Swift and written in Swift.
I started it because I was bored, but also to learn more about lexers, parsers, ASTs and all the stuff needed to write an interpreter.

Currently, it has a simple lexer and RELP to try it out:

```
> swift run iwasbored

> let x = 12
> (x + 1) == 26 / 3

Token(lexeme: "let", type: iwasbored.TokenType.Identifier, line: 0)
Token(lexeme: "x", type: iwasbored.TokenType.Identifier, line: 0)
Token(lexeme: "=", type: iwasbored.TokenType.Equal, line: 0)
Token(lexeme: "12", type: iwasbored.TokenType.Number, line: 0)
Token(lexeme: "", type: iwasbored.TokenType.Eof, line: 0)
Token(lexeme: "(", type: iwasbored.TokenType.LeftParen, line: 1)
Token(lexeme: "x", type: iwasbored.TokenType.Identifier, line: 1)
Token(lexeme: "+", type: iwasbored.TokenType.Plus, line: 1)
Token(lexeme: "1", type: iwasbored.TokenType.Number, line: 1)
Token(lexeme: ")", type: iwasbored.TokenType.RightParen, line: 1)
Token(lexeme: "==", type: iwasbored.TokenType.EqualEqual, line: 1)
Token(lexeme: "26", type: iwasbored.TokenType.Number, line: 1)
Token(lexeme: "/", type: iwasbored.TokenType.Slash, line: 1)
Token(lexeme: "3", type: iwasbored.TokenType.Number, line: 1)
Token(lexeme: "", type: iwasbored.TokenType.Eof, line: 1)
```
