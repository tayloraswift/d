public protocol DecimalPower {
    /// The power of ten offset to apply for this format. For example, when formatting percents,
    /// this is 2, because we want to print the number `0.XYZ` as `XY.Z%`.
    static var power: Int { get }
    static var sigil: String { get }
}
