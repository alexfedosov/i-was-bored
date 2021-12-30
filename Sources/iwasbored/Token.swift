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
