/// Defines rounding behavior when creating a `Decimal` from a fraction.
@frozen public enum DecimalRoundingMode {
    /// Rounds towards zero (truncation).
    ///
    /// - `1.239` (s=3) -> `1.23`
    /// - `-1.239` (s=3) -> `-1.23`
    case toZero

    /// Rounds away from zero if any fractional part exists.
    ///
    /// - `1.231` (s=3) -> `1.24`
    /// - `-1.231` (s=3) -> `-1.24`
    /// - `1.230` (s=3) -> `1.23`
    case awayFromZero

    /// Rounds to the nearest value; halves round away from zero.
    ///
    /// - `1.235` (s=3) -> `1.24`
    /// - `1.234` (s=3) -> `1.23`
    /// - `-1.235` (s=3) -> `-1.24`
    case nearest
}
