extension Decimal {
    @frozen public struct Grouped<Power> where Power: DecimalPower {
        @usableFromInline let _stride: UInt8
        @usableFromInline let _places: UInt8
        @inlinable init(stride: UInt8, places: UInt8) {
            self._stride = stride
            self._places = places
        }
    }
}
extension Decimal.Grouped: DecimalFormat {
    @inlinable public var stride: UInt8? { self._stride }
    @inlinable public var places: UInt8? { self._places }
}
