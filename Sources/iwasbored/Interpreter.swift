import Foundation

class Interpreter: ExpressionVisitor {
    typealias T = Any?

    enum RuntimeError: LocalizedError {
        case TypeError(line: Int, expected: String, found: String)

        var errorDescription: String? {
            let desc: String
            switch self {
            case let .TypeError(line, expected, found):
                desc = "Type error at line \(line): expected \(expected), found \(found)"
            }
            return "[Runtime error]: \(desc)"
        }
    }

    let errorReporter: ErrorReporter

    init(errorReporter: ErrorReporter) {
        self.errorReporter = errorReporter
    }

    func interpret(expression: Expression) -> Any? {
        do {
            return try evaluate(expression: expression)
        } catch {
            errorReporter.report(error: error)
            return nil
        }
    }

    func evaluate(expression: Expression) throws -> Any? {
        try expression.accept(visitor: self)
    }

    func visit(node _: Expression) throws -> Any? {
        nil
    }

    func visit(node: LiteralExpression) throws -> Any? {
        node.value
    }

    func visit(node: BinaryExpression) throws -> Any? {
        let left = try evaluate(expression: node.left)
        let right = try evaluate(expression: node.right)

        switch node.op.type {
        case .Minus:
            try typeCheck(value: left, type: Double.self, typeName: "Double", line: node.op.line)
            try typeCheck(value: right, type: Double.self, typeName: "Double", line: node.op.line)
            return (left as! Double) - (right as! Double)
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
            if left is Double {
                try typeCheck(value: right, type: Double.self, typeName: "Double", line: node.op.line)
            } else if left is String {
                try typeCheck(value: right, type: String.self, typeName: "String", line: node.op.line)
            }
            throw RuntimeError.TypeError(line: node.op.line, expected: "Double or String", found: String(reflecting: left.self))
        case .Slash:
            try typeCheck(value: left, type: Double.self, typeName: "Double", line: node.op.line)
            try typeCheck(value: right, type: Double.self, typeName: "Double", line: node.op.line)
            return (left as! Double) / (right as! Double)
        case .Star:
            try typeCheck(value: left, type: Double.self, typeName: "Double", line: node.op.line)
            try typeCheck(value: right, type: Double.self, typeName: "Double", line: node.op.line)
            return (left as! Double) * (right as! Double)
        case .Less:
            try typeCheck(value: left, type: Double.self, typeName: "Double", line: node.op.line)
            try typeCheck(value: right, type: Double.self, typeName: "Double", line: node.op.line)
            return (left as! Double) < (right as! Double)
        case .More:
            try typeCheck(value: left, type: Double.self, typeName: "Double", line: node.op.line)
            try typeCheck(value: right, type: Double.self, typeName: "Double", line: node.op.line)
            return (left as! Double) > (right as! Double)
        case .LessEqual:
            try typeCheck(value: left, type: Double.self, typeName: "Double", line: node.op.line)
            try typeCheck(value: right, type: Double.self, typeName: "Double", line: node.op.line)
            return (left as! Double) <= (right as! Double)
        case .MoreEqual:
            try typeCheck(value: left, type: Double.self, typeName: "Double", line: node.op.line)
            try typeCheck(value: right, type: Double.self, typeName: "Double", line: node.op.line)
            return (left as! Double) >= (right as! Double)
        case .EqualEqual:
            return isEqual(left, right)
        // catch error
        default: break
        }

        return nil // catch error
    }

    func visit(node: GroupingExpression) throws -> Any? {
        try evaluate(expression: node.expression)
    }

    func visit(node: UnaryExpression) throws -> Any? {
        let value = try evaluate(expression: node.right)
        switch node.op.type {
        case .Minus: return -(value as! Double)
        case .Bang: return !isTruthy(value: value)
        default: return nil // should be unreachable
        }
    }
}

extension Interpreter {
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

    func typeCheck<T>(value: Any?, type _: T.Type, typeName: String, line: Int) throws {
        guard let value = value else {
            throw Self.RuntimeError.TypeError(line: line, expected: typeName, found: "nil")
        }

        guard value is T else {
            throw Self.RuntimeError.TypeError(line: line, expected: typeName, found: String(reflecting: value.self))
        }
    }
}
