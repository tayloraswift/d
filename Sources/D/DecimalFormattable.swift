public protocol DecimalFormattable {
    var zero: Bool  { get }
    var sign: Bool? { get }

    /// Compute the magnitude and sign of the difference between `self` and `next`.
    /// The sign component is true if `next` is greater than `self`, false if less, and nil if
    /// they are equal.
    func delta(to next: Self) -> (sign: Bool?, magnitude: Self)
    func format(power: Int, places: Int?, signed: Bool, suffix: String) -> String
}
extension DecimalFormattable {
    @inlinable public subscript<Format>(format: Format) -> DecimalRepresentation<Self, Format>
        where Format: DecimalFormat {
        .init(value: self, places: format.places, signed: false)
    }

    @inlinable public subscript<Format>(
        format: (Decimal.NaturalPrecision<Format>) -> ()
    ) -> DecimalRepresentation<Self, Format> where Format: DecimalFormat {
        .init(value: self, places: nil, signed: false)
    }
}
