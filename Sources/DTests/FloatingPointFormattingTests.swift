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
            (990, "990"),
            (991, "990"),
            // (999, "1.0\u{202F}k"),
            (1_000, "1.0\u{202F}k"),
            (1_500, "1.5\u{202F}k"),
            (2_000, "2.0\u{202F}k"),
        ]
    ) static func FinancialNotation(_ value: Double, _ expected: String) {
        #expect("\(value[..2][.financial])" == expected)
    }
}
