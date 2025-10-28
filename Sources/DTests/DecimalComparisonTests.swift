import Testing
import D

@Suite struct DecimalComparisonTests {
    @Test(
        arguments: [
            // 0 < 1
            (.init(units: 0, power: 0), .init(units: 1, power: 0)),
            // 0 < 0.001
            (.init(units: 0, power: 0), .init(units: 1, power: -3)),
            // -1 < 0
            (.init(units: -1, power: 0), .init(units: 0, power: 0)),
            // -0.001 < 0
            (.init(units: -1, power: -3), .init(units: 0, power: 0)),
            // -1 < 1
            (.init(units: -1, power: 0), .init(units: 1, power: 0)),
            // -100 < 0.01
            (.init(units: -100, power: 0), .init(units: 1, power: -2)),
            // -1e18 < 1e-18 (Approx)
            (.init(units: -1, power: 18), .init(units: 1, power: -18)),
            // -123.45 < 67.89
            (.init(units: -12345, power: -2), .init(units: 6789, power: -2)),
        ] as [(Decimal, Decimal)]
    ) func SignChecksExpectedTrue(_ a: Decimal, _ b: Decimal) throws {
        #expect(a < b)
    }

    @Test(
        arguments: [
            // !(0 < 0)
            (.init(units: 0, power: 0), .init(units: 0, power: 0)),
            // !(0 < -0.001)
            (.init(units: 0, power: 0), .init(units: -1, power: -3)),
            // !(0 < -1)
            (.init(units: 0, power: 0), .init(units: -1, power: 0)),
            // !(1 < 0)
            (.init(units: 1, power: 0), .init(units: 0, power: 0)),
            // !(0.001 < 0)
            (.init(units: 1, power: -3), .init(units: 0, power: 0)),
            // !(1 < -1)
            (.init(units: 1, power: 0), .init(units: -1, power: 0)),
            // !(0.01 < -100)
            (.init(units: 1, power: -2), .init(units: -100, power: 0)),
            // !(1e-18 < -1e18)
            (.init(units: 1, power: -18), .init(units: -1, power: 18)),
            // !(67.89 < -123.45)
            (.init(units: 6789, power: -2), .init(units: -12345, power: -2)),
        ] as [(Decimal, Decimal)]
    ) func SignChecksExpectedFalse(_ a: Decimal, _ b: Decimal) throws {
        #expect(!(a < b))
    }

    @Test(
        arguments: [
            // 1 < 2
            (.init(units: 1, power: 0), .init(units: 2, power: 0)),
            // 1.23 < 1.24
            (.init(units: 123, power: -2), .init(units: 124, power: -2)),
            // 100 < 200
            (.init(units: 1, power: 2), .init(units: 2, power: 2)),
            // -2 < -1
            (.init(units: -2, power: 0), .init(units: -1, power: 0)),
            // -1.24 < -1.23
            (.init(units: -124, power: -2), .init(units: -123, power: -2)),
            // -200 < -100
            (.init(units: -2, power: 2), .init(units: -1, power: 2)),
        ] as [(Decimal, Decimal)]
    ) func EqualPowerExpectedTrue(_ a: Decimal, _ b: Decimal) throws {
        #expect(a < b)
    }

    @Test(
        arguments: [
            // !(2 < 1)
            (.init(units: 2, power: 0), .init(units: 1, power: 0)),
            // !(1 < 1)
            (.init(units: 1, power: 0), .init(units: 1, power: 0)),
            // !(1.24 < 1.23)
            (.init(units: 124, power: -2), .init(units: 123, power: -2)),
            // !(1.23 < 1.23)
            (.init(units: 123, power: -2), .init(units: 123, power: -2)),
            // !(200 < 100)
            (.init(units: 2, power: 2), .init(units: 1, power: 2)),
            // !(100 < 100)
            (.init(units: 1, power: 2), .init(units: 1, power: 2)),
            // !(-1 < -2)
            (.init(units: -1, power: 0), .init(units: -2, power: 0)),
            // !(-1 < -1)
            (.init(units: -1, power: 0), .init(units: -1, power: 0)),
            // !(-1.23 < -1.24)
            (.init(units: -123, power: -2), .init(units: -124, power: -2)),
            // !(-1.23 < -1.23)
            (.init(units: -123, power: -2), .init(units: -123, power: -2)),
            // !(-100 < -200)
            (.init(units: -1, power: 2), .init(units: -2, power: 2)),
            // !(-100 < -100)
            (.init(units: -1, power: 2), .init(units: -1, power: 2)),
        ] as [(Decimal, Decimal)]
    ) func EqualPowerExpectedFalse(_ a: Decimal, _ b: Decimal) throws {
        #expect(!(a < b))
    }

    @Test(
        arguments: [
            // 1.23 < 1.234
            (.init(units: 123, power: -2), .init(units: 1234, power: -3)),
            // 10 < 10.1
            (.init(units: 10, power: 0), .init(units: 101, power: -1)),
            // 99... < 1e18 (Large units)
            (.init(units: 999_999_999_999_999_999, power: 0), .init(units: 1, power: 18)),
            // 1e-18 < 1.1e-18
            (.init(units: 1, power: -18), .init(units: 11, power: -19)),
            // 1 < 1.00...01 (-18)
            (.init(units: 1, power: 0), .init(units: 1_000_000_000_000_000_001, power: -18)),

            // -1.234 < -1.23
            (.init(units: -1234, power: -3), .init(units: -123, power: -2)),
            // -10.1 < -10
            (.init(units: -101, power: -1), .init(units: -10, power: 0)),
            // -1e18 < -99... (Large units)
            (.init(units: -1, power: 18), .init(units: -999_999_999_999_999_999, power: 0)),
            // -1.1e-18 < -1e-18
            (.init(units: -11, power: -19), .init(units: -1, power: -18)),
            // -1.00...01 < -1 (-18)
            (.init(units: -1_000_000_000_000_000_001, power: -18), .init(units: -1, power: 0)),
        ] as [(Decimal, Decimal)]
    ) func DifferentPower128BitExpectedTrue(_ a: Decimal, _ b: Decimal) throws {
        #expect(a < b)
    }

    @Test(
        arguments: [
            // !(1.234 < 1.23)
            (.init(units: 1234, power: -3), .init(units: 123, power: -2)),
            // !(1.23 < 1.230) - Equivalent
            (.init(units: 123, power: -2), .init(units: 1230, power: -3)),
            // !(10.1 < 10)
            (.init(units: 101, power: -1), .init(units: 10, power: 0)),
            // !(10 < 10.0) - Equivalent
            (.init(units: 10, power: 0), .init(units: 100, power: -1)),
            // !(1e18 < 99...)
            (.init(units: 1, power: 18), .init(units: 999_999_999_999_999_999, power: 0)),
            // !(1.1e-18 < 1e-18)
            (.init(units: 11, power: -19), .init(units: 1, power: -18)),
            // !(1.00...01 < 1) (-18)
            (.init(units: 1_000_000_000_000_000_001, power: -18), .init(units: 1, power: 0)),

            // !(-1.23 < -1.234)
            (.init(units: -123, power: -2), .init(units: -1234, power: -3)),
            // !(-1.230 < -1.23) - Equivalent
            (.init(units: -1230, power: -3), .init(units: -123, power: -2)),
            // !(-10 < -10.1)
            (.init(units: -10, power: 0), .init(units: -101, power: -1)),
            // !(-10.0 < -10) - Equivalent
            (.init(units: -100, power: -1), .init(units: -10, power: 0)),
            // !(-99... < -1e18)
            (.init(units: -999_999_999_999_999_999, power: 0), .init(units: -1, power: 18)),
            // !(-1e-18 < -1.1e-18)
            (.init(units: -1, power: -18), .init(units: -11, power: -19)),
            // !(-1 < -1.00...01) (-18)
            (.init(units: -1, power: 0), .init(units: -1_000_000_000_000_000_001, power: -18)),
        ] as [(Decimal, Decimal)]
    ) func DifferentPower128BitExpectedFalse(_ a: Decimal, _ b: Decimal) throws {
        #expect(!(a < b))
    }

    @Test(
        arguments: [
            // 1e-20 < 1e-1 (Power diff > 18)
            (.init(units: 1, power: -20), .init(units: 1, power: -1)),
            // 1 < 1e20 (Power diff > 18)
            (.init(units: 1, power: 0), .init(units: 1, power: 20)),
            // 1.23e-20 < 1.24e-20 (Normalized powers equal)
            (.init(units: 123, power: -20), .init(units: 124, power: -20)),
            // 1e-50 < 1e-40 (Final magnitude check)
            (.init(units: 1, power: -50), .init(units: 1, power: -40)),
            (.init(units: 1230_000_000_000_000_000, power: -21), .init(units: 124, power: -5)),
            (.init(units: 1230_000_000_000_000_000, power: -21), .init(units: 123, power: -4)),

            // -1e-1 < -1e-20 (Power diff > 18)
            (.init(units: -1, power: -1), .init(units: -1, power: -20)),
            // -1e20 < -1 (Power diff > 18)
            (.init(units: -1, power: 20), .init(units: -1, power: 0)),
            // -1.24e-20 < -1.23e-20 (Normalized powers equal)
            (.init(units: -124, power: -20), .init(units: -123, power: -20)),
            // -1e-40 < -1e-50 (Final magnitude check)
            (.init(units: -1, power: -40), .init(units: -1, power: -50)),
            (
                .init(units: -1230_000_000_000_000_000, power: -21),
                .init(units: -122, power: -5)
            ),
            (
                .init(units: -1230_000_000_000_000_000, power: -21),
                .init(units: -123, power: -6)
            ),
        ] as [(Decimal, Decimal)]
    ) func NormalizationFallbackExpectedLess(_ a: Decimal, _ b: Decimal) throws {
        #expect(a < b)
    }

    @Test(
        arguments: [
            // !(1e-1 < 1e-20)
            (.init(units: 1, power: -1), .init(units: 1, power: -20)),
            // !(1e20 < 1)
            (.init(units: 1, power: 20), .init(units: 1, power: 0)),
            // !(1.24e-20 < 1.23e-20)
            (.init(units: 124, power: -20), .init(units: 123, power: -20)),
            // !(1e-40 < 1e-50)
            (.init(units: 1, power: -40), .init(units: 1, power: -50)),
            (.init(units: 1230_000_000_000_000_000, power: -21), .init(units: 122, power: -5)),
            (.init(units: 1230_000_000_000_000_000, power: -21), .init(units: 123, power: -6)),

            // !(-1e-20 < -1e-1)
            (.init(units: -1, power: -20), .init(units: -1, power: -1)),
            // !(-1 < -1e20)
            (.init(units: -1, power: 0), .init(units: -1, power: 20)),
            // !(-1.23e-20 < -1.24e-20)
            (.init(units: -123, power: -20), .init(units: -124, power: -20)),
            // !(-1e-50 < -1e-40)
            (.init(units: -1, power: -50), .init(units: -1, power: -40)),
            (
                .init(units: -1230_000_000_000_000_000, power: -21),
                .init(units: -124, power: -5)
            ),
            (
                .init(units: -1230_000_000_000_000_000, power: -21),
                .init(units: -123, power: -4)
            ),
        ] as [(Decimal, Decimal)]
    ) func NormalizationFallbackExpectedGreater(_ a: Decimal, _ b: Decimal) throws {
        #expect(a > b)
    }

    @Test(
        arguments: [
            // 2 > 1
            (.init(units: 2, power: 0), .init(units: 1, power: 0)),
            // 1 > -1
            (.init(units: 1, power: 0), .init(units: -1, power: 0)),
            // 0 > -1
            (.init(units: 0, power: 0), .init(units: -1, power: 0)),
            // 1.234 > 1.23
            (.init(units: 1234, power: -3), .init(units: 123, power: -2)),
            // -1.23 > -1.234
            (.init(units: -123, power: -2), .init(units: -1234, power: -3)),
            // 1e20 > 1e-20
            (.init(units: 1, power: 20), .init(units: 1, power: -20)),
            // -1e-20 > -1e20
            (.init(units: -1, power: -20), .init(units: -1, power: 20)),
        ] as [(Decimal, Decimal)]
    ) func GreaterThan(_ a: Decimal, _ b: Decimal) throws {
        #expect(a > b)
        #expect(!(b > a))
        #expect(!(a > a))
    }

    @Test(
        arguments: [
            // 1 <= 2
            (.init(units: 1, power: 0), .init(units: 2, power: 0)),
            // 1 <= 1
            (.init(units: 1, power: 0), .init(units: 1, power: 0)),
            // -1 <= 1
            (.init(units: -1, power: 0), .init(units: 1, power: 0)),
            // -1 <= 0
            (.init(units: -1, power: 0), .init(units: 0, power: 0)),
            // -2 <= -1
            (.init(units: -2, power: 0), .init(units: -1, power: 0)),
            // -1 <= -1
            (.init(units: -1, power: 0), .init(units: -1, power: 0)),
            // 1.23 <= 1.234
            (.init(units: 123, power: -2), .init(units: 1234, power: -3)),
            // 1.23 <= 1.23
            (.init(units: 123, power: -2), .init(units: 123, power: -2)),
            // -1.234 <= -1.23
            (.init(units: -1234, power: -3), .init(units: -123, power: -2)),
            // -1.23 <= -1.23
            (.init(units: -123, power: -2), .init(units: -123, power: -2)),
            // 1e-20 <= 1e20
            (.init(units: 1, power: -20), .init(units: 1, power: 20)),
            // 1e-20 <= 1e-20
            (.init(units: 1, power: -20), .init(units: 1, power: -20)),
            // -1e20 <= -1e-20
            (.init(units: -1, power: 20), .init(units: -1, power: -20)),
            // -1e20 <= -1e20
            (.init(units: -1, power: 20), .init(units: -1, power: 20)),
        ] as [(Decimal, Decimal)]
    ) func LessThanOrEqual(_ a: Decimal, _ b: Decimal) throws {
        #expect(a <= b)
        #expect(!(b < a))
    }

    @Test(
        arguments: [
            // 2 >= 1
            (.init(units: 2, power: 0), .init(units: 1, power: 0)),
            // 1 >= 1
            (.init(units: 1, power: 0), .init(units: 1, power: 0)),
            // 1 >= -1
            (.init(units: 1, power: 0), .init(units: -1, power: 0)),
            // 0 >= -1
            (.init(units: 0, power: 0), .init(units: -1, power: 0)),
            // -1 >= -2
            (.init(units: -1, power: 0), .init(units: -2, power: 0)),
            // -1 >= -1
            (.init(units: -1, power: 0), .init(units: -1, power: 0)),
            // 1.234 >= 1.23
            (.init(units: 1234, power: -3), .init(units: 123, power: -2)),
            // 1.23 >= 1.23
            (.init(units: 123, power: -2), .init(units: 123, power: -2)),
            // -1.23 >= -1.234
            (.init(units: -123, power: -2), .init(units: -1234, power: -3)),
            // -1.23 >= -1.23
            (.init(units: -123, power: -2), .init(units: -123, power: -2)),
            // 1e20 >= 1e-20
            (.init(units: 1, power: 20), .init(units: 1, power: -20)),
            // 1e20 >= 1e20
            (.init(units: 1, power: 20), .init(units: 1, power: 20)),
            // -1e-20 >= -1e20
            (.init(units: -1, power: -20), .init(units: -1, power: 20)),
            // -1e-20 >= -1e-20
            (.init(units: -1, power: -20), .init(units: -1, power: -20)),
        ] as [(Decimal, Decimal)]
    ) func GreaterThanOrEqual(_ a: Decimal, _ b: Decimal) throws {
        #expect(a >= b)
        #expect(!(a < b))
    }
}
