struct Token {
    let lexeme: String
    let type: TokenType
    let line: Int

    init(lexeme: String = "", type: TokenType, line: Int) {
        self.type = type
        self.line = line
        self.lexeme = lexeme
    }
}

extension Token: CustomStringConvertible {
    var description: String {
        switch type {
        case .Newline: fallthrough
        case .Eof: return type.description
        default: return lexeme
        }
    }
}
