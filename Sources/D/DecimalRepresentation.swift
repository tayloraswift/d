@frozen public struct DecimalRepresentation<Value, Format>
    where Value: DecimalFormattable, Format: DecimalFormat {
    public let value: Value
    @usableFromInline let stride: UInt8?
    @usableFromInline let places: UInt8?
    /// Whether to format the number with a leading plus sign, if positive.
    @usableFromInline var signed: Bool

    @inlinable init(value: Value, stride: UInt8?, places: UInt8?, signed: Bool) {
        self.value = value
        self.stride = stride
        self.places = places
        self.signed = signed
    }
}
extension DecimalRepresentation {
    @inlinable public func map<T, E>(
        _ transform: (Value) throws(E) -> T
    ) throws(E) -> DecimalRepresentation<T, Format> {
        .init(value: try transform(self.value), stride: self.stride, places: self.places, signed: self.signed)
    }

    @inlinable public func with(value: Value) -> Self {
        .init(value: value, stride: self.stride, places: self.places, signed: self.signed)
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
            power: Format.Power.power,
            stride: self.stride.map(Int.init(_:)),
            places: self.places.map(Int.init(_:)),
            signed: self.signed,
            suffix: Format.Power.sigil,
        )
    }
}
extension DecimalRepresentation {
    /// A string representation without any suffix.
    @inlinable public var bare: String {
        self.value.format(
            power: Format.Power.power,
            stride: self.stride.map(Int.init(_:)),
            places: self.places.map(Int.init(_:)),
            signed: self.signed,
            suffix: "",
        )
    }
}
