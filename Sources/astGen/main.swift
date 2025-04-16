import Foundation

@discardableResult
func shell(_ args: String...) -> Int32 {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    task.arguments = args
    try? task.run()
    task.waitUntilExit()
    return task.terminationStatus
}

class ASTGen {
    private var output = ""

    private func parseStructDefinition(_ definition: String) -> [(name: String, type: String)] {
        definition.split(separator: ",")
            .map { arg in
                let property = arg
                    .split(separator: ":")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                return (name: property[0], type: property[1])
            }
    }

    private func writeStructProperties(_ properties: [(name: String, type: String)]) {
        for (name, type) in properties {
            addLine("let \(name): \(type)")
        }
    }

    private func writeStructVisitorMethod(visitorClass: String) {
        addLine("func accept<V: \(visitorClass)>(visitor: V) throws -> V.T {")
        addLine("try visitor.visit(node: self)")
        addLine("}")
    }

    private func writeStruct(name: String, base: String, definition: String) {
        addLine("struct \(name): \(base) {")
        let properties = parseStructDefinition(definition)
        writeStructProperties(properties)
        addLine("")
        writeStructVisitorMethod(visitorClass: "\(base)Visitor")
        addLine("}")
    }

    private func writeVisitorProtocol(base: String, classNames: [String]) {
        addLine("protocol \(base)Visitor {")
        addLine("associatedtype T")
        addLine("func visit(node: \(base)) throws -> T")
        for name in classNames.sorted() {
            addLine("func visit(node: \(name + base)) throws -> T")
        }
        addLine("}")
    }

    private func addLine(_ str: String) {
        output += "\(str)\n"
    }

    func generate(base: String, definitions: [String: String]) -> String {
        output = ""
        writeVisitorProtocol(base: base, classNames: Array(definitions.keys))
        addLine("")
        addLine("protocol \(base) {")
        addLine("func accept<V: \(base)Visitor>(visitor: V) throws -> V.T")
        addLine("}")
        addLine("")
        for name in definitions.keys.sorted() {
            writeStruct(name: name + base, base: base, definition: definitions[name]!)
            addLine("")
        }
        return output
    }
}

guard CommandLine.arguments.count == 2 else {
    print("Usage: astGen <output dir>")
    exit(65)
}

let outputFile = CommandLine.arguments[1]

let generator = ASTGen()
let statementClass = generator.generate(base: "Statement", definitions: [
    "Expression": "expression: Expression",
    "Print": "expression: Expression",
    "Var": "name: Token, initializer: Expression",
    "Const": "name: Token, initializer: Expression",
    "Block": "statements: [Statement]",
    "If": "condition: Expression, thenBlock: Statement, elseBlock: Statement?",
    "While": "condition: Expression, block: Statement",
])
let expressionClass = generator.generate(base: "Expression", definitions: [
    "Assignment": "name: Token, value: Expression",
    "Binary": "left: Expression, op: Token, right: Expression",
    "Grouping": "expression: Expression",
    "Literal": "value: Any?",
    "Unary": "op: Token, right: Expression",
    "Variable": "name: Token",
    "Constant": "name: Token",
    "Logical": "left: Expression, op: Token, right: Expression",
    "Array": "elements: [Expression]",
    "Subscript": "array: Expression, index: Expression",
    "Call": "callee: Expression, name: Token, arguments: [Expression]",
])
let output = [statementClass, expressionClass].joined(separator: "\n\n")

let filePath = URL(fileURLWithPath: outputFile)
do {
    try (output as NSString).write(to: filePath, atomically: true, encoding: String.Encoding.utf8.rawValue)
    exit(shell("swift-format", "-i", outputFile))
} catch { print(error) }
