protocol ErrorReporter {
    var hasErrors: Bool { get }
    func report(error: Error)
    func reset()
}

class StdOutErrorReporter: ErrorReporter {
    var hasErrors: Bool = false

    func report(error: Error) {
        hasErrors = true
        print(error.localizedDescription)
    }

    func reset() {
        hasErrors = false
    }
}
