final class Parser {
    let tokens: [Token]
    let errorReporter: ErrorReporter
    var currentToken = 0
    var isAtEnd: Bool { currentToken >= tokens.count }

    init(tokens: [Token], errorReporter: ErrorReporter) {
        self.tokens = tokens
        self.errorReporter = errorReporter
    }

    func parse() -> Expression? {
        do {
            return try expression()
        } catch {
            errorReporter.report(error: error)
            return nil
        }
    }

    private func expression() throws -> Expression {
        try equality()
    }

    private func equality() throws -> Expression {
        var expression = try comparison()

        while match(tokenType: [.BangEqual, .EqualEqual]) {
            let op = previous()
            let right = try comparison()
            expression = BinaryExpression(left: expression, op: op, right: right)
        }

        return expression
    }

    private func comparison() throws -> Expression {
        var expression = try term()

        while match(tokenType: [.More, .MoreEqual, .Less, .LessEqual]) {
            let op = previous()
            let right = try term()
            expression = BinaryExpression(left: expression, op: op, right: right)
        }

        return expression
    }

    private func term() throws -> Expression {
        var expression = try factor()

        while match(tokenType: [.Minus, .Plus]) {
            let op = previous()
            let right = try factor()
            expression = BinaryExpression(left: expression, op: op, right: right)
        }

        return expression
    }

    private func factor() throws -> Expression {
        var expression = try unary()

        while match(tokenType: [.Slash, .Star]) {
            let op = previous()
            let right = try unary()
            expression = BinaryExpression(left: expression, op: op, right: right)
        }

        return expression
    }

    private func unary() throws -> Expression {
        if match(tokenType: [.Bang, .Minus]) {
            let op = previous()
            let right = try unary()
            return UnaryExpression(op: op, right: right)
        }

        return try primary()
    }

    private func primary() throws -> Expression {
        if match(.True) { return LiteralExpression(value: true) }
        if match(.False) { return LiteralExpression(value: false) }
        if match(.Nil) { return LiteralExpression(value: nil) }

        if match(.Number) { return LiteralExpression(value: Double(previous().lexeme)) }
        if match(.String) { return LiteralExpression(value: previous().lexeme) }

        if match(.LeftParen) {
            let expression = try expression()
            try consume(tokenType: .RightParen)
            return GroupingExpression(expression: expression)
        }

        throw ParserError.ExpectedExpression(token: peek())
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

    @discardableResult
    func consume(tokenType: TokenType) throws -> Token {
        guard check(tokenType: [tokenType]) else {
            throw ParserError.TokenNotFound(token: peek(), expected: tokenType)
        }
        return advance()
    }
}
