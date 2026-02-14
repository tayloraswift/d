@frozen public enum NumericSignDisplay: Equatable {
    /// A plus sign is shown for for positive numbers, and a minus sign for negative numbers.
    case plus
    /// No plus sign is shown for positive numbers, a minus sign is shown for negative numbers.
    case `default`
}
