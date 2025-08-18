public protocol DecimalFormat {
    /// The power of ten offset to apply for this format. For example, when formatting percents,
    /// this is 2, because we want to print the number `0.XYZ` as `XY.Z%`.
    static var power: Int { get }
    static var sigil: String { get }
    /// The number of decimal places to use when formatting. If set to 0 or less, no decimal
    /// places will appear.
    var places: UInt8 { get }
}
