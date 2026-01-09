import D
import Testing

@Suite struct BigIntFormattingTests {
    @Test static func Zero() {
        let a: Int64 = 0
        #expect("\(a[/0])" == "0")
        #expect("\(a[/3])" == "0")
    }

    @Test static func Single() {
        let a: Int64 = 1
        #expect("\(a[/0])" == "1")
        #expect("\(a[/1])" == "1")
        #expect("\(a[/3])" == "1")

        let b: Int64 = -1
        #expect("\(b[/0])" == "−1")
        #expect("\(b[/1])" == "−1")
        #expect("\(b[/3])" == "−1")
    }

    @Test static func Double() {
        let a: Int64 = 12
        #expect("\(a[/0])" == "12")
        #expect("\(a[/1])" == "1,2")
        #expect("\(a[/2])" == "12")
        #expect("\(a[/3])" == "12")

        let b: Int64 = -34
        #expect("\(b[/0])" == "−34")
        #expect("\(b[/1])" == "−3,4")
        #expect("\(b[/2])" == "−34")
        #expect("\(b[/3])" == "−34")
    }

    @Test static func Triple() {
        let a: Int64 = 123
        #expect("\(a[/0])" == "123")
        #expect("\(a[/1])" == "1,2,3")
        #expect("\(a[/2])" == "1,23")
        #expect("\(a[/3])" == "123")

        let b: Int64 = -456
        #expect("\(b[/0])" == "−456")
        #expect("\(b[/1])" == "−4,5,6")
        #expect("\(b[/2])" == "−4,56")
        #expect("\(b[/3])" == "−456")
    }

    @Test static func Quadruple() {
        let a: Int64 = 1234
        #expect("\(a[/0])" == "1234")
        #expect("\(a[/1])" == "1,2,3,4")
        #expect("\(a[/2])" == "12,34")
        #expect("\(a[/3])" == "1,234")

        let b: Int64 = -5678
        #expect("\(b[/0])" == "−5678")
        #expect("\(b[/1])" == "−5,6,7,8")
        #expect("\(b[/2])" == "−56,78")
        #expect("\(b[/3])" == "−5,678")
    }

    @Test static func Large() {
        let a: Int64 = 123456789123
        #expect("\(a[/0])" == "123456789123")
        #expect("\(a[/1])" == "1,2,3,4,5,6,7,8,9,1,2,3")
        #expect("\(a[/2])" == "12,34,56,78,91,23")
        #expect("\(a[/3])" == "123,456,789,123")

        let b: Int64 = -987654321098
        #expect("\(b[/0])" == "−987654321098")
        #expect("\(b[/1])" == "−9,8,7,6,5,4,3,2,1,0,9,8")
        #expect("\(b[/2])" == "−98,76,54,32,10,98")
        #expect("\(b[/3])" == "−987,654,321,098")
    }

    @Test static func LargeWithRemainder() {
        let a: Int64 = 1234567890
        #expect("\(a[/0])" == "1234567890")
        #expect("\(a[/1])" == "1,2,3,4,5,6,7,8,9,0")
        #expect("\(a[/2])" == "12,34,56,78,90")
        #expect("\(a[/3])" == "1,234,567,890")

        let b: Int64 = -9876543210
        #expect("\(b[/0])" == "−9876543210")
        #expect("\(b[/1])" == "−9,8,7,6,5,4,3,2,1,0")
        #expect("\(b[/2])" == "−98,76,54,32,10")
        #expect("\(b[/3])" == "−9,876,543,210")
    }

    @Test static func LargeWithLeadingPlus() {
        let a: Int64 = 1234567890
        #expect("\(+a[/0])" == "+1234567890")
        #expect("\(+a[/1])" == "+1,2,3,4,5,6,7,8,9,0")
        #expect("\(+a[/2])" == "+12,34,56,78,90")
        #expect("\(+a[/3])" == "+1,234,567,890")

        let b: Int64 = -9876543210
        #expect("\(+b[/0])" == "−9876543210")
        #expect("\(+b[/1])" == "−9,8,7,6,5,4,3,2,1,0")
        #expect("\(+b[/2])" == "−98,76,54,32,10")
        #expect("\(+b[/3])" == "−9,876,543,210")
    }
}
