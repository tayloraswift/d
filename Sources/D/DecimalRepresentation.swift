@frozen public struct DecimalRepresentation<Value, Format>
    where Value: DecimalFormattable, Format: DecimalFormat {
    public let value: Value
    @usableFromInline let format: Format
    /// Whether to format the number with a leading plus sign, if positive.
    @usableFromInline var signed: Bool

    @inlinable init(value: Value, format: Format, signed: Bool) {
        self.value = value
        self.format = format
        self.signed = signed
    }
}
extension DecimalRepresentation {
    @inlinable public func map<T, E>(
        _ transform: (Value) throws(E) -> T
    ) throws(E) -> DecimalRepresentation<T, Format> {
        .init(value: try transform(self.value), format: self.format, signed: self.signed)
    }

    @inlinable public func with(value: Value) -> Self {
        .init(value: value, format: self.format, signed: self.signed)
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
            stride: self.format.stride.map(Int.init(_:)),
            places: self.format.places.map(Int.init(_:)),
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
            stride: self.format.stride.map(Int.init(_:)),
            places: self.format.places.map(Int.init(_:)),
            signed: self.signed,
            suffix: "",
        )
    }
}
extension DecimalRepresentation<Double, Decimal.Ungrouped<Units>> {
    @inlinable public subscript<Notation>(
        notation: Notation
    ) -> String where Notation: DynamicMagnitudeNotation {
        self.value.format(
            notation: Notation.self,
            signed: self.signed,
            digits: Int.init(self.format._places)
        )
    }
}
extension DecimalRepresentation<Decimal, Decimal.Ungrouped<Units>.Natural> {
    @inlinable public subscript<Notation>(
        notation: Notation
    ) -> String where Notation: DynamicMagnitudeNotation {
        self.value.format(
            notation: Notation.self,
            signed: self.signed,
        )
    }
}
extension DecimalRepresentation {
    @available(*, unavailable, message: "notation is not supported for this format")
    @inlinable public subscript<Notation>(
        notation: Notation
    ) -> String where Notation: DynamicMagnitudeNotation {
        fatalError()
    }
}
