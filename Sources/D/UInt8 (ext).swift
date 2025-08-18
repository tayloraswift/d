extension UInt8 {
    @inlinable public prefix static func / (value: Self) -> BigIntFormat {
        .init(stride: value)
    }

    @inlinable public prefix static func .. (value: Self) -> UnitFormat {
        .init(places: value)
    }

    @inlinable public prefix static func % (value: Self) -> PercentFormat {
        .init(places: value)
    }

    @inlinable public prefix static func ‰ (value: Self) -> PermilleFormat {
        .init(places: value)
    }

    @inlinable public prefix static func ‱ (value: Self) -> BasisPointsFormat {
        .init(places: value)
    }
}
