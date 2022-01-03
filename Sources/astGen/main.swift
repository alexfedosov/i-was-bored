import Foundation

@discardableResult
func shell(_ args: String...) -> Int32 {
    let task = Process()
    task.launchPath = "/usr/local/bin/swift-format"
    task.arguments = args
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}

class ASTGen {
    private var output = ""

    private func parseClassDefinition(_ definition: String) -> [(name: String, type: String)] {
        definition.split(separator: ",").map { arg in
            let property = arg
                .split(separator: ":")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            return (name: property[0], type: property[1])
        }
    }

    private func writeClassProperties(_ properties: [(name: String, type: String)]) {
        for (name, type) in properties {
            addLine("let \(name): \(type)")
        }
    }

    private func writeClassInit(properties: [(name: String, type: String)]) {
        let initArgs = properties
            .map { $0.name + ": " + $0.type }
            .joined(separator: ", ")
        addLine("init(\(initArgs)) {")
        for (name, _) in properties {
            addLine("self.\(name) = \(name)")
        }
        addLine("super.init()")
        addLine("}")
    }

    private func writeClassVisitorMethod(name: String, isOverride: Bool = true) {
        addLine("\(isOverride ? "override " : "")func accept<V: Visitor>(visitor: V) -> V.T {")
        addLine("visitor.visit(\(name.lowercased()): self)")
        addLine("}")
    }

    private func writeClass(name: String, base: String?, definition: String?) {
        if let base = base {
            addLine("class \(name): \(base) {")
        } else {
            addLine("class \(name) {")
        }
        if let definition = definition {
            let properties = parseClassDefinition(definition)
            writeClassProperties(properties)
            addLine("")
            writeClassInit(properties: properties)
        }
        addLine("")
        writeClassVisitorMethod(name: name, isOverride: base != nil)
        addLine("}")
    }

    private func writeVisitorProtocol(classNames: [String]) {
        addLine("protocol Visitor {")
        addLine("associatedtype T")
        for name in classNames {
            addLine("func visit(\(name.lowercased()) node: \(name)) -> T")
        }
        addLine("}")
    }

    private func addLine(_ str: String) {
        output += "\(str)\n"
    }

    func generate(base: String, definitions: [String: String]) -> String {
        output = "// Generated by astGen. Do not edit manually"
        addLine("")
        writeVisitorProtocol(classNames: [base] + Array(definitions.keys))
        addLine("")
        writeClass(name: base, base: nil, definition: nil)
        addLine("")
        for (name, definition) in definitions {
            writeClass(name: name, base: base, definition: definition)
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

let base = "Expression"
let ast = [
    "Binary": "left: \(base), op: Token, right: \(base)",
    "Grouping": "expression: \(base)",
    "Literal": "value: Any?",
    "Unary": "op: Token, right: \(base)",
]

let output = ASTGen().generate(base: base, definitions: ast)
let filePath = URL(fileURLWithPath: outputFile)
do {
    try (output as NSString).write(to: filePath, atomically: true, encoding: String.Encoding.utf8.rawValue)
    exit(shell("--in-place", outputFile))
} catch { print(error) }
