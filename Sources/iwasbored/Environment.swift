class Environment {
    struct Box {
        let value: Any?
    }

    private var enclosing: Environment?
    private var variables: [String: Box] = [:]

    init(enclosing: Environment? = nil) {
        self.enclosing = enclosing
    }

    func declare(token: Token, value: Any?) {
        // we allow redeclaration on purpose
        variables[token.lexeme] = Box(value: value)
    }

    func get(token: Token) throws -> Any? {
        if let box = variables[token.lexeme] {
            return box.value
        } else if let enclosing = enclosing {
            return try enclosing.get(token: token)
        } else {
            throw Interpreter.RuntimeError.UnknownVariable(line: token.line, name: token.lexeme)
        }
    }

    func assign(token: Token, value: Any?) throws {
        if let _ = variables[token.lexeme] {
            variables[token.lexeme] = Box(value: value)
        } else if let enclosing = enclosing {
            try enclosing.assign(token: token, value: value)
        } else {
            throw Interpreter.RuntimeError.UnknownVariable(line: token.line, name: token.lexeme)
        }
    }
}
