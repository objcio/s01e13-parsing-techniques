import Foundation

final class Parser {
    let scanner: Scanner
    
    init(_ string: String) {
        scanner = Scanner(string: string)
    }
    
    func multiplication() -> Int? {
        let oldLocation = scanner.scanLocation
        guard let lhs = int() else { return nil }
        guard scanner.scanString("*", into: nil) else { return lhs }
        guard let rhs = int() else {
            scanner.scanLocation = oldLocation
            return nil
        }
        return lhs * rhs
    }
    
    func addition() -> Int? {
        let oldLocation = scanner.scanLocation
        guard let lhs = multiplication() else { return nil }
        guard scanner.scanString("+", into: nil) else { return lhs }
        guard let rhs = multiplication() else {
            scanner.scanLocation = oldLocation
            return nil
        }
        return lhs + rhs
    }
    
    func int() -> Int? {
        var result: Int = 0
        guard scanner.scanInt(&result) else { return nil }
        return result
    }
}

let parser = Parser("2+3")
parser.addition()