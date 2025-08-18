@frozen public struct BasisPointsFormat: DecimalFormat {
    public let places: UInt8
    @inlinable public static var power: Int { 4 }
    @inlinable public static var sigil: String { "‱" }

    @inlinable init(places: UInt8) {
        self.places = places
    }
}
