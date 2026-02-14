extension Decimal {
    /// This type is a severely crippled form of ``Decimal``, which only exists to allow
    /// ``Decimal`` to conform to ``Numeric``.
    @frozen public struct Magnitude: Sendable {
        public let units: UInt64
        public let power: Int64

        @inlinable public init(units: UInt64, power: Int64) {
            self.units = units
            self.power = power
        }
    }
}
extension Decimal.Magnitude: ExpressibleByIntegerLiteral {
    @inlinable public init(integerLiteral: UInt64) {
        self.init(integerLiteral)
    }
}
extension Decimal.Magnitude {
    @inlinable public init(_ integer: UInt64) {
        self.init(units: integer, power: 0)
    }
}
extension Decimal.Magnitude: Equatable {
    @inlinable public static func == (a: Self, b: Self) -> Bool { self.equals(a, b) }
}
extension Decimal.Magnitude: Comparable {
    @inlinable public static func < (a: Self, b: Self) -> Bool { self.less(a, b) }
}
extension Decimal.Magnitude: DecimalArithmetic {
    @inlinable public var sign: Bool? { self.units == 0 ? nil : true }
}
extension Decimal.Magnitude: AdditiveArithmetic {
    @inlinable public static var zero: Self { .init(units: 0, power: 0) }

    @inlinable public static func + (a: Self, b: Self) -> Self {
        let ((a, b), power): ((UInt64, UInt64), Int64) = a || b
        return .init(units: a + b, power: power)
    }

    @inlinable public static func - (a: Self, b: Self) -> Self {
        let ((a, b), power): ((UInt64, UInt64), Int64) = a || b
        return .init(units: a - b, power: power)
    }
}
extension Decimal.Magnitude: Numeric {
    @inlinable public init?(exactly value: some BinaryInteger) {
        guard let value: UInt64 = .init(exactly: value) else {
            return nil
        }
        self.init(value)
    }

    @inlinable public var magnitude: Self { self }

    @inlinable public static func * (a: Self, b: Self) -> Self {
        .init(units: a.units * b.units, power: a.power + b.power)
    }

    @inlinable public static func *= (self: inout Self, factor: Self) {
        self = self * factor
    }
}
