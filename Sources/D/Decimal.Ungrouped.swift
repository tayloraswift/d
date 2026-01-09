extension Decimal {
    @frozen public struct Ungrouped<Power> where Power: DecimalPower {
        @usableFromInline let _places: UInt8
        @inlinable init(places: UInt8) {
            self._places = places
        }
    }
}
extension Decimal.Ungrouped: DecimalFormat {
    @inlinable public var stride: UInt8? { nil }
    @inlinable public var places: UInt8? { self._places }
}
