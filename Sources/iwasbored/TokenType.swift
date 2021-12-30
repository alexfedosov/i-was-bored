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

    case Eof
}
