public protocol NumericRepresentation<Value>: CustomStringConvertible {
    associatedtype Value
    /// Whether to format the number with a leading plus sign, if positive.
    var prefix: NumericSignDisplay { get set }
    var value: Value { get set }
    var zero: Bool { get }
    var sign: Bool? { get }
    /// Returns this number formatted with no suffix.
    var bare: String { get }
}
extension NumericRepresentation {
    @inlinable public prefix static func + (self: consuming Self) -> Self {
        self.prefix = .plus
        return self
    }

    @inlinable public prefix static func +? (self: Self) -> Self? {
        self.zero ? nil : +self
    }

    @inlinable public prefix static func ?? (self: Self) -> Self? {
        self.zero ? nil : self
    }
}
extension NumericRepresentation where Value: SignedNumeric {
    @inlinable public prefix static func - (self: consuming Self) -> Self {
        self.prefix = .plus
        self.value = -self.value
        return self
    }
    @inlinable public prefix static func -? (self: consuming Self) -> Self {
        self.zero ? self : -self
    }
}
extension NumericRepresentation {
    @inlinable public consuming func with(value: Value) -> Self {
        self.value = value
        return self
    }
    @inlinable public consuming func with(
        value: Value,
        sign: NumericSignDisplay
    ) -> Self {
        self.value = value
        self.prefix = sign
        return self
    }
}
