import Foundation

public struct Parser<A> {
    public typealias Stream = String.CharacterView
    let parse: (Stream) -> (A, Stream)?
}


extension Parser {
    public func run(_ x: String) -> (A, Stream)? {
        return parse(x.characters)
    }
    
    public func map<Result>(_ f: (A) -> Result) -> Parser<Result> {
        return Parser<Result> { stream in
            guard let (result, newStream) = self.parse(stream) else { return nil }
            return (f(result), newStream)
        }
    }
    
    public var many: Parser<[A]> {
        return Parser<[A]> { stream in
            var result: [A] = []
            var remainder = stream
            while let (element, newRemainder) = self.parse(remainder) {
                remainder = newRemainder
                result.append(element)
            }
            return (result, remainder)
        }
    }
    
    public func or(_ other: Parser<A>) -> Parser<A> {
        return Parser { stream in
            return self.parse(stream) ?? other.parse(stream)
        }
    }
    
    public func followed<B, C>(by other: Parser<B>, combine: (A, B) -> C) -> Parser<C> {
        return Parser<C> { stream in
            guard let (result, remainder) = self.parse(stream) else { return nil }
            guard let (result2, remainder2) = other.parse(remainder) else { return nil }
            return (combine(result,result2), remainder2)
        }
    }
    
    public func followed<B>(by other: Parser<B>) -> Parser<(A, B)> {
        return followed(by: other, combine: { ($0, $1) })
    }
    
    public init(result: A) {
        parse = { stream in (result, stream) }
    }
    
    public var optional: Parser<A?> {
        return self.map({ .some($0) }).or(Parser<A?>(result: nil))
    }
}


public func curry<A, B, C>(_ f: (A, B) -> C) -> (A) -> (B) -> C {
    return { x in { y in f(x, y) } }
}


public func character(condition: (Character) -> Bool) -> Parser<Character> {
    return Parser { stream in
        guard let char = stream.first, condition(char) else { return nil }
        return (char, stream.dropFirst())
    }
}

public func string(_ string: String) -> Parser<String> {
    return Parser<String> { stream in
        var remainder = stream
        for char in string.characters {
            guard let (_, newRemainder) = character(condition: { $0 == char }).parse(remainder) else {
                return nil
            }
            remainder = newRemainder
        }
        return (string, remainder)
    }
}


infix operator <^> { associativity left precedence 130 }
infix operator <*> { associativity left precedence 130 }
infix operator <&> { associativity left precedence 130 }
infix operator *> { associativity left precedence 130 }
infix operator <* { associativity left precedence 130 }
infix operator <|> { associativity left precedence 110 }

public func <^><A, B>(f: (A) -> B, rhs: Parser<A>) -> Parser<B> {
    return rhs.map(f)
}

public func <^><A, B, R>(f: (A, B) -> R, rhs: Parser<A>) -> Parser<(B) -> R> {
    return Parser(result: curry(f)) <*> rhs
}



public func <*><A, B>(lhs: Parser<(A) -> B>, rhs: Parser<A>) -> Parser<B> {
    return lhs.followed(by: rhs, combine: { $0($1) })
}

public func <&><A, B>(lhs: Parser<A>, rhs: Parser<B>) -> Parser<(A,B)> {
    return lhs.followed(by: rhs, combine: { ($0, $1) })
}



public func <*<A, B>(lhs: Parser<A>, rhs: Parser<B>) -> Parser<A> {
    return lhs.followed(by: rhs, combine: { x, _ in x })
}

public func *><A, B>(lhs: Parser<A>, rhs: Parser<B>) -> Parser<B> {
    return lhs.followed(by: rhs, combine: { _, x in x })
}

public func <|><A>(lhs: Parser<A>, rhs: Parser<A>) -> Parser<A> {
    return lhs.or(rhs)
}



