import RealModule

extension Double {
    @inlinable public init(_ decimal: Decimal) {
        // This is not very numerically stable, unfortunately. We should be using `scalbn`, but
        // that is not available in Swift WebAssembly.
        self = Double.init(decimal.units) * Double.exp10(Double.init(decimal.power))
    }
}
extension Double: DecimalFormattable {
    @inlinable public var zero: Bool { self == 0 }
    @inlinable public var sign: Bool? { self.zero ? nil : 0 < self }

    @inlinable public func delta(to next: Double) -> (sign: Bool?, magnitude: Double) {
        if self == next {
            (nil, 0)
        } else if self < next {
            (true, next - self)
        } else {
            (false, self - next)
        }
    }

    public func format(power: Int, places: Int?, signed: Bool, suffix: String = "") -> String {
        guard
        let places: Int,
        let decimal: Decimal = .init(rounding: self, places: power + places) else {
            let value: Double = self * .pow(10.0, Double(power))
            if  signed, value > 0 {
                return "+\(value)\(suffix)"
            } else if value < 0 {
                return "\u{2212}\(-value)\(suffix)"
            } else {
                return "0\(suffix)"
            }
        }

        if  signed, decimal.units == 0,
            let sign: Bool = self.sign {
            // special case to ensure sign is shown for zero when requested
            return places > 0 ? """
            \(sign ? "+" : "\u{2212}")0.\(String.init(repeating: "0", count: places))\(suffix)
            """ : """
            \(sign ? "+" : "\u{2212}")0\(suffix)
            """
        } else {
            return decimal.format(power: power, places: places, signed: signed, suffix: suffix)
        }
    }
}
