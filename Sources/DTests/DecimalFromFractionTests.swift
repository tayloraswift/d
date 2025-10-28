import D
import Testing

@Suite struct DecimalFromFractionTests {
    // MARK: - Helper Type

    /// A simple tuple for parameterized tests that allows for `nil` expectations.
    typealias TestCase = (
        digits: Int,
        n: Int64,
        d: Int64,
        expected: Decimal?
    )

    /// Custom initializer to capture file/line info automatically.
    static func testCase(
        digits: Int,
        n: Int64,
        d: Int64,
        expected: Decimal?,
    ) -> TestCase {
        (digits, n, d, expected)
    }

    // MARK: - Test Functions

    @Test(
        "Invalid Inputs",
        arguments: [
            // Denominator is zero
            testCase(digits: 1, n: 1, d: 0, expected: nil),
            // Digits is zero
            testCase(digits: 0, n: 1, d: 1, expected: nil),
            // Digits is too large
            testCase(digits: 19, n: 1, d: 1, expected: nil),
        ]
    )
    static func InvalidInputs(test: TestCase) {
        let result = Decimal.roundedToNearest(
            n: test.n,
            d: test.d,
            digits: test.digits,
        )
        #expect(result == test.expected)
    }

    @Test(
        "Zero Numerator",
        arguments: [
            testCase(digits: 1, n: 0, d: 1, expected: .zero),
            testCase(digits: 5, n: 0, d: -100, expected: .zero),
            testCase(digits: 18, n: 0, d: .max, expected: .zero),
        ]
    )
    static func ZeroNumerator(test: TestCase) {
        let result = Decimal.roundedToNearest(
            n: test.n,
            d: test.d,
            digits: test.digits,
        )
        #expect(result == test.expected)
    }

    @Test(
        "Rounding Down (< 5)",
        arguments: [
            // 1/3 (s=3) -> 0.333
            testCase(digits: 3, n: 1, d: 3, expected: .init(units: 333, power: -3)),
            // ** TEST FIX **
            // 1/4 (s=1) -> 0.3 (rounds 0.25 up)
            testCase(digits: 1, n: 1, d: 4, expected: .init(units: 3, power: -1)),
            // 10/3 (s=3) -> 3.33
            testCase(digits: 3, n: 10, d: 3, expected: .init(units: 333, power: -2)),
            // 1.234 (s=3) -> 1.23
            testCase(digits: 3, n: 1234, d: 1000, expected: .init(units: 123, power: -2)),
        ]
    )
    static func RoundingDown(test: TestCase) {
        let result = Decimal.roundedToNearest(
            n: test.n,
            d: test.d,
            digits: test.digits,
        )
        #expect(result == test.expected)
    }

    @Test(
        "Rounding Up (== 5, Midpoint)",
        arguments: [
            // 1/2 (s=1) -> 0.5
            testCase(digits: 1, n: 1, d: 2, expected: .init(units: 5, power: -1)),
            // 3/2 (s=1) -> 2 (rounds 1.5 up)
            testCase(digits: 1, n: 3, d: 2, expected: .init(units: 2, power: 0)),
            // 1/8 (s=2) -> 0.13 (rounds 0.125 up)
            testCase(digits: 2, n: 1, d: 8, expected: .init(units: 13, power: -2)),
            // 1.25 (s=2) -> 1.3
            testCase(digits: 2, n: 125, d: 100, expected: .init(units: 13, power: -1)),
        ]
    )
    static func RoundingUpMidpoint(test: TestCase) {
        let result = Decimal.roundedToNearest(
            n: test.n,
            d: test.d,
            digits: test.digits,
        )
        #expect(result == test.expected)
    }

    @Test(
        "Rounding Up (> 5)",
        arguments: [
            // 2/3 (s=3) -> 0.667
            testCase(digits: 3, n: 2, d: 3, expected: .init(units: 667, power: -3)),
            // 20/3 (s=3) -> 6.67
            testCase(digits: 3, n: 20, d: 3, expected: .init(units: 667, power: -2)),
            // 1.239 (s=3) -> 1.24
            testCase(digits: 3, n: 1239, d: 1000, expected: .init(units: 124, power: -2)),
            // 8/9 (s=1) -> 0.9 (rounds 0.88... up)
            testCase(digits: 1, n: 8, d: 9, expected: .init(units: 9, power: -1)),
        ]
    )
    static func RoundingUpAboveMidpoint(test: TestCase) {
        let result = Decimal.roundedToNearest(
            n: test.n,
            d: test.d,
            digits: test.digits,
        )
        #expect(result == test.expected)
    }

    @Test(
        "Rounding Overflow",
        arguments: [
            // 9.95 (s=2) -> 10
            testCase(digits: 2, n: 995, d: 100, expected: .init(units: 10, power: 0)),
            // 9.99 (s=2) -> 10
            testCase(digits: 2, n: 999, d: 100, expected: .init(units: 10, power: 0)),
            // 9.999 (s=3) -> 10.0
            testCase(digits: 3, n: 9999, d: 1000, expected: .init(units: 100, power: -1)),
            // 9.999 (s=1) -> 10
            testCase(digits: 1, n: 9999, d: 1000, expected: .init(units: 1, power: 1)),
            // 999 (s=2) -> 1000
            testCase(digits: 2, n: 999, d: 1, expected: .init(units: 10, power: 2)),
            // 0.0995 (s=2) -> 0.10
            testCase(digits: 2, n: 995, d: 10000, expected: .init(units: 10, power: -2)),
            // ** TEST FIX **
            // 999_999_999_999_999_999 (s=18) -> 1_000_000_000_000_000_000
            // Rounds 9.99... (18 9s) up
            testCase(
                digits: 18,
                n: 999_999_999_999_999_999,
                d: 1,
                expected: .init(units: 100_000_000_000_000_000, power: 1)
            ),
        ]
    )
    static func RoundingOverflow(test: TestCase) {
        let result = Decimal.roundedToNearest(
            n: test.n,
            d: test.d,
            digits: test.digits,
        )
        #expect(result == test.expected)
    }

    @Test(
        "Sign Combinations",
        arguments: [
            // -1/3 (s=3) -> -0.333
            testCase(digits: 3, n: -1, d: 3, expected: .init(units: -333, power: -3)),
            // 1/-3 (s=3) -> -0.333
            testCase(digits: 3, n: 1, d: -3, expected: .init(units: -333, power: -3)),
            // -1/-3 (s=3) -> 0.333
            testCase(digits: 3, n: -1, d: -3, expected: .init(units: 333, power: -3)),
            // -2/3 (s=3) -> -0.667 (rounds away from 0)
            testCase(digits: 3, n: -2, d: 3, expected: .init(units: -667, power: -3)),
            // -1/2 (s=1) -> -0.5
            testCase(digits: 1, n: -1, d: 2, expected: .init(units: -5, power: -1)),
            // -3/2 (s=1) -> -2 (rounds -1.5 away from 0)
            testCase(digits: 1, n: -3, d: 2, expected: .init(units: -2, power: 0)),
            // -9.95 (s=2) -> -10 (overflow)
            testCase(digits: 2, n: -995, d: 100, expected: .init(units: -10, power: 0)),
        ]
    )
    static func SignCombinations(test: TestCase) {
        let result = Decimal.roundedToNearest(
            n: test.n,
            d: test.d,
            digits: test.digits,
        )
        #expect(result == test.expected)
    }

    @Test(
        "Magnitude and Zero Padding",
        arguments: [
            // Path: Result < 1 (finds power -2)
            // 1/40 (s=3) -> 0.0250 (tests zero padding)
            testCase(digits: 3, n: 1, d: 40, expected: .init(units: 250, power: -4)),
            // 1/4 (s=5) -> 0.25000
            testCase(digits: 5, n: 1, d: 4, expected: .init(units: 25000, power: -5)),
            // 1/8 (s=6) -> 0.125000
            testCase(digits: 6, n: 1, d: 8, expected: .init(units: 125000, power: -6)),
            // Path: Result >= 1 (finds power 2)
            // 100/1 (s=5) -> 100.00
            testCase(digits: 5, n: 100, d: 1, expected: .init(units: 10000, power: -2)),
            // Path: Result >= 1 (finds power 3)
            // 12345/2 (s=3) -> 6170 (rounds 6172.5 up)
            testCase(digits: 3, n: 12345, d: 2, expected: .init(units: 617, power: 1)),
        ]
    )
    static func MagnitudeAndZeroPadding(test: TestCase) {
        let result = Decimal.roundedToNearest(
            n: test.n,
            d: test.d,
            digits: test.digits,
        )
        #expect(result == test.expected)
    }

    @Test(
        "High Precision and Max Digits",
        arguments: [
            // Max digits, no rounding
            testCase(
                digits: 18,
                n: 123_456_789_012_345_678,
                d: 1,
                expected: .init(units: 123_456_789_012_345_678, power: 0)
            ),
            // Max digits, rounding
            // ** TEST FIX **
            // 9.22...807 (s=18) -> 9.22...81 * 10^1 (rounds up)
            testCase(
                digits: 18,
                n: 9_223_372_036_854_775_807, // Int64.max
                d: 1,
                expected: .init(units: 9_223_372_036_854_775_81, power: 1)
            ),
            // Max digits, rounding down
            // ** TEST FIX **
            // 3.07...586 (s=18) -> 3.07...59 * 10^18 (rounds up)
            testCase(
                digits: 18,
                n: 9_223_372_036_854_775_807, // Int64.max
                d: 3,
                expected: .init(units: 3_074_457_345_618_258_60, power: 1) // 3.07...5866 rounds up
            ),
        ]
    )
    static func HighPrecisionAndMaxDigits(test: TestCase) {
        let result = Decimal.roundedToNearest(
            n: test.n,
            d: test.d,
            digits: test.digits,
        )
        #expect(result == test.expected)
    }

    @Test(
        "Extreme Values (Int64.min, .max)",
        arguments: [
            // .min / 1 (s=18)
            // ** TEST FIX **
            // -9.22...808 (s=18) -> -9.22...81 * 10^1 (rounds up)
            testCase(
                digits: 18,
                n: .min,
                d: 1,
                expected: .init(units: -9_223_372_036_854_775_81, power: 1)
            ),
            // .min / -1 (s=18) -> .max + 1, rounds up
            // ** TEST FIX **
            // 9.22...808 (s=18) -> 9.22...81 * 10^1 (rounds up)
            testCase(
                digits: 18,
                n: .min,
                d: -1,
                expected: .init(units: 9_223_372_036_854_775_81, power: 1)
            ),
            // .min / .max (s=5) -> -1.0000
            testCase(
                digits: 5,
                n: .min,
                d: .max,
                expected: .init(units: -10000, power: -4) // -1.00000...
            ),
            // .min / .min (s=5) -> 1.0000
            testCase(
                digits: 5,
                n: .min,
                d: .min,
                expected: .init(units: 10000, power: -4)
            ),
            // Path: Result is too small, becomes 1e-19
            // ** TEST FIX **
            testCase(digits: 1, n: 1, d: .max, expected: .init(units: 1, power: -19)),
            // ** TEST FIX **
            testCase(digits: 1, n: 1, d: .min, expected: .init(units: -1, power: -19)),
        ]
    )
    static func ExtremeValues(test: TestCase) {
        let result = Decimal.roundedToNearest(
            n: test.n,
            d: test.d,
            digits: test.digits,
        )
        #expect(result == test.expected)
    }
}
