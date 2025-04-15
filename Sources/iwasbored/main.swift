#if os(Linux)
import Glibc
#else
import Darwin
#endif
import Foundation

class IWasBored {
    let interpreter: Interpreter
    let errorReporter: ErrorReporter

    init() {
        errorReporter = StdOutErrorReporter()
        interpreter = Interpreter(errorReporter: errorReporter)
    }

    func run(_ source: String) -> Bool {
        errorReporter.reset()
        let scanner = Scanner(source: source, errorReporter: errorReporter)
        let tokens = scanner.scanTokens()
        let parser = Parser(tokens: tokens, errorReporter: errorReporter)
        let statements = parser.parse()
        if !errorReporter.hasErrors {
            interpreter.interpret(statements: statements)
        }

        return errorReporter.hasErrors
    }

    func runREPL() {
        print("Welcome to IWasBored REPL!")
        print("Type an expression to evaluate or an empty line to exit")
        while true {
            print("> ", terminator: "")
                guard let line = readLine(),
                      !line.isEmpty else { break }
            _ = run(line)
        }
        print("Bye..")
    }

    func runFile(path: String) throws -> Bool {
        let source = try String(contentsOfFile: path, encoding: .utf8)
        return run(source)
    }
}

let iWasBored = IWasBored()

if CommandLine.arguments.count < 2 {
    iWasBored.runREPL()
} else {
    // This should be better, but I don't want to bring argument parser just yet
    let sourceFilePath = CommandLine.arguments[1]
    if let hasErrors = try? iWasBored.runFile(path: sourceFilePath), !hasErrors {
        exit(65)
    }
}

exit(0)
