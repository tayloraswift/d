extension Decimal.Grouped.Natural {
    /// A syntactical intermediate for constructing a ``Decimal.NaturalPrecision`` format,
    /// necessary to work around precedence issues with the prefix `/` operator.
    @frozen public struct Postfix_ {
        @usableFromInline let stride: UInt8
        @inlinable init(stride: UInt8) {
            self.stride = stride
        }
    }
}
extension Decimal.Grouped.Natural.Postfix_ {
    @inlinable public static prefix func / (self: Self) -> Decimal.Grouped<Power>.Natural {
        .init(stride: self.stride)
    }
}
