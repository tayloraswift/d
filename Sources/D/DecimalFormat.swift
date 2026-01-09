public protocol DecimalFormat<Power> {
    associatedtype Power: DecimalPower
    /// The grouping stride to use when formatting. If `nil`, no grouping will be applied.
    var stride: UInt8? { get }
    /// The number of decimal places to use when formatting. If set to 0 or less, no decimal
    /// places will appear.
    var places: UInt8? { get }
}
