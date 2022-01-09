class Interpreter: Visitor {
    func interpret(expression: Expression) -> Any? {
        return evaluate(expression: expression)
    }

    func evaluate(expression: Expression) -> Any? {
        expression.accept(visitor: self)
    }

    func visit(expression _: Expression) -> Any? {
        nil
    }

    func visit(literal: Literal) -> Any? {
        literal.value
    }

    func visit(binary: Binary) -> Any? {
        let left = evaluate(expression: binary.left)
        let right = evaluate(expression: binary.right)

        switch binary.op.type {
        case .Minus: return (left as! Double) - (right as! Double)
        case .Plus:
            if let left = left as? Double,
               let right = right as? Double
            {
                return left + right
            }
            if let left = left as? String,
               let right = right as? String
            {
                return left + right
            }
        case .Slash: return (left as! Double) / (right as! Double)
        case .Star: return (left as! Double) * (right as! Double)
        case .Less: return (left as! Double) < (right as! Double)
        case .More: return (left as! Double) > (right as! Double)
        case .LessEqual: return (left as! Double) <= (right as! Double)
        case .MoreEqual: return (left as! Double) >= (right as! Double)
        case .EqualEqual: return isEqual(left, right)
        // catch error
        default: break
        }

        return nil // catch error
    }

    func visit(grouping: Grouping) -> Any? {
        evaluate(expression: grouping.expression)
    }

    func visit(unary: Unary) -> Any? {
        let value = evaluate(expression: unary.right)
        switch unary.op.type {
        case .Minus: return -(value as! Double)
        case .Bang: return !isTruthy(value: value)
        default: return nil // should be unreachable
        }
    }

    func isTruthy(value: Any?) -> Bool {
        guard let value = value else { return false }
        if let value = value as? Bool,
           value == false
        {
            return false
        } else {
            return true
        }
    }

    func isTypedEqual<T: Equatable>(type _: T.Type, a: Any, b: Any) -> Bool {
        guard let a = a as? T, let b = b as? T else { return false }

        return a == b
    }

    func isEqual(_ left: Any?, _ right: Any?) -> Bool {
        guard let left = left, let right = right else {
            return left == nil && right == nil
        }
        return isTypedEqual(type: Double.self, a: left, b: right) ||
            isTypedEqual(type: Bool.self, a: left, b: right) ||
            isTypedEqual(type: String.self, a: left, b: right)
    }
}
