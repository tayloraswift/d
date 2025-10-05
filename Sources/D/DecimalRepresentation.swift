@frozen public struct DecimalRepresentation<Value, Format>
    where Value: DecimalFormattable, Format: DecimalFormat {
    public let value: Value
    @usableFromInline let places: UInt8?
    /// Whether to format the number with a leading plus sign, if positive.
    @usableFromInline var signed: Bool

    @inlinable init(value: Value, places: UInt8?, signed: Bool) {
        self.value = value
        self.places = places
        self.signed = signed
    }
}
extension DecimalRepresentation {
    @inlinable public func map<T, E>(
        _ transform: (Value) throws(E) -> T
    ) throws(E) -> DecimalRepresentation<T, Format> {
        .init(value: try transform(self.value), places: self.places, signed: self.signed)
    }

    @inlinable public func with(value: Value) -> Self {
        .init(value: value, places: self.places, signed: self.signed)
    }
}
extension DecimalRepresentation: NumericRepresentation {
    @inlinable public var zero: Bool { self.value.zero }
    @inlinable public var sign: Bool? { self.value.sign }

    @inlinable public prefix static func + (self: consuming Self) -> Self {
        self.signed = true
        return self
    }
}
extension DecimalRepresentation: CustomStringConvertible {
    @inlinable public var description: String {
        self.value.format(
            power: Format.power,
            places: self.places.map(Int.init(_:)),
            signed: self.signed,
            suffix: Format.sigil,
        )
    }
}
