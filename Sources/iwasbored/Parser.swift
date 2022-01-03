import Foundation

final class Parser {
    let tokens: [Token]
    var currentToken = 0
    var isAtEnd: Bool { currentToken >= tokens.count }

    init(tokens: [Token]) {
        self.tokens = tokens
    }

    func parse() -> Expression {
        expression()
    }

    private func expression() -> Expression {
        equality()
    }

    private func equality() -> Expression {
        var expression = comparison()

        while match(tokenType: [.BangEqual, .EqualEqual]) {
            let op = previous()
            let right = comparison()
            expression = Binary(left: expression, op: op, right: right)
        }

        return expression
    }

    private func comparison() -> Expression {
        var expression = term()

        while match(tokenType: [.More, .MoreEqual, .Less, .LessEqual]) {
            let op = previous()
            let right = term()
            expression = Binary(left: expression, op: op, right: right)
        }

        return expression
    }

    private func term() -> Expression {
        var expression = factor()

        while match(tokenType: [.Minus, .Plus]) {
            let op = previous()
            let right = factor()
            expression = Binary(left: expression, op: op, right: right)
        }

        return expression
    }

    private func factor() -> Expression {
        var expression = unary()

        while match(tokenType: [.Slash, .Star]) {
            let op = previous()
            let right = unary()
            expression = Binary(left: expression, op: op, right: right)
        }

        return expression
    }

    private func unary() -> Expression {
        if match(tokenType: [.Bang, .Minus]) {
            let op = previous()
            let right = unary()
            return Unary(op: op, right: right)
        }

        return primary()
    }

    private func primary() -> Expression {
        if match(.True) { return Literal(value: true) }
        if match(.False) { return Literal(value: false) }
        if match(.Nil) { return Literal(value: nil) }

        if match(.Number) { return Literal(value: Double(previous().lexeme)) }
        if match(.String) { return Literal(value: previous().lexeme) }

        return Expression()
    }
}

extension Parser {
    private func peek() -> Token {
        tokens[currentToken]
    }

    private func check(tokenType: Set<TokenType>) -> Bool {
        !isAtEnd && tokenType.contains(tokens[currentToken].type)
    }

    private func match(tokenType: Set<TokenType>) -> Bool {
        if check(tokenType: tokenType) {
            advance()
            return true
        } else {
            return false
        }
    }

    private func match(_ tokenType: TokenType ...) -> Bool {
        match(tokenType: Set(tokenType))
    }

    private func previous() -> Token {
        tokens[currentToken - 1]
    }

    @discardableResult
    private func advance() -> Token {
        guard !isAtEnd else { return tokens[tokens.count - 1] }
        currentToken += 1
        return previous()
    }
}
