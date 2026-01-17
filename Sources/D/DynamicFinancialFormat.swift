@frozen public struct DynamicFinancialFormat: DynamicMagnitudeNotation {
    @inlinable init() {}
    @inlinable public static subscript(
        magnitude magnitude: Double
    ) -> (exponent: Int, suffix: String?)? {
        if  -3 ..< 3 ~= magnitude {
            return nil
        }

        let triples: Int = Int.init((magnitude / 3).rounded(.down))
        let exponent: Int = 3 * triples
        let suffix: String

        switch triples {
        case 1:
            suffix = "\u{202F}k"
        case 2:
            suffix = "\u{202F}M"
        case 3:
            suffix = "\u{202F}B"
        case 4:
            suffix = "\u{202F}T"
        case 5:
            suffix = "\u{202F}Q"
        case 0...:
            suffix = "e\(exponent)"
        default:
            suffix = "e\u{2212}\(-exponent)"
        }
        return (exponent, suffix)
    }
}
