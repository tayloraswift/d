@frozen public struct Percent: DecimalPower {
    @inlinable public static var power: Int { 2 }
    @inlinable public static var sigil: String { "%" }
}
