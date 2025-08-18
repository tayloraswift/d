extension BinaryInteger {
    @inlinable public subscript(format: BigIntFormat) -> BigIntRepresentation<Self> {
        .init(value: self, stride: format.stride, signed: false)
    }
}
