import Darwin
import Foundation

func run(_ source: String) -> Bool {
    let errorReporter = StdOutErrorReporter()
    let scanner = Scanner(source: source, errorReporter: errorReporter)
    let tokens = scanner.scanTokens()
    let parser = Parser(tokens: tokens, errorReporter: errorReporter)
    if let expression = parser.parse(), !errorReporter.hasErrors {
        let printer = ASTPrinter()
        print(expression.accept(visitor: printer))
    }

    return errorReporter.hasErrors
}

func runREPL() {
    print("Welcome to IWasBored REPL!")
    print("Type an expression to evaluate or an empty line to exit")
    while true {
        print("> ", terminator: "")
        if let line = readLine() {
            if line.isEmpty { break }
            _ = run(line)
        }
    }
    print("Bye..")
}

func runFile(path: String) throws -> Bool {
    let source = try String(contentsOfFile: path, encoding: .utf8)
    return run(source)
}

if CommandLine.arguments.count < 2 {
    runREPL()
} else {
    // This should be better, but I don't want to bring argument parser just yet
    let sourceFilePath = CommandLine.arguments[1]
    if let hasErrors = try? runFile(path: sourceFilePath), !hasErrors {
        exit(65)
    }
}

exit(0)
