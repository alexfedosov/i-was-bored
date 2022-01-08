class Scanner {
    private let source: String
    private let errorReporter: ErrorReporter
    private var tokens: [Token] = []
    private var currentCharacterIndex: String.Index
    private var lexemeStart: String.Index
    private var line: Int = 0
    private var isAtEnd: Bool { currentCharacterIndex >= source.endIndex }
    private var keywordMap: [String: TokenType]

    init(source: String, errorReporter: ErrorReporter) {
        self.source = source
        self.errorReporter = errorReporter
        currentCharacterIndex = source.startIndex
        lexemeStart = currentCharacterIndex
        keywordMap = [
            "var": .Var,
            "func": .Func,
            "return": .Return,
            "true": .True,
            "false": .False,
            "nil": .Nil,
        ]
    }

    func scanTokens() -> [Token] {
        while !isAtEnd {
            lexemeStart = currentCharacterIndex
            scanToken()
        }

        lexemeStart = source.endIndex
        addToken(type: .Eof)
        return tokens
    }

    func scanToken() {
        let char = advance()
        switch char {
        case "=": addToken(type: match("=") ? .EqualEqual : .Equal)
        case "!": addToken(type: match("=") ? .BangEqual : .Bang)
        case "-": addToken(type: .Minus)
        case "+": addToken(type: .Plus)
        case "/":
            if match("/") {
                while let p = peek(), !p.isNewline { advance() }
            } else {
                addToken(type: .Slash)
            }
        case "(": addToken(type: .LeftParen)
        case ")": addToken(type: .RightParen)
        case "{": addToken(type: .LeftBrace)
        case "}": addToken(type: .RightBrace)
        case ",": addToken(type: .Comma)
        case ".": addToken(type: .Dot)
        case ":": addToken(type: .Colon)
        case ";": addToken(type: .Semicolon)
        case "*": addToken(type: .Star)
        case "<": addToken(type: match("=") ? .LessEqual : .Less)
        case ">": addToken(type: match("=") ? .MoreEqual : .More)
        case "\"": readString()
        case char where isDigit(char: char): readNumber()
        case char where isAlpha(char: char): readIdentifier()
        case char where char.isNewline:
            addToken(type: .Newline)
            line += 1
        case char where char.isWhitespace: break
        default:
            errorReporter.report(error: ParserError.UnexpectedCharacter(line: line, character: char))
        }
    }

    func match(_ character: Character) -> Bool {
        guard !isAtEnd, source[currentCharacterIndex] == character else { return false }
        currentCharacterIndex = source.index(after: currentCharacterIndex)
        return true
    }

    func addToken(type: TokenType) {
        let lexeme = String(source[lexemeStart ..< currentCharacterIndex])
        let token = Token(lexeme: lexeme, type: type, line: line)
        tokens.append(token)
    }

    @discardableResult
    func advance() -> Character {
        let char = source[currentCharacterIndex]
        currentCharacterIndex = source.index(after: currentCharacterIndex)
        return char
    }

    func peek(_ offset: Int = 0) -> Character? {
        guard !isAtEnd else { return nil }
        if let offsetIndex = source.index(currentCharacterIndex, offsetBy: offset, limitedBy: source.endIndex) {
            return source[offsetIndex]
        } else {
            return nil
        }
    }

    func readString() {
        while let char = peek(), char != "\"" {
            advance()
        }
        let lexeme = String(source[lexemeStart ..< currentCharacterIndex])
        if peek() == nil {
            errorReporter.report(error: ParserError.UnterminatedString(line: line, lexeme: lexeme))
        } else {
            let stringValue = String(lexeme[lexeme.index(after: lexeme.startIndex) ..< lexeme.endIndex])
            let token = Token(lexeme: stringValue, type: .String, line: line)
            tokens.append(token)
            advance()
        }
    }

    func isDigit(char: Character?) -> Bool {
        guard let char = char else { return false }
        return char >= "0" && char <= "9"
    }

    func isAlpha(char: Character?) -> Bool {
        guard let char = char else { return false }
        return char >= "a" && char <= "z"
            || char >= "A" && char <= "Z"
            || char == "_"
    }

    func readNumber() {
        while let char = peek(), isDigit(char: char) {
            advance()
        }

        if peek() == ".", isDigit(char: peek(1)) {
            // consume the dot
            advance()
            // consume fractional part
            while isDigit(char: peek()), !isAtEnd {
                advance()
            }
        }

        let lexeme = String(source[lexemeStart ..< currentCharacterIndex])
        if let _ = Double(lexeme) {
            addToken(type: .Number)
        } else {
            errorReporter.report(error: ParserError.CouldNotParseNumber(line: line, lexeme: lexeme))
        }
    }

    func readIdentifier() {
        while isAlpha(char: peek()), !isAtEnd {
            advance()
        }
        let lexeme = String(source[lexemeStart ..< currentCharacterIndex])
        let tokenType = keywordMap[lexeme] ?? .Identifier
        addToken(type: tokenType)
    }
}
