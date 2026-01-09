extension Decimal.NaturalPrecision {
    /// A syntactical intermediate for constructing a ``Decimal.NaturalPrecision`` format,
    /// necessary to work around precedence issues with the prefix `/` operator.
    @frozen public struct Postfix_ {
        @usableFromInline let stride: UInt8
        @inlinable init(stride: UInt8) {
            self.stride = stride
        }
    }
}
extension Decimal.NaturalPrecision.Postfix_ {
    @inlinable public static prefix func / (self: Self) -> Decimal.NaturalPrecision<Power> {
        .init(stride: self.stride)
    }
}
