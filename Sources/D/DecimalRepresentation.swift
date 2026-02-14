@frozen public struct DecimalRepresentation<Value, Format>
    where Value: DecimalFormattable, Format: DecimalFormat {
    public var value: Value
    public var prefix: NumericSignDisplay
    @usableFromInline let format: Format

    @inlinable init(value: Value, prefix: NumericSignDisplay, format: Format) {
        self.value = value
        self.prefix = prefix
        self.format = format
    }
}
extension DecimalRepresentation {
    @inlinable public func map<T, E>(
        _ transform: (Value) throws(E) -> T
    ) throws(E) -> DecimalRepresentation<T, Format> {
        .init(value: try transform(self.value), prefix: self.prefix, format: self.format)
    }
}
extension DecimalRepresentation: NumericRepresentation {
    @inlinable public var zero: Bool { self.value.zero }
    @inlinable public var sign: Bool? { self.value.sign }

    /// A string representation without any suffix.
    @inlinable public var bare: String {
        self.value.format(
            power: Format.Power.power,
            stride: self.format.stride.map(Int.init(_:)),
            places: self.format.places.map(Int.init(_:)),
            prefix: self.prefix,
            suffix: "",
        )
    }
}
extension DecimalRepresentation: CustomStringConvertible {
    @inlinable public var description: String {
        self.value.format(
            power: Format.Power.power,
            stride: self.format.stride.map(Int.init(_:)),
            places: self.format.places.map(Int.init(_:)),
            prefix: self.prefix,
            suffix: Format.Power.sigil,
        )
    }
}
extension DecimalRepresentation<Double, Decimal.Ungrouped<Units>> {
    @inlinable public subscript<Notation>(
        notation: Notation
    ) -> String where Notation: DynamicMagnitudeNotation {
        self.value.format(
            notation: Notation.self,
            prefix: self.prefix,
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
            prefix: self.prefix,
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
