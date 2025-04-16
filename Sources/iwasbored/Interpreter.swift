import Foundation

class Interpreter {
    typealias T = Any?

    enum RuntimeError: LocalizedError {
        case TypeError(line: Int, expected: String, found: String)
        case UnknownVariable(line: Int, name: String)
        case ReassigningConstantValue(line: Int, name: String)
        case IndexOutOfBounds(line: Int, index: Int, size: Int)
        case UnsupportedMethod(line: Int, type: String, method: String)

        var errorDescription: String? {
            let desc: String
            switch self {
            case let .TypeError(line, expected, found):
                desc = "Type error at line \(line): expected \(expected), found \(found)"
            case let .UnknownVariable(line, name):
                desc = "Unknown variable \(name) at line \(line)"
            case let .ReassigningConstantValue(line, name):
                desc = "Can not reassign value of constant \(name) at line \(line)"
            case let .IndexOutOfBounds(line, index, size):
                desc = "Index out of bounds at line \(line): index \(index), size \(size)"
            case let .UnsupportedMethod(line, type, method):
                desc = "Unsupported method \(method) for type \(type) at line \(line)"
            }
            return "[Runtime error]: \(desc)"
        }
    }

    var environment = Environment()
    let errorReporter: ErrorReporter

    init(errorReporter: ErrorReporter) {
        self.errorReporter = errorReporter
    }

    func interpret(statements: [Statement]) {
        do {
            for statement in statements {
                _ = try statement.accept(visitor: self)
            }
        } catch {
            errorReporter.report(error: error)
        }
    }

    func evaluate(expression: Expression) throws -> Any? {
        try expression.accept(visitor: self)
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
        
        if let leftArray = left as? [Any?], let rightArray = right as? [Any?] {
            guard leftArray.count == rightArray.count else { return false }
            for i in 0..<leftArray.count {
                if !isEqual(leftArray[i], rightArray[i]) {
                    return false
                }
            }
            return true
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

    func stringify(value: Any?) -> String {
        guard let value = value else { return "nil" }
        
        if let array = value as? [Any?] {
            var elements: [String] = []
            for element in array {
                elements.append(stringify(value: element))
            }
            return "[\(elements.joined(separator: ", "))]"
        }

        if value is Double {
            let doubleRepresentation = String(value as! Double)
            if doubleRepresentation.hasSuffix(".0") {
                return String(doubleRepresentation.dropLast(2))
            } else {
                return doubleRepresentation
            }
        }

        return String(describing: value)
    }
}

extension Interpreter: ExpressionVisitor {
    func visit(node _: Expression) throws -> Any? { nil }

    func visit(node: LiteralExpression) throws -> Any? {
        node.value
    }
    
    func visit(node: ArrayExpression) throws -> Any? {
        var elements: [Any?] = []
        for element in node.elements {
            elements.append(try evaluate(expression: element))
        }
        return elements
    }
    
    func visit(node: SubscriptExpression) throws -> Any? {
        let array = try evaluate(expression: node.array)
        try typeCheck(value: array, type: [Any?].self, typeName: "Array", line: 0)
        
        let index = try evaluate(expression: node.index)
        try typeCheck(value: index, type: Double.self, typeName: "Number", line: 0)
        
        let intIndex = Int(index as! Double)
        let arrayValue = array as! [Any?]
        
        guard intIndex >= 0 && intIndex < arrayValue.count else {
            throw RuntimeError.IndexOutOfBounds(line: 0, index: intIndex, size: arrayValue.count)
        }
        
        return arrayValue[intIndex]
    }
    
    func visit(node: CallExpression) throws -> Any? {
        let object = try evaluate(expression: node.callee)
        let method = node.name.lexeme
        
        if let array = object as? [Any?] {
            switch method {
            case "push":
                guard node.arguments.count == 1 else {
                    throw RuntimeError.UnsupportedMethod(line: node.name.line, type: "Array", method: "\(method) with \(node.arguments.count) arguments")
                }
                let value = try evaluate(expression: node.arguments[0])
                var newArray = array
                newArray.append(value)
                return newArray
                
            case "pop":
                guard node.arguments.count == 0 else {
                    throw RuntimeError.UnsupportedMethod(line: node.name.line, type: "Array", method: "\(method) with \(node.arguments.count) arguments")
                }
                guard !array.isEmpty else {
                    throw RuntimeError.IndexOutOfBounds(line: node.name.line, index: -1, size: array.count)
                }
                let value = array.last
                var newArray = array
                newArray.removeLast()
                return value as Any?
                
            case "get":
                guard node.arguments.count == 1 else {
                    throw RuntimeError.UnsupportedMethod(line: node.name.line, type: "Array", method: "\(method) with \(node.arguments.count) arguments")
                }
                let index = try evaluate(expression: node.arguments[0])
                try typeCheck(value: index, type: Double.self, typeName: "Number", line: node.name.line)
                
                let intIndex = Int(index as! Double)
                guard intIndex >= 0 && intIndex < array.count else {
                    throw RuntimeError.IndexOutOfBounds(line: node.name.line, index: intIndex, size: array.count)
                }
                
                return array[intIndex]
                
            case "set":
                guard node.arguments.count == 2 else {
                    throw RuntimeError.UnsupportedMethod(line: node.name.line, type: "Array", method: "\(method) with \(node.arguments.count) arguments")
                }
                let index = try evaluate(expression: node.arguments[0])
                try typeCheck(value: index, type: Double.self, typeName: "Number", line: node.name.line)
                
                let value = try evaluate(expression: node.arguments[1])
                let intIndex = Int(index as! Double)
                
                guard intIndex >= 0 && intIndex < array.count else {
                    throw RuntimeError.IndexOutOfBounds(line: node.name.line, index: intIndex, size: array.count)
                }
                
                var newArray = array
                newArray[intIndex] = value
                return newArray
                
            default:
                throw RuntimeError.UnsupportedMethod(line: node.name.line, type: "Array", method: method)
            }
        }
        
        throw RuntimeError.UnsupportedMethod(line: node.name.line, type: String(describing: type(of: object)), method: method)
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

    func visit(node: VariableExpression) throws -> Any? {
        return try environment.get(token: node.name)
    }

    func visit(node: ConstantExpression) throws -> Any? {
        return try environment.get(token: node.name)
    }

    func visit(node: AssignmentExpression) throws -> Any? {
        let value = try evaluate(expression: node.value)
        try environment.assign(token: node.name, value: value)
        return value
    }

    func visit(node: LogicalExpression) throws -> Any? {
        switch node.op.type {
        case .Maybe:
            return try evaluate(expression: Bool.random() ? node.left : node.right)
        case .And:
            let left = try evaluate(expression: node.left)
            if isTruthy(value: left) {
                return try evaluate(expression: node.right)
            } else {
                return left
            }
        case .Or:
            let left = try evaluate(expression: node.left)
            if !isTruthy(value: left) {
                return try evaluate(expression: node.right)
            } else {
                return left
            }
        default: break
        }
        return nil
    }
}

extension Interpreter: StatementVisitor {
    func visit(node _: Statement) throws -> Any? { nil }

    func visit(node: PrintStatement) throws -> Any? {
        let value = try evaluate(expression: node.expression)
        print(stringify(value: value))
        return nil
    }

    func visit(node: ExpressionStatement) throws -> Any? {
        try node.expression.accept(visitor: self)
    }

    func visit(node: VarStatement) throws -> Any? {
        let value = try evaluate(expression: node.initializer)
        environment.declare(token: node.name, value: value, mutable: true)
        return nil
    }

    func visit(node: ConstStatement) throws -> Any? {
        let value = try evaluate(expression: node.initializer)
        environment.declare(token: node.name, value: value, mutable: false)
        return nil
    }

    func visit(node: BlockStatement) throws -> Any? {
        let previousEnvironment = environment
        environment = Environment(enclosing: previousEnvironment)
        defer { environment = previousEnvironment }
        for statement in node.statements {
            _ = try statement.accept(visitor: self)
        }
        return nil
    }

    func visit(node: IfStatement) throws -> Any? {
        if isTruthy(value: try evaluate(expression: node.condition)) {
            _ = try node.thenBlock.accept(visitor: self)
        } else {
            _ = try node.elseBlock?.accept(visitor: self)
        }
        return nil
    }

    func visit(node: WhileStatement) throws -> Any? {
        while isTruthy(value: try evaluate(expression: node.condition)) {
            _ = try node.block.accept(visitor: self)
        }
        return nil
    }
}
