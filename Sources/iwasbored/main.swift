import Darwin
import Foundation

func run(_ source: String) {
    let scanner = Scanner(source: source)
    let tokens = scanner.scanTokens()
    let parser = Parser(tokens: tokens)
    let expression = parser.parse()
    let printer = ASTPrinter()
    print(expression.accept(visitor: printer))
}

func runREPL() {
    print("Welcome to IWasBored REPL!")
    print("Type an expression to evaluate or an empty line to exit")
    while true {
        print("> ", terminator: "")
        if let line = readLine() {
            if line.isEmpty { break }
            run(line)
        }
    }
    print("Bye..")
}

func runFile(path: String) throws {
    let source = try String(contentsOfFile: path, encoding: .utf8)
    run(source)
}

func error(line: Int, message: String) {
    hadError = true
    print("Error at \(line): \(message)")
}

var hadError = false
do {
    if CommandLine.arguments.count < 2 {
        runREPL()
    } else {
        // This should be better, but I don't want to bring argument parser just yet
        let sourceFilePath = CommandLine.arguments[1]
        try runFile(path: sourceFilePath)
    }
} catch {
    print("Error: \(error)")
}

exit(hadError ? 65 : 0)
