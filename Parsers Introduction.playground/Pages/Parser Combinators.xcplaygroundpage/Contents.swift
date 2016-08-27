import Foundation

let digit = character(condition: { CharacterSet.decimalDigits.contains($0.unicodeScalar) })
let int = digit.many.map { characters in Int(String(characters))! }

let multiplication = curry({ x, y in x * (y ?? 1) }) <^> int <*> (string("*") *> int).optional
let addition = curry({ x, y in x + (y ?? 0) }) <^> multiplication <*> (string("+") *> multiplication).optional


addition.run("2+5*3")