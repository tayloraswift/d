import D
import Testing

@Suite enum FloatingPointGroupingTests {
    @Test static func Triple() {
        let x: Double = 0.3989
        let y: Double = 0.3944
        #expect("\(x[/3..3])" == "0.399")
        #expect("\(y[/3..3])" == "0.394")
    }
}
