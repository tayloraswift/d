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
    /// Creates a `Decimal` instance from a ``Double``, rounding to the specified
    /// number of decimal places.
    ///
    /// - Parameters:
    ///   - value: The ``Double`` value to convert.
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

    /// Creates a `Decimal` from a ``Double``, rounding to the specified
    /// number of significant digits.
    @inlinable public init?(rounding value: Double, digits: Int) {
        // 1. Handle non-finite or zero values immediately
        guard value.isFinite else { return nil }
        if  value == 0 {
            self = .zero
            return
        }

        // 2. Calculate the order of magnitude (exponent)
        // e.g., for 123.45, log10 is ~2.09, floor is 2.
        let exponent: Int = .init(Double.log10(abs(value)).rounded(.down))

        // 3. Calculate required decimal places
        // digits = 3, exponent = 2 (100s place)
        // places = 3 - 1 - 2 = 0 decimal places -> rounds to 123
        let places: Int = digits - 1 - exponent

        // 4. Delegate to the existing initializer
        self.init(rounding: value, places: places)
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
extension Decimal: Comparable {
    @inlinable public static func < (a: Self, b: Self) -> Bool {
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
            let x: (Int64, UInt64) = a.units.multipliedFullWidth(by: Self.power(power.b))
            let y: (Int64, UInt64) = b.units.multipliedFullWidth(by: Self.power(power.a))
            return x < y
        } else {
            let a: Self = a.normalized()
            let b: Self = b.normalized()

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
extension Decimal {
    /// Creates a `Decimal` from a fraction, rounding to the nearest value
    /// with **halves rounding away from zero**.
    ///
    /// - `1.235` (s=3) -> `1.24`
    /// - `-1.235` (s=3) -> `-1.24`
    @inlinable public static func roundedToNearest(
        n: Int64,
        d: Int64,
        digits: Int
    ) -> Self? {
        .init(numerator: n, denominator: d, digits: digits, rounding: .nearest)
    }
    /// Creates a `Decimal` from a fractional representation, rounded to a
    /// specified number of significant digits.
    ///
    /// - Parameters:
    ///   - numerator: The numerator of the fraction.
    ///   - denominator: The denominator of the fraction.
    ///   - significantDigits: The number of significant digits to preserve. Must be
    ///     greater than 0 and less than 19.
    ///   - rounding: The rounding rule to apply.
    /// - Returns: A `Decimal` instance, or `nil` if the denominator is zero or
    ///   `significantDigits` is not in the valid range.
    @inlinable public init?(
        numerator: Int64,
        denominator: Int64,
        digits: Int,
        rounding: DecimalRoundingMode
    ) {
        // 1. Validate inputs
        guard denominator != 0, (1...18).contains(digits) else {
            return nil
        }

        if numerator == 0 {
            self = .zero
            return
        }

        // 2. Handle signs and use UInt64 for math to safely handle Int64.min
        let isNegative: Bool = (numerator < 0) != (denominator < 0)

        let n: UInt64 = numerator == .min ?
            UInt64(bitPattern: Int64.max) + 1 : UInt64(abs(numerator))
        let d: UInt64 = denominator == .min ?
            UInt64(bitPattern: Int64.max) + 1 : UInt64(abs(denominator))

        // 3-6. Perform core calculation (non-inlined)
        guard let (unroundedUnits, remainder, powerOfFirstDigit) =
                Self.__calculateUnrounded(n: n, d: d, digits: digits)
        else {
            // Result was non-zero but too small to represent
            self = .zero
            return
        }

        // 7. Perform rounding (inlined)
        let roundingDigit: UInt64 = unroundedUnits % 10
        var truncatedUnits: UInt64 = unroundedUnits / 10 // This has `s` digits

        let needsIncrement: Bool
        switch rounding {
        case .toZero:
            needsIncrement = false
        case .awayFromZero:
            // Increment if any fractional part exists at all
            needsIncrement = (roundingDigit > 0 || remainder > 0)
        case .nearest:
            // Increment if at or above midpoint (5 or greater)
            needsIncrement = roundingDigit >= 5
        }

        if needsIncrement {
            truncatedUnits &+= 1
        }

        // 8. Finalize `units` and `power` (inlined)
        var finalUnits: Int64
        var finalPower: Int = powerOfFirstDigit - (digits - 1)

        // Check for rounding overflow (e.g., 9.99 (s=2) rounds to 10.0)
        let powerOfTen: Int64 = Self.power(Int64(digits))

        if truncatedUnits == powerOfTen {
            finalUnits = Int64(truncatedUnits / 10)
            finalPower += 1
        } else {
            finalUnits = Int64(truncatedUnits)
        }

        self.init(
            units: isNegative ? -finalUnits : finalUnits,
            power: Int64(finalPower)
        )
    }
    /// Performs the rounding-independent, non-inlinable core logic for
    /// fractional initialization.
    ///
    /// This function performs the long-division to gather `digits + 1`
    /// significant digits.
    ///
    /// - Returns: A tuple containing the raw components for rounding, or `nil`
    ///   if the result is too small to represent.
    @usableFromInline static func __calculateUnrounded(
        n: UInt64,
        d: UInt64,
        digits: Int
    ) -> (units: UInt64, remainder: UInt64, powerOfFirstDigit: Int)? {
        // 3. Find power of first significant digit
        var q: UInt64 = n / d
        var r: UInt64 = n % d

        let powerOfFirstDigit: Int
        var units: UInt64 // We will build `s + 1` digits here
        var digitsGathered: Int

        if q > 0 {
            // Case A: Result is >= 1
            var power: Int = 0
            var tempQ: UInt64 = q
            while tempQ >= 10 {
                tempQ /= 10
                power += 1
            }
            powerOfFirstDigit = power
            units = q
            digitsGathered = power + 1
        } else {
            // Case B: Result is < 1. Find first non-zero digit.
            var power: Int = -1
            let overflowGuard: UInt64 = UInt64.max / 10

            while r <= overflowGuard {
                r &*= 10
                q = r / d
                if q > 0 {
                    // Found the first digit
                    break
                }
                // Digit was 0, so decrement power and continue
                power &-= 1
            }
            r = r % d

            guard q > 0 else {
                // Result is too small (e.g., 1 / 10^50), effectively zero
                return nil
            }

            powerOfFirstDigit = power
            units = q
            digitsGathered = 1
        }

        // 4. Gather remaining digits (we need `digits + 1` total)
        let targetDigits: Int = digits + 1
        let overflowGuard: UInt64 = UInt64.max / 10

        // Truncate if we already have more digits than needed (from Case A)
        if digitsGathered > targetDigits {
            let digitsToStrip: Int = digitsGathered - targetDigits
            // This will not overflow Int64 since digitsToStrip is at most 18
            let divisor: UInt64 = UInt64(Self.power(Int64(digitsToStrip)))
            let (newQ, newR): (UInt64, UInt64) = units.quotientAndRemainder(dividingBy: divisor)

            units = newQ
            digitsGathered = targetDigits
            // The new remainder is `newR`. The original remainder `r` was from
            // `n % d`. If `newR` is non-zero, it means we have a remainder.
            // If `newR` is zero, we rely on the original `r`.
            // The `init` logic only needs to know if `remainder > 0`.
            r = newR > 0 ? newR : r
        }

        while digitsGathered < targetDigits && units <= overflowGuard {
            r &*= 10
            units = (units &* 10) &+ (r / d)
            r = r % d
            digitsGathered &+= 1
        }

        // 5. Pad with zeros if exact value has fewer digits (e.g., 1/4, s=3 -> "250")
        while digitsGathered < targetDigits && units <= overflowGuard {
            units &*= 10
            digitsGathered &+= 1
        }

        return (units, r, powerOfFirstDigit)
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
    @inlinable public var fraction: (numerator: Int64, denominator: Int64?) {
        if self.units == 0 {
            return (0, nil)
        } else if self.power >= 0 {
            return (self.units * Self.power(self.power), nil)
        } else {
            return (self.units, Self.power(-self.power))
        }
    }

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
        stride: Int? = nil,
        places: Int? = nil,
        signed: Bool = false,
        suffix: String = ""
    ) -> String {
        let shifted: Self = .init(units: self.units, power: self.power + Int64.init(power))
        return shifted.format(
            stride: stride,
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
            stride: nil,
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

        guard let units: Int64 = .init(string) else {
            return nil
        }

        self.init(units: units, power: power)
    }
}
extension Decimal {
    public func format(stride: Int? = nil, places: Int, signed: Bool = false, suffix: String = "") -> String {
        self.format(stride: stride, places: places, signed: signed, suffix: suffix, ascii: false)
    }

    private func format(stride: Int?, places: Int, signed: Bool, suffix: String, ascii: Bool) -> String {
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

        let digitsInFirstGroup: Int
        let digitsToGroup: Int
        let commas: Int

        if  zeroes.before > 0 {
            digitsToGroup = 1 // The leading '0' in "0.xxxxx"
        } else {
            digitsToGroup = digits + zeroes.after - places
        }

        if  let stride: Int = stride, 1 ..< digitsToGroup ~= stride {
            let r: Int
            (commas, r) = (digitsToGroup - 1).quotientAndRemainder(dividingBy: stride)
            digitsInFirstGroup = r + 1
        } else {
            commas = 0
            digitsInFirstGroup = digitsToGroup
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

        let characters: Int = punctuation + zeroes.before + digits + zeroes.after + commas
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

            var digitsGrouped: Int = 0
            var digitsInCurrentGroup: Int = digitsInFirstGroup

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
                for utf8: UInt8 in string.utf8 {
                    $0[i] = utf8 ; i += 1
                    digitsGrouped += 1

                    if  digitsGrouped < digitsToGroup {
                        digitsInCurrentGroup -= 1
                        if  let stride: Int, digitsInCurrentGroup == 0 {
                            $0[i] = 0x2C ; i += 1 // ','
                            digitsInCurrentGroup = stride
                        }
                    } else if places > 0,
                        digitsGrouped == digitsToGroup {
                        $0[i] = 0x2E ; i += 1 // '.'
                    }
                }
                for _: Int in 0 ..< zeroes.after {
                    $0[i] = 0x30 ; i += 1
                }
            } else {
                // Decimal point appears at the end or beyond the digits.
                for utf8: UInt8 in string.utf8 {
                    $0[i] = utf8 ; i += 1
                    digitsGrouped += 1
                    if  digitsGrouped < digitsToGroup {
                        digitsInCurrentGroup -= 1
                        if  let stride: Int, digitsInCurrentGroup == 0 {
                            $0[i] = 0x2C ; i += 1 // ','
                            digitsInCurrentGroup = stride
                        }
                    }
                }
                for _: Int in 0 ..< zeroes.after - places {
                    $0[i] = 0x30 ; i += 1
                    digitsGrouped += 1
                    if  digitsGrouped < digitsToGroup {
                        digitsInCurrentGroup -= 1
                        if  let stride: Int, digitsInCurrentGroup == 0 {
                            $0[i] = 0x2C ; i += 1 // ','
                            digitsInCurrentGroup = stride
                        }
                    }
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
