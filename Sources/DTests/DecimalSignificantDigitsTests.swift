import D
import Testing

@Suite struct DecimalSignificantDigitsTests {
    typealias Case = (
        value: Double,
        digits: Int,
        expected: Decimal?
    )

    @Test(
        arguments: [
            // Standard rounding (3 significant digits)
            (value: 123.45, digits: 3, expected: .init(units: 123, power: 0)),
            // Rounding up
            (value: 123.9, digits: 3, expected: .init(units: 124, power: 0)),
            // Rounding decimals
            (value: 0.012345, digits: 3, expected: .init(units: 123, power: -4)),
            // Rounding large numbers
            (value: 12345.0, digits: 3, expected: .init(units: 123, power: 2)),

            // 1 significant digit
            (value: 0.005, digits: 1, expected: .init(units: 5, power: -3)),
            (value: 500.0, digits: 1, expected: .init(units: 5, power: 2)),

            // Negative numbers
            (value: -123.45, digits: 3, expected: .init(units: -123, power: 0)),
            (value: -0.012345, digits: 3, expected: .init(units: -123, power: -4)),

            // Zero handling
            (value: 0.0, digits: 3, expected: .zero),
            (value: -0.0, digits: 3, expected: .zero),

            // Edge cases
            (value: 1.0, digits: 5, expected: .init(units: 10000, power: -4)),
            (value: 99.99, digits: 2, expected: .init(units: 10, power: 1)), // Rounds to 100
        ] as [Case]
    ) func Initialization(test: Case) {
        #expect(test.expected == Decimal.init(rounding: test.value, digits: test.digits))
    }

    @Test func InvalidInputs() {
        // Test infinite values
        #expect(nil == Decimal.init(rounding: .infinity, digits: 3))
        #expect(nil == Decimal.init(rounding: -.infinity, digits: 3))
        #expect(nil == Decimal.init(rounding: .nan, digits: 3))
    }
}
