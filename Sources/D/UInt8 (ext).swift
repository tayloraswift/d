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
    @inlinable public postfix static func .. (
        self: Self
    ) -> Decimal.Grouped<Units>.Natural.Postfix_ {
        .init(stride: self)
    }

    @inlinable public postfix static func % (
        self: Self
    ) -> Decimal.Grouped<Percent>.Natural.Postfix_ {
        .init(stride: self)
    }

    @inlinable public postfix static func ‰ (
        self: Self
    ) -> Decimal.Grouped<Permille>.Natural.Postfix_ {
        .init(stride: self)
    }

    @inlinable public postfix static func ‱ (
        self: Self
    ) -> Decimal.Grouped<BasisPoints>.Natural.Postfix_ {
        .init(stride: self)
    }
}
