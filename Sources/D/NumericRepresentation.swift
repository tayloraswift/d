public protocol NumericRepresentation: CustomStringConvertible {
    var zero: Bool { get }
    var sign: Bool? { get }
    prefix static func + (self: consuming Self) -> Self
}
extension NumericRepresentation {
    @inlinable public prefix static func +? (self: Self) -> Self? {
        self.zero ? nil : +self
    }
    @inlinable public prefix static func ?? (self: Self) -> Self? {
        self.zero ? nil : self
    }
}
