extension Decimal {
    @frozen public enum NaturalPrecision<Format> where Format: DecimalFormat {
    }
}
extension Decimal.NaturalPrecision<UnitFormat> {
    @inlinable public static prefix func .. (_: Self) -> () {}
}
extension Decimal.NaturalPrecision<PercentFormat> {
    @inlinable public static prefix func % (_: Self) -> () {}
}
extension Decimal.NaturalPrecision<PermilleFormat> {
    @inlinable public static prefix func ‰ (_: Self) -> () {}
}
extension Decimal.NaturalPrecision<BasisPointsFormat> {
    @inlinable public static prefix func ‱ (_: Self) -> () {}
}
