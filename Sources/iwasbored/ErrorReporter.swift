protocol ErrorReporter {
    var hasErrors: Bool { get }
    func report(error: Error)
}

class StdOutErrorReporter: ErrorReporter {
    var hasErrors: Bool = false

    func report(error: Error) {
        hasErrors = true
        print(error.localizedDescription)
    }
}
