import D
import Testing

@Suite struct ZeroElisionTests {
    @Test static func BigInt() {
        let zero: Int64 = 0
        #expect((+?zero[/3]) == nil)
        #expect((-?zero[/3]) == nil)
        #expect((??zero[/3]) == nil)

        let positive: Int64 = 1234
        #expect((+?positive[/3]).map(String.init(describing:)) == "+1,234")
        #expect((-?positive[/3]).map(String.init(describing:)) == "−1,234")
        #expect((??positive[/3]).map(String.init(describing:)) == "1,234")

        let negative: Int64 = -1234
        #expect((+?negative[/3]).map(String.init(describing:)) == "−1,234")
        #expect((-?negative[/3]).map(String.init(describing:)) == "+1,234")
        #expect((??negative[/3]).map(String.init(describing:)) == "−1,234")
    }

    @Test static func Decimal() {
        let zero: D.Decimal = 0
        #expect((+?zero[..]) == nil)
        #expect((-?zero[..]) == nil)
        #expect((??zero[..]) == nil)

        let positive: D.Decimal = 55%
        #expect((+?positive[..]).map(String.init(describing:)) == "+0.55")
        #expect((-?positive[..]).map(String.init(describing:)) == "−0.55")
        #expect((??positive[..]).map(String.init(describing:)) == "0.55")

        let negative: D.Decimal = -55%
        #expect((+?negative[..]).map(String.init(describing:)) == "−0.55")
        #expect((-?negative[..]).map(String.init(describing:)) == "+0.55")
        #expect((??negative[..]).map(String.init(describing:)) == "−0.55")
    }

    @Test static func FloatingPoint() {
        let zero: Double = 0
        #expect((+?zero[..1]) == nil)
        #expect((-?zero[..1]) == nil)
        #expect((??zero[..1]) == nil)

        let negativeZero: Double = -0.0
        #expect((+?negativeZero[..1]) == nil)
        #expect((-?negativeZero[..1]) == nil)
        #expect((??negativeZero[..1]) == nil)

        let positive: Double = 1.5
        #expect((+?positive[..1]).map(String.init(describing:)) == "+1.5")
        #expect((-?positive[..1]).map(String.init(describing:)) == "−1.5")
        #expect((??positive[..1]).map(String.init(describing:)) == "1.5")

        let negative: Double = -1.5
        #expect((+?negative[..1]).map(String.init(describing:)) == "−1.5")
        #expect((-?negative[..1]).map(String.init(describing:)) == "+1.5")
        #expect((??negative[..1]).map(String.init(describing:)) == "−1.5")
    }
}
