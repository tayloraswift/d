@frozen public struct UnitFormat: DecimalFormat {
    public let places: UInt8
    @inlinable public static var power: Int { 0 }
    @inlinable public static var sigil: String { "" }

    @inlinable init(places: UInt8) {
        self.places = places
    }
}
