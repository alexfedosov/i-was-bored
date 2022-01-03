class ASTPrinter: Visitor {
    func visit(expression exp: Expression) -> String {
        String(describing: exp)
    }

    func visit(literal: Literal) -> String {
        String(describing: literal.value)
    }

    func visit(binary: Binary) -> String {
        parenthesize(name: binary.op.lexeme, exps: binary.left, binary.right)
    }

    func visit(grouping: Grouping) -> String {
        parenthesize(name: "group", exps: grouping.expression)
    }

    func visit(unary: Unary) -> String {
        parenthesize(name: unary.op.lexeme, exps: unary.right)
    }

    private func parenthesize(name: String, exps: Expression...) -> String {
        var result = "(\(name) "
        for exp in exps {
            result += " \(exp.accept(visitor: self))"
        }
        result += ")"
        return result
    }
}
