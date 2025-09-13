import D
import Testing

@Suite struct DecimalLosslessStringConvertibleTests {
    @Test func Integer() {
        let a: String = "123"
        let d: Decimal? = .init(a)
        #expect(d?.units == 123)
        #expect(d?.power == 0)
        #expect(d?.description == "123")
    }

    @Test func NegativeInteger() {
        let a: String = "-123"
        let d: Decimal? = .init(a)
        #expect(d?.units == -123)
        #expect(d?.power == 0)
        #expect(d?.description == "-123")
    }

    @Test func Fractional() {
        let a: String = "123.45"
        let d: Decimal? = .init(a)
        #expect(d?.units == 12345)
        #expect(d?.power == -2)
        #expect(d?.description == "123.45")
    }

    @Test func NegativeDecimal() {
        let a: String = "-123.45"
        let d: Decimal? = .init(a)
        #expect(d?.units == -12345)
        #expect(d?.power == -2)
        #expect(d?.description == "-123.45")
    }

    @Test func LeadingDot() {
        let a: String = ".45"
        let d: Decimal? = .init(a)
        #expect(d?.units == 45)
        #expect(d?.power == -2)
        #expect(d?.description == "0.45")
    }

    @Test func NegativeLeadingDot() {
        let a: String = "-.45"
        let d: Decimal? = .init(a)
        #expect(d?.units == -45)
        #expect(d?.power == -2)
        #expect(d?.description == "-0.45")
    }

    @Test func TrailingDot() {
        let a: String = "123."
        let d: Decimal? = .init(a)
        #expect(d?.units == 123)
        #expect(d?.power == 0)
        #expect(d?.description == "123")
    }

    @Test func NegativeTrailingDot() {
        let a: String = "-123."
        let d: Decimal? = .init(a)
        #expect(d?.units == -123)
        #expect(d?.power == 0)
        #expect(d?.description == "-123")
    }

    @Test func Zero() {
        let a: String = "0"
        let d: Decimal? = .init(a)
        #expect(d?.units == 0)
        #expect(d?.power == 0)
        #expect(d?.description == "0")
    }

    @Test func ZeroWithDecimal() {
        let a: String = "0.00"
        let d: Decimal? = .init(a)
        #expect(d?.units == 0)
        #expect(d?.power == -2)
        #expect(d?.description == "0.00")
    }

    @Test func Invalid() {
        #expect(Decimal.init("abc") == nil)
        #expect(Decimal.init("1.2.3") == nil)
        #expect(Decimal.init("") == nil)
        #expect(Decimal.init(".") == nil)
        #expect(Decimal.init("-") == nil)
    }

    @Test(
        arguments: [
            ("0", "0"),
            ("1", "1"),
            ("-1", "-1"),
            ("1.23", "1.23"),
            ("-1.23", "-1.23"),
            (".123", "0.123"),
            ("-.123", "-0.123"),
            ("123.0", "123.0"),
            ("123.", "123"),
            ("123456789.123456789", "123456789.123456789")
        ]
    )
    func Roundtrip(_ value: String, canonical: String) {
        let d: Decimal? = .init(value)
        #expect(d?.description == canonical)
    }
}
