import Foundation

enum ParserError: LocalizedError {
    case TokenNotFound(token: Token, expected: TokenType)
    case ExpectedExpression(token: Token)
    case UnterminatedString(line: Int, lexeme: String)
    case CouldNotParseNumber(line: Int, lexeme: String)
    case UnexpectedCharacter(line: Int, character: Character)
    case InvalidAssignmentTarget(token: Token)
    case UnexpectedToken(token: Token)

    var errorDescription: String? {
        switch self {
        case let .TokenNotFound(token, expected):
            return "Expected \"\(expected)\" at \(token.line), found \"\(token)\""
        case let .ExpectedExpression(token):
            return "Expected expression, found \"\(token)\""
        case let .UnterminatedString(line, lexeme):
            return "Unterminated string at \(line): \"\(lexeme)\""
        case let .CouldNotParseNumber(line, lexeme):
            return "Could not parse number at \(line): \"\(lexeme)\""
        case let .UnexpectedCharacter(line, character):
            return "Unexpected character at \(line): \"\(character)\""
        case let .InvalidAssignmentTarget(token):
            return "Invalid assignment target at line \(token.line) \"\(token.lexeme)\""
        case let .UnexpectedToken(token):
            return "Unexpected token at line \(token.line) \"\(token.lexeme)\""
                + " Did you try to use expression in place of statement?"
        }
    }
}
