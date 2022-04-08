class Environment {
    struct Box {
        let value: Any?
        let mutable: Bool
    }

    private var enclosing: Environment?
    private var variables: [String: Box] = [:]

    init(enclosing: Environment? = nil) {
        self.enclosing = enclosing
    }

    func declare(token: Token, value: Any?, mutable: Bool) {
        // we allow redeclaration on purpose
        variables[token.lexeme] = Box(value: value, mutable: mutable)
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
        if let variable = variables[token.lexeme] {
            guard variable.mutable else {
                throw Interpreter.RuntimeError.ReassigningConstantValue(line: token.line, name: token.lexeme)
            }
            variables[token.lexeme] = Box(value: value, mutable: true)
        } else if let enclosing = enclosing {
            try enclosing.assign(token: token, value: value)
        } else {
            throw Interpreter.RuntimeError.UnknownVariable(line: token.line, name: token.lexeme)
        }
    }
}
