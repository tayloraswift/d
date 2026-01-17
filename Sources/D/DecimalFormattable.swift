public protocol DecimalFormattable {
    var zero: Bool  { get }
    var sign: Bool? { get }

    /// Compute the magnitude and sign of the difference between `self` and `next`.
    /// The sign component is true if `next` is greater than `self`, false if less, and nil if
    /// they are equal.
    func delta(to next: Self) -> (sign: Bool?, magnitude: Self)
    func format(power: Int, stride: Int?, places: Int?, signed: Bool, suffix: String) -> String
}
extension DecimalFormattable {
    @inlinable public subscript<Format>(format: Format) -> DecimalRepresentation<Self, Format>
        where Format: DecimalFormat {
        .init(value: self, format: format, signed: false)
    }

    @inlinable public subscript<E>(
        format: (Decimal.Ungrouped<E>.Natural) -> ()
    ) -> DecimalRepresentation<Self, Decimal.Ungrouped<E>.Natural> where E: DecimalPower {
        .init(value: self, format: .init(), signed: false)
    }
}
extension DecimalFormattable {
    @available(
        *, unavailable,
        message: """
        it looks like you accidentally put the power specifier before the precision specifier
        """
    ) @inlinable public subscript<E>(
        format: Decimal.Grouped<E>.Natural.Postfix_
    ) -> DecimalRepresentation<Self, Decimal.Ungrouped<E>.Natural> where E: DecimalPower {
        fatalError()
    }
}
