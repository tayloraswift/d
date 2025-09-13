import RealModule

@frozen public struct Decimal: Sendable {
    public var units: Int64
    public var power: Int64

    @inlinable public init(units: Int64, power: Int64) {
        self.units = units
        self.power = power
    }
}

extension Decimal {
    /// Creates a `Decimal` instance from a `Double`, rounding to the specified
    /// number of decimal places.
    ///
    /// - Parameters:
    ///   - value: The `Double` value to convert.
    ///   - places: The number of decimal places to preserve. The value will be
    ///     rounded to this number of places.
    @inlinable public init?(rounding value: Double, places: Int) {
        if  let units: Int64 = .init(exactly: (value * .exp10(Double.init(places))).rounded()) {
            self.init(
                units: units,
                power: -Int64.init(places)
            )
        } else {
            return nil
        }
    }
}

extension Decimal {
    /// Normalizes the decimal by removing trailing zeros from the units.
    @inlinable public mutating func normalize() {
        if  self.units == 0 {
            self.power = 0
            return
        }

        while case (let q, remainder: 0) = self.units.quotientAndRemainder(dividingBy: 10) {
            self.units = q
            self.power += 1
        }
    }

    /// Returns a normalized copy of the decimal.
    @inlinable public consuming func normalized() -> Self {
        self.normalize()
        return self
    }
}

extension Decimal: Equatable {
    @inlinable public static func == (a: Self, b: Self) -> Bool {
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
            let x: (Int64, UInt64) = a.units.multipliedFullWidth(by: Self.power(power.b))
            let y: (Int64, UInt64) = b.units.multipliedFullWidth(by: Self.power(power.a))
            return x == y
        } else {
            let a: Decimal = a.normalized()
            let b: Decimal = b.normalized()
            return (a.units, a.power) == (b.units, b.power)
        }
    }
}

extension Decimal: ExpressibleByIntegerLiteral {
    @inlinable public init(integerLiteral: Int64) {
        self.init(units: integerLiteral, power: 0)
    }
}

extension Decimal {
    @inlinable public prefix static func - (self: Self) -> Self {
        .init(units: -self.units, power: self.power)
    }
    @inlinable public prefix static func + (self: Self) -> Self {
        self
    }
}
extension Decimal {
    @inlinable public postfix static func % (self: Self) -> Self {
        .init(units: self.units, power: self.power - 2)
    }

    @inlinable public postfix static func ‰ (self: Self) -> Self {
        .init(units: self.units, power: self.power - 3)
    }

    @inlinable public postfix static func ‱ (self: Self) -> Self {
        .init(units: self.units, power: self.power - 4)
    }
}
extension Decimal {
    @inlinable static func power(_ exponent: Int64) -> Int64 {
        switch exponent {
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
        default: fatalError("Decimal power \(exponent) is not representable!")
        }
    }

    /// Scale both decimals to a common power for addition or subtraction. The returned power
    /// is the smaller of the two original powers.
    @inlinable static func || (a: Self, b: Self) -> ((Int64, Int64), power: Int64) {
        if a.power == b.power {
            ((a.units, b.units), a.power)
        } else if a.power < b.power {
            ((a.units, b.units * Self.power(b.power - a.power)), a.power)
        } else {
            ((a.units * Self.power(a.power - b.power), b.units), b.power)
        }
    }
}
extension Decimal: AdditiveArithmetic {
    @inlinable public static var zero: Self { .init(units: 0, power: 0) }

    @inlinable public static func + (a: Self, b: Self) -> Self {
        let ((a, b), power): ((Int64, Int64), Int64) = a || b
        return .init(units: a + b, power: power)
    }

    @inlinable public static func - (a: Self, b: Self) -> Self {
        let ((a, b), power): ((Int64, Int64), Int64) = a || b
        return .init(units: a - b, power: power)
    }
}
extension Decimal {
    @inlinable public static func += (self: inout Self, other: Self) {
        self = self + other
    }

    @inlinable public static func -= (self: inout Self, other: Self) {
        self = self - other
    }
}

extension Decimal: DecimalFormattable {
    @inlinable public var zero: Bool { self.units == 0 }
    @inlinable public var sign: Bool? { self.zero ? nil : 0 < self.units }

    @inlinable public func delta(to next: Self) -> (sign: Bool?, magnitude: Self) {
        let (units, power): ((Int64, Int64), Int64) = self || next
        if units.0 == units.1 {
            return (nil, .init(units: 0, power: power))
        } else if units.0 < units.1 {
            return (true, .init(units: units.1 - units.0, power: power))
        } else {
            return (false, .init(units: units.0 - units.1, power: power))
        }
    }

    @inlinable public func format(
        power: Int,
        places: Int? = nil,
        signed: Bool = false,
        suffix: String = ""
    ) -> String {
        let shifted: Self = .init(units: self.units, power: self.power + Int64.init(power))
        return shifted.format(
            places: places ?? -Int.init(min(shifted.power, 0)),
            signed: signed,
            suffix: suffix
        )
    }
}
extension Decimal: CustomStringConvertible {
    /// Format the decimal with as many places as necessary to represent the number exactly,
    /// using ASCII characters only. The string contains no leading plus sign.
    public var description: String {
        self.format(
            places: -Int.init(min(self.power, 0)),
            signed: false,
            suffix: "",
            ascii: true
        )
    }
}
extension Decimal: LosslessStringConvertible {
    @inlinable public init?(
        _ string: consuming some StringProtocol & RangeReplaceableCollection
    ) {
        let power: Int64
        if  let i: String.Index = string.firstIndex(of: ".") {
            power = -Int64.init(
                string.distance(from: string.index(after: i), to: string.endIndex)
            )
            string.remove(at: i)
        } else {
            power = 0
        }

        guard let units: Int64 = .init(string)
        else {
            return nil
        }

        self.init(units: units, power: power)
    }
}
extension Decimal {
    public func format(places: Int, signed: Bool = false, suffix: String = "") -> String {
        self.format(places: places, signed: signed, suffix: suffix, ascii: false)
    }

    private func format(places: Int, signed: Bool, suffix: String, ascii: Bool) -> String {
        /// We test this before we perform any rounding, to preserve the sign.
        let negative: Bool = self.units < 0
        let positive: Bool = self.units > 0

        let rounded: Self
        let zeroes: (before: Int, after: Int)
        let string: Substring
        let digits: Int

        if  self.power < 0 {
            let digitsInserted: Int64 = Int64.init(places) + self.power
            if  digitsInserted < 0 {
                /// In other words, we must remove some digits, by rounding.
                rounded = self.stripping(last: -digitsInserted)
                zeroes.after = 0
            } else {
                rounded = self
                zeroes.after = Int.init(digitsInserted)
            }

            string = rounded.digits
            digits = string.utf8.count

            /// Figure out how many digits the result will contain.
            /// We know the result must start with at least one digit before the decimal point,
            /// and have `places` more digits after it.
            let digitsExpected: Int = 1 + places - zeroes.after
            zeroes.before = max(0, digitsExpected - digits)
        } else {
            // Any decimal places we print will be purely zeroes.
            zeroes.before = 0
            rounded = self
            string = self.digits
            digits = string.utf8.count
            // Edge case: zero never gets any trailing padding digits, regardless of power.
            zeroes.after = self.units == 0 ? places : places + Int.init(self.power)
        }

        /// Add 1 for the decimal point. The unicode minus sign (U+2212) takes three bytes
        /// to encode in UTF-8.
        let punctuation: Int

        if  negative {
            if ascii {
                punctuation = places > 0 ? 2 : 1
            } else {
                punctuation = places > 0 ? 4 : 3
            }
        } else if signed, positive {
            punctuation = places > 0 ? 2 : 1
        } else {
            punctuation = places > 0 ? 1 : 0
        }

        let characters: Int = punctuation + zeroes.before + digits + zeroes.after
        return .init(unsafeUninitializedCapacity: characters + suffix.utf8.count) {
            var i: Int
            if negative {
                if ascii {
                    $0[0] = 0x2D // U+002D
                    i = 1
                } else {
                    $0[0] = 0xE2
                    $0[1] = 0x88
                    $0[2] = 0x92 // U+2212
                    i = 3
                }
            } else if signed, positive {
                $0[0] = 0x2B // '+'
                i = 1
            } else {
                i = 0
            }
            // We would only insert zeroes before, if if the decimal starts with `0.`
            if zeroes.before > 0 {
                $0[i] = 0x30 ; i += 1 // '0'
                $0[i] = 0x2E ; i += 1 // '.'
                for _: Int in 1 ..< zeroes.before {
                    $0[i] = 0x30 ; i += 1
                }
                for utf8: UInt8 in string.utf8 {
                    $0[i] = utf8 ; i += 1
                }
                for _: Int in 0 ..< zeroes.after {
                    $0[i] = 0x30 ; i += 1
                }
            } else if places > zeroes.after {
                // We know that the decimal point appears within the digits.
                let period: Int = characters - places - 1
                for utf8: UInt8 in string.utf8 {
                    if period == i {
                        $0[i] = 0x2E ; i += 1 // '.'
                    }

                    $0[i] = utf8 ; i += 1
                }
                for _: Int in 0 ..< zeroes.after {
                    $0[i] = 0x30 ; i += 1
                }
            } else {
                for utf8: UInt8 in string.utf8 {
                    $0[i] = utf8 ; i += 1
                }
                for _: Int in 0 ..< zeroes.after - places {
                    $0[i] = 0x30 ; i += 1
                }
                if places > 0 {
                    $0[i] = 0x2E ; i += 1 // '.'
                }
                for _: Int in 0 ..< places {
                    $0[i] = 0x30 ; i += 1
                }
            }

            assert(i == characters)

            for utf8: UInt8 in suffix.utf8 {
                $0[i] = utf8 ; i += 1
            }

            return i
        }
    }

    /// Remove the last `places` digits from the decimal. Half-increments will be rounded away
    /// from zero.
    /// -   Parameter places:
    ///     The number of digits to remove from the end of the decimal. Must be positive.
    private consuming func stripping(last places: Int64) -> Self {
        self.strip(last: places)
        return self
    }

    private mutating func strip(last places: Int64) {
        if places < 19 {
            let powerOfTen: Int64 = Self.power(places)
            let (q, r): (Int64, Int64) = self.units.quotientAndRemainder(
                dividingBy: powerOfTen
            )
            let half: Int64 = powerOfTen / 2
            if  half <= r {
                self.units = q + 1
            } else if r <= -half {
                self.units = q - 1
            } else {
                self.units = q
            }
        } else if places == 19 {
            let half: Int64 = 5000000000000000000
            if  half <= self.units {
                self.units = +1
            } else if self.units <= -half {
                self.units = -1
            } else {
                self.units = 0
            }
        } else {
            self.units = 0
        }

        self.power += places
    }

    private var digits: Substring {
        /// We don’t just `abs(_:)` this, because it will crash on `Int64.min`.
        if  self.units < 0 {
            let signed: String = "\(self.units)"
            return signed[signed.index(after: signed.startIndex)...]
        } else {
            return "\(self.units)"
        }
    }
}
