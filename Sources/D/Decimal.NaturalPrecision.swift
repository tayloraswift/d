extension Decimal {
    @frozen public struct NaturalPrecision<Power> where Power: DecimalPower {
        @usableFromInline let _stride: UInt8
        @inlinable init(stride: UInt8) {
            self._stride = stride
        }
    }
}
extension Decimal.NaturalPrecision: DecimalFormat {
    @inlinable public var stride: UInt8? { self._stride }
    @inlinable public var places: UInt8? { nil }
}
extension Decimal.NaturalPrecision<Units> {
    @inlinable public static prefix func .. (_: Self) -> () {}
}
extension Decimal.NaturalPrecision<Percent> {
    @inlinable public static prefix func % (_: Self) -> () {}
}
extension Decimal.NaturalPrecision<Permille> {
    @inlinable public static prefix func ‰ (_: Self) -> () {}
}
extension Decimal.NaturalPrecision<BasisPoints> {
    @inlinable public static prefix func ‱ (_: Self) -> () {}
}
