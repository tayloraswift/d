import D
import Testing

@Suite struct FloatingPointFormattingTests {
    @Test static func Rounding() {
        let a: Double = 0.14
        #expect("\(a[..1])" == "0.1")
        let b: Double = 0.15
        #expect("\(b[..1])" == "0.2")
        let c: Double = 0.16
        #expect("\(c[..1])" == "0.2")
    }
    @Test static func Signed() {
        let a: Double = 0.09
        #expect("\(+a[..1])" == "+0.1")
        let b: Double = 0.01
        #expect("\(+b[..1])" == "+0.0")
        let c: Double = -0.01
        #expect("\(+c[..1])" == "−0.0")
        let d: Double = -0.09
        #expect("\(+d[..1])" == "−0.1")
    }
    @Test static func SignedIntegral() {
        let a: Double = 0.9
        #expect("\(+a[..0])" == "+1")
        let b: Double = 0.1
        #expect("\(+b[..0])" == "+0")
        let c: Double = -0.1
        #expect("\(+c[..0])" == "−0")
        let d: Double = -0.9
        #expect("\(+d[..0])" == "−1")
    }

    @Test(
        arguments: [
            (-0.00123, "−0.0012"),
            (-0.000128, "−130e−6"),
            (-0.000123, "−120e−6"),
            (0, "0"),
            (0.000123, "120e−6"),
            (0.000128, "130e−6"),
            (0.00123, "0.0012"),
            (0.0123, "0.012"),
            (0.123, "0.12"),
            (98, "98"),
            (99, "99"),
            (100, "100"),
            (101, "100"),
            (990, "990"),
            (991, "990"),
            (999, "1.0\u{202F}k"),
            (1_000, "1.0\u{202F}k"),
            (1_500, "1.5\u{202F}k"),
            (2_000, "2.0\u{202F}k"),
        ]
    ) static func FinancialNotation2(_ value: Double, _ expected: String) {
        #expect("\(value[..2][.financial])" == expected)
    }
    @Test(
        arguments: [
            (-0.00123, "−0.00123"),
            (-0.000123, "−123e−6"),
            (0, "0"),
            (0.000123, "123e−6"),
            (0.00123, "0.00123"),
            (0.0123, "0.0123"),
            (0.123, "0.123"),
            (0.1, "0.100"),
            (98, "98.0"),
            (99, "99.0"),
            (100, "100"),
            (101, "101"),
            (990, "990"),
            (991, "991"),
            (999, "999"),
            (1_000, "1.00\u{202F}k"),
            (1_500, "1.50\u{202F}k"),
            (2_000, "2.00\u{202F}k"),
        ]
    ) static func FinancialNotation3(_ value: Double, _ expected: String) {
        #expect("\(value[..3][.financial])" == expected)
    }
}
