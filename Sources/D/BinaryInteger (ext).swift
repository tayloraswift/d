extension BinaryInteger {
    @inlinable public subscript(format: BigIntFormat) -> BigIntRepresentation<Self> {
        .init(value: self, prefix: .default, format: format)
    }
}
