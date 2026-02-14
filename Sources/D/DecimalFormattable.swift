public protocol DecimalFormattable {
    var zero: Bool  { get }
    var sign: Bool? { get }

    /// Compute the magnitude and sign of the difference between `self` and `next`.
    /// The sign component is true if `next` is greater than `self`, false if less, and nil if
    /// they are equal.
    func delta(to next: Self) -> (sign: Bool?, magnitude: Self)
    func format(
        power: Int,
        stride: Int?,
        places: Int?,
        prefix: NumericSignDisplay,
        suffix: String
    ) -> String
}
extension DecimalFormattable {
    @inlinable public subscript<Format>(format: Format) -> DecimalRepresentation<Self, Format>
        where Format: DecimalFormat {
        .init(value: self, prefix: .default, format: format)
    }

    @inlinable public subscript<E>(
        format: (Decimal.Ungrouped<E>.Natural) -> ()
    ) -> DecimalRepresentation<Self, Decimal.Ungrouped<E>.Natural> where E: DecimalPower {
        .init(value: self, prefix: .default, format: .init())
    }
}
extension DecimalFormattable where Self: BinaryFloatingPoint {
    @available(
        *, deprecated, message: """
        natural precision decimal formatting might produce a very long string, if this is \
        intentional, use the trailing '..' operator to explicitly specify natural precision
        """
    ) @inlinable public subscript(
        format: BigIntFormat
    ) -> DecimalRepresentation<Self, BigIntFormat> {
        .init(value: self, prefix: .default, format: format)
    }
}
extension DecimalFormattable where Self == Decimal {
    @available(
        *, deprecated, message: """
        natural precision decimal formatting with digit grouping is better expressed as a \
        plain 'BigIntFormat' without the trailing '..' operator
        """
    ) @inlinable public subscript(
        format: Decimal.Grouped<Units>.Natural
    ) -> DecimalRepresentation<Self, Decimal.Grouped<Units>.Natural> {
        .init(value: self, prefix: .default, format: format)
    }
}
extension DecimalFormattable {
    @available(
        *, unavailable, message: """
        it looks like you accidentally put the power specifier before the precision specifier
        """
    ) @inlinable public subscript<E>(
        format: Decimal.Grouped<E>.Natural.Postfix_
    ) -> DecimalRepresentation<Self, Decimal.Ungrouped<E>.Natural> where E: DecimalPower {
        fatalError()
    }
}
