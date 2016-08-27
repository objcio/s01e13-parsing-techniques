import Foundation

extension Character {
    public var unicodeScalar: UnicodeScalar {
        return String(self).unicodeScalars.first!
    }
}

