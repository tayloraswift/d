import D
import Testing

@Suite struct DecimalSemanticsTests {
    @Test static func Initialization() {
        let a: Decimal = 123
        #expect(a.units == 123)
        #expect(a.power == 0)

        let b: Decimal = -456
        #expect(b.units == -456)
        #expect(b.power == 0)
    }

    @Test static func PostfixOperators() {
        let aPercent: Decimal = 100%
        let aPermille: Decimal = 100‰
        let aPermyriad: Decimal = 100‱
        #expect(aPercent.units == 100)
        #expect(aPercent.power == -2)

        #expect(aPermille.units == 100)
        #expect(aPermille.power == -3)

        #expect(aPermyriad.units == 100)
        #expect(aPermyriad.power == -4)
    }

    @Test static func UnaryOperators() {
        let a: Decimal = .init(units: 123, power: 2)

        #expect((-a).units == -123)
        #expect((-a).power == 2)

        #expect((+a).units == 123)
        #expect((+a).power == 2)
    }

    @Test static func Addition() {
        let a: Decimal = .init(units: 1, power: 2)
        let b: Decimal = .init(units: 5, power: 0)

        let sum1: Decimal = a + b
        #expect(sum1.units == 105)
        #expect(sum1.power == 0)

        let c: Decimal = .init(units: 3, power: -1)
        let sum2: Decimal = a + c
        #expect(sum2.units == 1003)
        #expect(sum2.power == -1)
    }

    @Test static func Subtraction() {
        let a: Decimal = .init(units: 1, power: 2)
        let b: Decimal = .init(units: 5, power: 0)

        let difference1: Decimal = a - b
        #expect(difference1.units == 95)
        #expect(difference1.power == 0)

        let c: Decimal = .init(units: 3, power: -1)
        let difference2: Decimal = a - c
        #expect(difference2.units == 997)
        #expect(difference2.power == -1)
    }

    @Test static func Equality() {
        #expect(Decimal.init(units: 1, power: 0) == Decimal.init(units: 1, power: 0))
        #expect(Decimal.init(units: 10, power: -1) == Decimal.init(units: 1, power: 0))
        #expect(Decimal.init(units: 1230, power: -2) == Decimal.init(units: 123, power: -1))
        #expect(Decimal.init(units: 12300, power: -2) == Decimal.init(units: 123, power: 0))
        #expect(Decimal.init(units: -50, power: 1) == Decimal.init(units: -5, power: 2))
    }

    @Test static func EqualityWithZero() {
        #expect(Decimal.init(units: 0, power: 5) == Decimal.init(units: 0, power: -3))
        #expect(Decimal.init(units: 0, power: 0) == 0)
        #expect(Decimal.init(units: 1, power: 0) != 0)
    }

    @Test static func EqualityOverflow() {
        // This test checks for equality between two representations of the same large number.
        let a: Decimal = .init(units: .max, power: 18)
        let b: Decimal = .init(units: .max, power: 18)
        #expect(a == b)

        // A naive comparison would need to scale `a.units` by 10 (to reduce its power to 17),
        // causing integer overflow.
        let c: Decimal = .init(units: .max, power: 17)
        #expect(a != c)

        let d: Decimal = .init(units: .max / 10,      power: .max)
        let e: Decimal = .init(units: .max / 10 * 10, power: .max - 1)
        #expect(d == e)

        let f: Decimal = .init(units: .max / 10 * 10, power: .min)
        let g: Decimal = .init(units: .max / 10,      power: .min + 1)
        #expect(f == g)
    }

    @Test static func Inequality() {
        #expect(Decimal.init(units: 1, power: 1) != Decimal.init(units: 1, power: 0))
        #expect(Decimal.init(units: 10, power: -1) != Decimal.init(units: 2, power: 0))
    }

    @Test static func Normalization() {
        var a: Decimal = .init(units: 1200, power: -1)
        a.normalize()
        #expect(a.units == 12)
        #expect(a.power == 1)

        var b: Decimal = 0
        b.normalize()
        #expect(b.units == 0)
        #expect(b.power == 0)
    }

    @Test static func NormalizationArithmetic() {
        let a: Decimal = 150%
        let b: Decimal = 500‰

        let c: Decimal = (a - b).normalized()
        #expect(c.units == 1)
        #expect(c.power == 0)

        let d: Decimal = (-c + 250‱).normalized()
        #expect(d.units == -975)
        #expect(d.power == -3)
    }

    @Test static func ZeroAndNegativeNumbers() {
        let a: Decimal = 0
        let b: Decimal = .init(units: -10, power: 1)

        let sum: Decimal = a + b
        #expect(sum.units == -100)
        #expect(sum.power == 0)

        let difference: Decimal = a - b
        #expect(difference.units == 100)
        #expect(difference.power == 0)
    }
}
