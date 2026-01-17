extension Decimal.Grouped {
    @frozen public struct Natural {
        @usableFromInline let _stride: UInt8
        @inlinable init(stride: UInt8) {
            self._stride = stride
        }
    }
}
extension Decimal.Grouped.Natural: DecimalFormat {
    @inlinable public var stride: UInt8? { self._stride }
    @inlinable public var places: UInt8? { nil }
}
