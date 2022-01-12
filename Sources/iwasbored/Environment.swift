class Environment {
    struct Box {
        let value: Any?
    }

    private var variables: [String: Box] = [:]

    func declare(token: Token, value: Any?) {
        // we allow redeclaration on purpose
        variables[token.lexeme] = Box(value: value)
    }

    func get(token: Token) throws -> Any? {
        guard let boxedValue = variables[token.lexeme] else {
            throw Interpreter.RuntimeError.UnknownVariable(line: token.line, name: token.lexeme)
        }
        return boxedValue.value
    }
}
