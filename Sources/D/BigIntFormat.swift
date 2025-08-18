@frozen public struct BigIntFormat {
    public let stride: UInt8

    @inlinable init(stride: UInt8) {
        self.stride = stride
    }
}
