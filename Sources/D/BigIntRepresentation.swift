@frozen public struct BigIntRepresentation<Value> where Value: BinaryInteger {
    public var value: Value
    public var prefix: NumericSignDisplay
    @usableFromInline let format: BigIntFormat

    @inlinable init(value: Value, prefix: NumericSignDisplay, format: BigIntFormat) {
        self.value = value
        self.prefix = prefix
        self.format = format
    }
}
extension BigIntRepresentation {
    @inlinable public func map<T, E>(
        _ transform: (Value) throws(E) -> T
    ) throws(E) -> BigIntRepresentation<T> {
        .init(value: try transform(self.value), prefix: self.prefix, format: self.format)
    }
}
extension BigIntRepresentation {
    private var digits: Substring {
        /// We don’t just `abs(_:)` this, because it will crash on `Self.min`.
        if  self.value < 0 {
            let signed: String = "\(self.value)"
            return signed[signed.index(after: signed.startIndex)...]
        } else {
            return "\(self.value)"
        }
    }
}
extension BigIntRepresentation: CustomStringConvertible {
    @inlinable public var description: String { self.bare }
}
extension BigIntRepresentation: NumericRepresentation {
    @inlinable public var zero: Bool { self.value == 0 }
    @inlinable public var sign: Bool? { self.zero ? nil : 0 < self.value }

    public var bare: String {
        let ungrouped: Substring = self.digits
        let positive: Bool = self.value > 0
        let negative: Bool = self.value < 0


        let digits: Int = ungrouped.utf8.count

        let splits: (count: Int, stride: Int)?
        let remainder: Int

        if  let stride: UInt8 = self.format.stride, stride > 0 {
            let stride: Int = .init(stride)
            let count: Int

            (count, remainder: remainder) = digits.quotientAndRemainder(dividingBy: stride)

            splits = (remainder == 0 ? count - 1 : count, stride)
        } else {
            splits = nil
            remainder = digits
        }

        /// The unicode minus sign (U+2212) takes three bytes to encode in UTF-8.
        let characters: Int

        if  negative {
            characters = digits + (splits?.count ?? 0) + 3
        } else if case .plus = self.prefix, positive {
            characters = digits + (splits?.count ?? 0) + 1
        } else {
            characters = digits + (splits?.count ?? 0)
        }

        return .init(unsafeUninitializedCapacity: characters) {
            var i: Int

            if negative {
                $0[0] = 0xE2
                $0[1] = 0x88
                $0[2] = 0x92 // U+2212
                i = 3
            } else if case .plus = self.prefix, positive {
                $0[0] = 0x2B // '+'
                i = 1
            } else {
                i = 0
            }

            if let (splits, stride): (count: Int, Int) = splits, splits > 0 {
                var j: String.Index

                if remainder == 0 {
                    j = ungrouped.utf8.index(
                        ungrouped.utf8.startIndex,
                        offsetBy: stride
                    )
                } else {
                    j = ungrouped.utf8.index(
                        ungrouped.utf8.startIndex,
                        offsetBy: remainder
                    )
                }
                for utf8: UInt8 in ungrouped.utf8[..<j] {
                    $0[i] = utf8 ; i += 1
                }

                for _: Int in 0 ..< splits {
                    $0[i] = 0x2C ; i += 1 // ','

                    let next: String.Index = ungrouped.utf8.index(j, offsetBy: stride)
                    for utf8: UInt8 in ungrouped.utf8[j ..< next] {
                        $0[i] = utf8 ; i += 1
                    }
                    j = next
                }
            } else {
                for utf8: UInt8 in ungrouped.utf8 {
                    $0[i] = utf8 ; i += 1
                }
            }

            assert(i == characters)

            return characters
        }
    }
}
