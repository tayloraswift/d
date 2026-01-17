extension Decimal.Ungrouped {
    @frozen public struct Natural {
        @inlinable init() {}
    }
}
extension Decimal.Ungrouped.Natural: DecimalFormat {
    @inlinable public var stride: UInt8? { nil }
    @inlinable public var places: UInt8? { nil }
}
extension Decimal.Ungrouped<Units>.Natural {
    @inlinable public static prefix func .. (_: Self) -> () {}
}
extension Decimal.Ungrouped<Percent>.Natural {
    @inlinable public static prefix func % (_: Self) -> () {}
}
extension Decimal.Ungrouped<Permille>.Natural {
    @inlinable public static prefix func ‰ (_: Self) -> () {}
}
extension Decimal.Ungrouped<BasisPoints>.Natural {
    @inlinable public static prefix func ‱ (_: Self) -> () {}
}
