enum TokenType {
    // Literals
    case Identifier
    case String
    case Number

    // single-character tokens
    case Equal
    case Bang
    case Minus
    case Plus
    case Slash
    case LeftParen
    case RightParen
    case LeftBrace
    case RightBrace
    case Comma
    case Dot
    case Colon
    case Semicolon
    case Star
    case Less
    case More
    case Newline

    // double-character tokens
    case BangEqual
    case EqualEqual
    case LessEqual
    case MoreEqual

    // Keywords
    case Var
    case Func
    case Return
    case True
    case False
    case Nil
    case Print

    case Eof
}

extension TokenType: CustomStringConvertible {
    var description: String {
        switch self {
        // Literals
        case .Identifier: return "identifier"
        case .String: return "string"
        case .Number: return "number"

        // single-character tokens
        case .Equal: return "="
        case .Bang: return "!"
        case .Minus: return "-"
        case .Plus: return "+"
        case .Slash: return "/"
        case .LeftParen: return "("
        case .RightParen: return ")"
        case .LeftBrace: return "{"
        case .RightBrace: return "}"
        case .Comma: return ","
        case .Dot: return "."
        case .Colon: return ":"
        case .Semicolon: return ";"
        case .Star: return "*"
        case .Less: return "<"
        case .More: return ">"
        case .Newline: return "new line"

        // double-character tokens
        case .BangEqual: return "!="
        case .EqualEqual: return "=="
        case .LessEqual: return "<="
        case .MoreEqual: return ">="

        // Keywords
        case .Var: return "var"
        case .Func: return "func"
        case .Return: return "return"
        case .True: return "true"
        case .False: return "false"
        case .Nil: return "nil"
        case .Print: return "print"

        case .Eof: return "end of file"
        }
    }
}
