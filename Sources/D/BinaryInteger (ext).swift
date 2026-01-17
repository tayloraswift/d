extension BinaryInteger {
    @inlinable public subscript(format: BigIntFormat) -> BigIntRepresentation<Self> {
        .init(value: self, format: format, signed: false)
    }
}
