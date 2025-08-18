import D

// The ``Decimal`` type allows for precise base-10 arithmetic.
// You can initialize it from an integer literal.
let a: Decimal = .init(units: 15, power: -1) // Represents 1.5
let b: Decimal = 2

// Postfix operators provide a convenient way to express common values.
let _: Decimal = 150% // 1.5
let _: Decimal = 500‰ // 0.5
let _: Decimal = 250‱ // 0.025

// Arithmetic is precise.
let sum: Decimal = 150% + 500‰
print("150% + 500‰ = \(sum[..])") // "2.000"

let difference: Decimal = 150% - 500‰
print("150% - 500‰ = \(difference[..])") // "1.000"

// You can normalize a Decimal to its simplest form.
let unnormalized: Decimal = .init(units: 1200, power: -1) // 120.0
let normalized: Decimal = unnormalized.normalized()
// `normalized` is now {units: 12, power: 1}, representing 120.

print("Normalized \(unnormalized[..]) is \(normalized[..])")


// The library provides a powerful DSL for formatting numbers within string interpolation.
let value: Decimal = 12345‱ // Represents 1.2345

// Format with a specific number of decimal places using `..`.
print("Value with 2 places: \(value[..2])") // "1.23"
print("Value with 5 places: \(value[..5])") // "1.23450"

// Format with its natural precision by omitting the digit count specifier.
print("Value with natural places: \(value[..])") // "1.2345"

// Format as a percentage, permille, or basis points.
print("As percentage (natural): \(value[%])") // "123.45%"
print("As permillage (natural): \(value[‰])") // "1234.5‰"
print("As basis points (natural): \(value[‱])") // "12345‱"

print("As a percentage (1 place): \(value[%1])") // "123.5%"
print("As a permillage (1 place): \(value[‰1])") // "1234.5‰"
print("As basis points (1 place): \(value[‱1])") // "12345.0‱"

print("As a percentage (3 places): \(value[%3])") // "123.450%"
print("As a permillage (3 places): \(value[‰3])") // "1234.500‰"
print("As basis points (3 places): \(value[‱3])") // "12345.000‱"

// Force a sign for positive numbers with the `+` prefix operator.
// Negative numbers are formatted using a true Unicode minus sign (`U+2212`).
print("Forced sign: \(+value[..2])") // "+1.23"
print("Negative sign: \((-value)[%0])") // "−123%"

let integer: Int = 1234567890

// Group digits using the `/` operator for readability.
print("Grouped by 3 (thousands): \(integer[/3])") // "1,234,567,890"
print("Grouped by 2 (hundreds): \(integer[/2])") // "12,34,56,78,90"
print("Grouped by 4 (myriads): \(integer[/4])") // "12,3456,7890"
print("Forced sign: \(+integer[/3])") // "+1,234,567,890"


// The `+?` and `??` operators return `nil` if the value is zero.
let zero: Decimal = 0
let nonzero: Decimal = 55%

// `+?` is for signed, optional output.
print(+?zero[..] as Any) // nil
print(+?nonzero[..] as Any) // "+0.55"

// `??` is for optional output without a forced sign.
print(??zero[..] as Any) // nil
print(??nonzero[..] as Any) // "0.55"


// You can use the same formatting DSL directly on `Double` types.
let pi: Double = 3.1415926535

print("π as permille (1 place): \(pi[‰1])") // "3141.6‰"
print("π with 4 places and a leading plus sign: \(+pi[..4])") // "+3.1416"

// You can also convert a `Decimal` to a `Double`.
let double: Double = .init(125%)
print("125% as a Double is: \(double)") // "1.25"
print("125% as a Double is: \(double[..3])") // "1.250"

// Beware that “natural” precision for a ``Double`` may include many decimal places.
let inexact: Double = 1 / 3
print("1/3 as a Double is: \(+inexact[..])") // "+0.3333333333333333"
