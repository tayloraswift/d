public protocol DynamicMagnitudeNotation {
    static subscript(magnitude magnitude: Double) -> (exponent: Int, suffix: String?)? { get }
}
extension DynamicMagnitudeNotation where Self == DynamicFinancialFormat {
    @inlinable public static var financial: Self { .init() }
}
