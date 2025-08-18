import RealModule

@frozen public struct DecimalLog {
    public var value: Double?

    @inlinable public init(value: Double = 0) {
        self.value = value
    }
}
extension DecimalLog {
    @inlinable public func raise(scaling value: Decimal) -> Double {
        guard let log: Double = self.value else {
            return 0
        }

        if  log == 0 {
            return Double.init(value)
        } else {
            return Double.init(value.units) * Double.exp10(Double.init(value.power) + log)
        }
    }
}
extension DecimalLog{
    @inlinable public static func += (self: inout Self, change: Decimal) {
        guard let value: Double = self.value else {
            return
        }

        let factor: Decimal = 1 + change
        if  factor.units <= 0 {
            // We cannot take the logarithm of a non-positive number.
            self.value = nil
            return
        }

        self.value = .log10(Double.init(factor.units)) + Double.init(factor.power) + value
    }
}
