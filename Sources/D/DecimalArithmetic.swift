@usableFromInline protocol DecimalArithmetic {
    associatedtype Units: FixedWidthInteger & ExpressibleByIntegerLiteral
        where Units.Magnitude == UInt64
    var units: Units { get }
    var power: Int64 { get }
    var sign: Bool? { get }
}
extension DecimalArithmetic {
    @inline(always) @inlinable static func normalize(
        units: inout Units,
        power: inout Int64
    ) {
        if  units == 0 {
            power = 0
            return
        }

        while case (let q, remainder: 0) = units.quotientAndRemainder(dividingBy: 10) {
            units = q
            power += 1
        }
    }
}
extension DecimalArithmetic {
    @inline(always) @inlinable static subscript(power power: Int64) -> Units {
        switch power {
        case 00: 1
        case 01: 10
        case 02: 100
        case 03: 1000
        case 04: 10000
        case 05: 100000
        case 06: 1000000
        case 07: 10000000
        case 08: 100000000
        case 09: 1000000000
        case 10: 10000000000
        case 11: 100000000000
        case 12: 1000000000000
        case 13: 10000000000000
        case 14: 100000000000000
        case 15: 1000000000000000
        case 16: 10000000000000000
        case 17: 100000000000000000
        case 18: 1000000000000000000
        default: fatalError("Decimal power \(power) is not representable!")
        }
    }

    /// Scale both decimals to a common power for addition or subtraction. The returned power
    /// is the smaller of the two original powers.
    @inline(always) @inlinable static func || (
        a: Self,
        b: Self
    ) -> ((Units, Units), power: Int64) {
        if a.power == b.power {
            ((a.units, b.units), a.power)
        } else if a.power < b.power {
            ((a.units, b.units * self[power: b.power - a.power]), a.power)
        } else {
            ((a.units * self[power: a.power - b.power], b.units), b.power)
        }
    }

    @inline(always) @inlinable static func equals(_ a: Self, _ b: Self) -> Bool {
        if a.power == b.power {
            return a.units == b.units
        }
        // To compare a and b, we treat them as fractions:
        // a.units * 10^(+a.power) == b.units * 10^(+b.power)
        // a.units / 10^(-a.power) == b.units / 10^(-b.power)
        //
        // By cross-multiplication, this is equivalent to:
        // a.units * 10^(-b.power) == b.units * 10^(-a.power)
        //
        // To get the most out of this property, we want to scale both powers such that they are
        // small but non-negative.
        let offset: Int64 = max(a.power, b.power)
        // Intuitively, after this transformation, one of the powers will be zero, and the other
        // will be a non-negative integer. This optimizes our chances of getting two powers in
        // the range of 0 through 18.
        let power: (a: Int64, b: Int64) = (offset - a.power, offset - b.power)

        // The power(_:) function is only defined for exponents up to 18.
        // If either power is outside this range, we fall back to normalization.
        if power.a <= 18, power.b <= 18 {
            let x: (Units, UInt64) = a.units.multipliedFullWidth(by: self[power: power.b])
            let y: (Units, UInt64) = b.units.multipliedFullWidth(by: self[power: power.a])
            return x == y
        } else {
            var a: (units: Units, power: Int64) = (a.units, a.power)
            var b: (units: Units, power: Int64) = (b.units, b.power)

            self.normalize(units: &a.units, power: &a.power)
            self.normalize(units: &b.units, power: &b.power)

            return a == b
        }
    }

    @inline(always) @inlinable public static func less(_ a: Self, _ b: Self) -> Bool {
        let positive: Bool

        switch (a.sign, b.sign) {
        case (nil, nil):
            // both are zero
            return false

        case (nil, let b?):
            // if `a` is zero then `a < b` if and only if `b` is positive
            return b

        case (let a?, let b):
            if case a? = b {
                // both have the same sign
                positive = a
                break
            }

            // if `a` is positive then `b` must be zero or negative, so `a < b` is false.
            // if `a` is negative then `b` must be zero or positive, so `a < b` is true.
            return !a
        }

        // if powers are identical, just compare units
        if  a.power == b.power {
            return a.units < b.units
        }

        let offset: Int64 = max(a.power, b.power)
        let power: (a: Int64, b: Int64) = (offset - a.power, offset - b.power)
        if  power.a <= 18, power.b <= 18 {
            let x: (Units, UInt64) = a.units.multipliedFullWidth(by: self[power: power.b])
            let y: (Units, UInt64) = b.units.multipliedFullWidth(by: self[power: power.a])
            return x < y
        } else {
            var a: (units: Units, power: Int64) = (a.units, a.power)
            var b: (units: Units, power: Int64) = (b.units, b.power)

            self.normalize(units: &a.units, power: &a.power)
            self.normalize(units: &b.units, power: &b.power)

            if  a.power == b.power {
                return a.units < b.units
            }

            // if powers are still different, the magnitudes are different
            // (we already know the signs are the same)
            if  positive {
                // a smaller (more negative) power means a smaller number
                return a.power < b.power
            } else {
                // a larger (less negative) power means a smaller number
                // e.g., -1e-2 (power -2) is LESS than -1e-5 (power -5)
                return a.power > b.power
            }
        }
    }
}
