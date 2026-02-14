import D
import Testing

@Suite struct DecimalFormattingTests {
    @Test static func Integral() {
        let a: Decimal = 123
        #expect(a.format(places: 0) == "123")
        #expect(a.format(places: 2) == "123.00")
        #expect(a.format(places: 20) == "123.00000000000000000000")
        #expect(a.format(places: 0, prefix: .plus) == "+123")
        #expect(a.format(places: 2, prefix: .plus) == "+123.00")

        let b: Decimal = -456
        #expect(b.format(places: 0) == "−456")
        #expect(b.format(places: 3) == "−456.000")
        #expect(b.format(places: 20) == "−456.00000000000000000000")
    }

    @Test static func Fractional() {
        let a: Decimal = 12345%
        #expect(a.format(places: 0) == "123")
        #expect(a.format(places: 2) == "123.45")
        #expect(a.format(places: 4) == "123.4500")
        #expect(a.format(places: 20) == "123.45000000000000000000")

        let b: Decimal = 12345‱
        #expect(b.format(places: 2) == "1.23")
        #expect(b.format(places: 4) == "1.2345")
        #expect(b.format(places: 20) == "1.23450000000000000000")

        let c: Decimal = .init(units: 12345, power: -6)
        #expect(c.format(places: 4) == "0.0123")

        let d: Decimal = .init(units: -987, power: -1)
        #expect(d.format(places: 2) == "−98.70")
    }

    @Test static func Rounding() {
        // Round up
        let a: Decimal = 12345‰
        #expect(a.format(places: 1) == "12.3")

        // Round up
        #expect(a.format(places: 2) == "12.35")

        // Round down
        let b: Decimal = 9826%
        #expect(b.format(places: 0) == "98")

        // Round positive toward zero
        let c: Decimal = +1%
        #expect(c.format(places: 1, prefix: .plus) == "+0.0")
        #expect(c.format(places: 0, prefix: .plus) == "+0")

        // Round negative toward zero
        let d: Decimal = -1%
        #expect(d.format(places: 1) == "−0.0")
        #expect(d.format(places: 0) == "−0")

        // Round negative away from zero
        let e: Decimal = -1235%
        #expect(e.format(places: 1) == "−12.4")
    }

    @Test static func RoundingE19() {
        // Round half up, away from zero (positive)
        let a: Decimal = .init(units: 5_000_000_000_000_000_000, power: -19)
        #expect(a.format(places: 0) == "1")

        // Round half up, away from zero (negative)
        let b: Decimal = .init(units: -5_000_000_000_000_000_000, power: -19)
        #expect(b.format(places: 0) == "−1")

        // Round toward zero (positive)
        let c: Decimal = .init(units: 4_999_999_999_999_999_999, power: -19)
        #expect(c.format(places: 0) == "0")

        // Round toward zero (negative)
        let d: Decimal = .init(units: -4_999_999_999_999_999_999, power: -19)
        #expect(d.format(places: 0) == "−0")
    }

    @Test static func RoundingEMin() {
        let a: Decimal = .init(units: 99999, power: -24)
        #expect(a.format(places: 45) == "0.000000000000000000099999000000000000000000000")
        #expect(a.format(places: 25) == "0.0000000000000000000999990")
        #expect(a.format(places: 24) == "0.000000000000000000099999")
        #expect(a.format(places: 23) == "0.00000000000000000010000")
        #expect(a.format(places: 22) == "0.0000000000000000001000")
        #expect(a.format(places: 21) == "0.000000000000000000100")
        #expect(a.format(places: 20) == "0.00000000000000000010")
        #expect(a.format(places: 19) == "0.0000000000000000001")
        #expect(a.format(places: 18) == "0.000000000000000000")

        let b: Decimal = .init(units: -99999, power: -24)
        #expect(b.format(places: 45) == "−0.000000000000000000099999000000000000000000000")
        #expect(b.format(places: 25) == "−0.0000000000000000000999990")
        #expect(b.format(places: 24) == "−0.000000000000000000099999")
        #expect(b.format(places: 23) == "−0.00000000000000000010000")
        #expect(b.format(places: 22) == "−0.0000000000000000001000")
        #expect(b.format(places: 21) == "−0.000000000000000000100")
        #expect(b.format(places: 20) == "−0.00000000000000000010")
        #expect(b.format(places: 19) == "−0.0000000000000000001")
        #expect(b.format(places: 18) == "−0.000000000000000000")

        let c: Decimal = .init(units: 123, power: -99)
        #expect(c.format(places: 0) == "0")
        #expect(c.format(places: 2) == "0.00")
        #expect(c.format(places: 20) == "0.00000000000000000000")
        #expect(c.format(places: 40) == "0.0000000000000000000000000000000000000000")

        let d: Decimal = .init(units: -45, power: -99)
        #expect(d.format(places: 0) == "−0")
        #expect(d.format(places: 2) == "−0.00")
        #expect(d.format(places: 20) == "−0.00000000000000000000")
        #expect(d.format(places: 40) == "−0.0000000000000000000000000000000000000000")
    }

    @Test static func SmallPowers() {
        let a: Decimal = .init(units: 123, power: -20)
        #expect(a.format(places: 0) == "0")
        #expect(a.format(places: 2) == "0.00")
        #expect(a.format(places: 20) == "0.00000000000000000123")
        #expect(a.format(places: 40) == "0.0000000000000000012300000000000000000000")

        let b: Decimal = .init(units: -45, power: -20)
        #expect(b.format(places: 0) == "−0")
        #expect(b.format(places: 2) == "−0.00")
        #expect(b.format(places: 20) == "−0.00000000000000000045")
        #expect(b.format(places: 40) == "−0.0000000000000000004500000000000000000000")
    }

    @Test static func LargePowers() {
        let a: Decimal = .init(units: 123, power: 2)
        #expect(a.format(places: 0) == "12300")
        #expect(a.format(places: 2) == "12300.00")
        #expect(a.format(places: 20) == "12300.00000000000000000000")

        let b: Decimal = .init(units: -45, power: 5)
        #expect(b.format(places: 0) == "−4500000")
        #expect(b.format(places: 2) == "−4500000.00")
        #expect(b.format(places: 20) == "−4500000.00000000000000000000")

        let c: Decimal = .init(units: -45, power: 20)
        #expect(c.format(places: 0) == "−4500000000000000000000")
        #expect(c.format(places: 2) == "−4500000000000000000000.00")
        #expect(c.format(places: 20) == "−4500000000000000000000.00000000000000000000")
    }

    @Test static func Zero() {
        let a: Decimal = 0
        #expect(a.format(places: 0) == "0")
        #expect(a.format(places: 4) == "0.0000")
        #expect(a.format(places: 2, prefix: .plus) == "0.00")
        #expect(a.format(places: 0, prefix: .plus) == "0")

        let b: Decimal = .init(units: 0, power: 9999)
        #expect(b.format(places: 0) == "0")
        #expect(b.format(places: 2) == "0.00")
        #expect(b.format(places: 0, prefix: .plus) == "0")
        #expect(b.format(places: 2, prefix: .plus) == "0.00")

        let c: Decimal = .init(units: 0, power: -99)
        #expect(c.format(places: 0) == "0")
        #expect(c.format(places: 2) == "0.00")
        #expect(c.format(places: 20) == "0.00000000000000000000")
        #expect(c.format(places: 40) == "0.0000000000000000000000000000000000000000")
    }

    @Test static func WithPlusSign() {
        let a: Decimal = 123
        #expect(a.format(places: 0, prefix: .plus) == "+123")

        let b: Decimal = -456
        #expect(b.format(places: 0, prefix: .plus) == "−456")

        let c: Decimal = 0
        #expect(c.format(places: 0, prefix: .plus) == "0")

        let d: Decimal = .init(units: 45, power: 20)
        #expect(d.format(places: 0, prefix: .plus) == "+4500000000000000000000")
        #expect(d.format(places: 2, prefix: .plus) == "+4500000000000000000000.00")
        #expect(
            d.format(
                places: 20,
                prefix: .plus
            ) == "+4500000000000000000000.00000000000000000000"
        )

        let e: Decimal = 12345‱
        #expect(e.format(places: 2, prefix: .plus) == "+1.23")
        #expect(e.format(places: 4, prefix: .plus) == "+1.2345")
        #expect(e.format(places: 20, prefix: .plus) == "+1.23450000000000000000")
    }

    @Test static func DSL() {
        let a: Decimal = 12345‱
        #expect("\(a[..])" == "1.2345")
        #expect("\(+a[..])" == "+1.2345")
        #expect("\(+a[..2])" == "+1.23")
        #expect("\(+a[..3])" == "+1.235")

        #expect("\(+a[%])" == "+123.45%")
        #expect("\(+a[%2])" == "+123.45%")
        #expect("\(+a[%3])" == "+123.450%")

        #expect("\(+a[‰])" == "+1234.5‰")
        #expect("\(+a[‰3])" == "+1234.500‰")
        #expect("\(+a[‰4])" == "+1234.5000‰")

        #expect("\(+a[‱])" == "+12345‱")
        #expect("\(+a[‱4])" == "+12345.0000‱")
        #expect("\(+a[‱3])" == "+12345.000‱")
        #expect("\(+a[‱2])" == "+12345.00‱")
        #expect("\(+a[‱1])" == "+12345.0‱")

        let b: Decimal = -9876‱
        #expect("\(+b[%])" == "−98.76%")
        #expect("\(+b[%0])" == "−99%")

        #expect("\(+b[‰])" == "−987.6‰")
        #expect("\(+b[‰0])" == "−988‰")

        #expect("\(+b[‱])" == "−9876‱")
        #expect("\(+b[‱0])" == "−9876‱")
        #expect("\(+b[‱2])" == "−9876.00‱")
    }
}
