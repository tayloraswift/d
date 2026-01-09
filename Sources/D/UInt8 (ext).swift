extension UInt8 {
    @inlinable public prefix static func / (value: Self) -> BigIntFormat {
        .init(stride: value)
    }

    @inlinable public prefix static func .. (value: Self) -> Decimal.Ungrouped<Units> {
        .init(places: value)
    }

    @inlinable public prefix static func % (value: Self) -> Decimal.Ungrouped<Percent> {
        .init(places: value)
    }

    @inlinable public prefix static func ‰ (value: Self) -> Decimal.Ungrouped<Permille> {
        .init(places: value)
    }

    @inlinable public prefix static func ‱ (value: Self) -> Decimal.Ungrouped<BasisPoints> {
        .init(places: value)
    }
}
extension UInt8 {
    @available(
        *,
        deprecated,
        message: """
        natural precision decimal formatting with digit grouping is better expressed as a \
        plain 'BigIntFormat' without the trailing '..' operator
        """
    ) @inlinable public postfix static func .. (
        self: Self
    ) -> Decimal.NaturalPrecision<Units>.Postfix_ {
        .init(stride: self)
    }

    @inlinable public postfix static func % (
        self: Self
    ) -> Decimal.NaturalPrecision<Percent>.Postfix_ {
        .init(stride: self)
    }

    @inlinable public postfix static func ‰ (
        self: Self
    ) -> Decimal.NaturalPrecision<Permille>.Postfix_ {
        .init(stride: self)
    }

    @inlinable public postfix static func ‱ (
        self: Self
    ) -> Decimal.NaturalPrecision<BasisPoints>.Postfix_ {
        .init(stride: self)
    }
}
