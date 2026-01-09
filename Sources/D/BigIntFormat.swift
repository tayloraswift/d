@frozen public struct BigIntFormat {
    @usableFromInline let _stride: UInt8

    @inlinable init(stride: UInt8) {
        self._stride = stride
    }
}
extension BigIntFormat: DecimalFormat {
    public typealias Power = Units
    @inlinable public var stride: UInt8? { self._stride }
    @inlinable public var places: UInt8? { nil }
}
extension BigIntFormat {
    @inlinable public static func .. (
        self: Self,
        places: UInt8
    ) -> Decimal.Grouped<Units> {
        .init(stride: self._stride, places: places)
    }

    @inlinable public static func % (
        self: Self,
        places: UInt8
    ) -> Decimal.Grouped<Percent> {
        .init(stride: self._stride, places: places)
    }

    @inlinable public static func ‰ (
        self: Self,
        places: UInt8
    ) -> Decimal.Grouped<Permille> {
        .init(stride: self._stride, places: places)
    }

    @inlinable public static func ‱ (
        self: Self,
        places: UInt8
    ) -> Decimal.Grouped<BasisPoints> {
        .init(stride: self._stride, places: places)
    }
}
