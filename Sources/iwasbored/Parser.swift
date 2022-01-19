final class Parser {
    let tokens: [Token]
    let errorReporter: ErrorReporter
    var currentToken = 0
    var isAtEnd: Bool { tokens[currentToken].type == .Eof }

    init(tokens: [Token], errorReporter: ErrorReporter) {
        self.tokens = tokens
        self.errorReporter = errorReporter
    }

    func parse() -> [Statement] {
        var statements: [Statement] = []
        while !isAtEnd {
            if let declaration = declaration() {
                statements.append(declaration)
            }
        }
        return statements
    }

    private func declaration() -> Statement? {
        do {
            return try statement()
        } catch {
            synchronize()
            errorReporter.report(error: error)
        }
        return nil
    }

    private func varDeclaration() throws -> Statement {
        let name = try consume(tokenType: .Identifier)
        let initializer: Expression
        if match(.Equal) {
            initializer = try expression()
        } else {
            initializer = LiteralExpression(value: nil)
        }
        return VarStatement(name: name, initializer: initializer)
    }

    private func printStatement() throws -> Statement {
        try consume(tokenType: .LeftParen)
        let expression = try expression()
        try consume(tokenType: .RightParen)
        return PrintStatement(expression: expression)
    }

    private func ifStatement() throws -> Statement {
        let condition = try expression()
        try consume(tokenType: .LeftBrace)
        let thenBlock = BlockStatement(statements: try block())
        var elseBlock: Statement?
        if match(.Else) {
            if match(.If) {
                elseBlock = try ifStatement()
            } else {
                try consume(tokenType: .LeftBrace)
                elseBlock = BlockStatement(statements: try block())
            }
        }
        return IfStatement(condition: condition, thenBlock: thenBlock, elseBlock: elseBlock)
    }

    private func whileStatement() throws -> Statement {
        let condition = try expression()
        try consume(tokenType: .LeftBrace)
        let block = BlockStatement(statements: try block())
        return WhileStatement(condition: condition, block: block)
    }

    private func statement() throws -> Statement {
        if match(.Var) { return try varDeclaration() }
        if match(.Print) { return try printStatement() }
        if match(.LeftBrace) { return BlockStatement(statements: try block()) }
        if match(.If) { return try ifStatement() }
        if match(.While) { return try whileStatement() }

        let expression = try expression()
        return ExpressionStatement(expression: expression)
    }

    private func block() throws -> [Statement] {
        var statements: [Statement] = []
        while !isAtEnd, peek().type != .RightBrace {
            if let statement = declaration() {
                statements.append(statement)
            }
        }
        try consume(tokenType: .RightBrace)
        return statements
    }

    private func expression() throws -> Expression {
        try assignment()
    }

    private func assignment() throws -> Expression {
        let expression = try maybe()

        if match(.Equal) {
            let token = previous()
            let assignment = try assignment()

            guard let expression = expression as? VariableExpression else {
                throw ParserError.InvalidAssignmentTarget(token: token)
            }

            return AssignmentExpression(name: expression.name, value: assignment)
        }

        return expression
    }

    private func maybe() throws -> Expression {
        var expression = try or()
        while match(.Maybe) {
            let op = previous()
            let right = try or()
            expression = LogicalExpression(left: expression, op: op, right: right)
        }

        return expression
    }

    private func or() throws -> Expression {
        var expression = try and()
        while match(.Or) {
            let op = previous()
            let right = try and()
            expression = LogicalExpression(left: expression, op: op, right: right)
        }

        return expression
    }

    private func and() throws -> Expression {
        var expression = try equality()
        while match(.And) {
            let op = previous()
            let right = try equality()
            expression = LogicalExpression(left: expression, op: op, right: right)
        }

        return expression
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

        if match(.Identifier) { return VariableExpression(name: previous()) }

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

    private func synchronize() {
        advance()

        let nextStatementStartSet: Set<TokenType> = [
            .Func,
            .Var,
            .Return,
            .Print,
            .If,
        ]

        while !isAtEnd {
            if previous().type == .Semicolon { return }
            if nextStatementStartSet.contains(peek().type) { return }
            advance()
        }
    }
}
