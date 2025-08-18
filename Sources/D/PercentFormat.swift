@frozen public struct PercentFormat: DecimalFormat {
    public let places: UInt8
    @inlinable public static var power: Int { 2 }
    @inlinable public static var sigil: String { "%" }

    @inlinable init(places: UInt8) {
        self.places = places
    }
}
