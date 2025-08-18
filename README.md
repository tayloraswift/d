[![Tests](https://github.com/ordo-one/d/actions/workflows/Tests.yml/badge.svg)](https://github.com/ordo-one/d/actions/workflows/Tests.yml)
[![Documentation](https://github.com/ordo-one/d/actions/workflows/Documentation.yml/badge.svg)](https://github.com/ordo-one/d/actions/workflows/Documentation.yml)

D is a pure Swift decimal arithmetic library and formatting DSL.

[documentation](https://swiftinit.org/docs/d) ·
[license](LICENSE)


## Requirements

The d library requires Swift 6.1 or later.


| Platform | Status |
| -------- | ------ |
| 🐧 Linux | [![Tests](https://github.com/ordo-one/d/actions/workflows/Tests.yml/badge.svg)](https://github.com/ordo-one/d/actions/workflows/Tests.yml) |
| 🍏 Darwin | [![Tests](https://github.com/ordo-one/d/actions/workflows/Tests.yml/badge.svg)](https://github.com/ordo-one/d/actions/workflows/Tests.yml) |
| 🍏 Darwin (iOS) | [![iOS](https://github.com/ordo-one/d/actions/workflows/iOS.yml/badge.svg)](https://github.com/ordo-one/d/actions/workflows/iOS.yml) |
| 🍏 Darwin (tvOS) | [![tvOS](https://github.com/ordo-one/d/actions/workflows/tvOS.yml/badge.svg)](https://github.com/ordo-one/d/actions/workflows/tvOS.yml) |
| 🍏 Darwin (visionOS) | [![visionOS](https://github.com/ordo-one/d/actions/workflows/visionOS.yml/badge.svg)](https://github.com/ordo-one/d/actions/workflows/visionOS.yml) |
| 🍏 Darwin (watchOS) | [![watchOS](https://github.com/ordo-one/d/actions/workflows/watchOS.yml/badge.svg)](https://github.com/ordo-one/d/actions/workflows/watchOS.yml) |


[Check deployment minimums](https://swiftinit.org/docs/d#ss:platform-requirements)


## Examples

### Decimal arithmetic

The ``Decimal`` type provides a foundation for precise, base-10 arithmetic, avoiding the floating-point inaccuracies of types like ``Double``. You can initialize a ``Decimal`` by specifying its `units` and `power`, or directly from an integer literal.

Postfix operators (`%`, `‰`, `‱`) offer a convenient shorthand for creating percentage, permille, and basis point values.

```swift
let a: Decimal = .init(units: 15, power: -1) // Represents 1.5
let b: Decimal = 2
```

Postfix operators provide a convenient way to express common values.

```swift
let _: Decimal = 150% // 1.5
let _: Decimal = 500‰ // 0.5
let _: Decimal = 250‱ // 0.025
```

All standard arithmetic operations are precise. The library handles scaling operands to a common power automatically.

```swift
let sum: Decimal = 150% + 500‰
print("150% + 500‰ = \(sum[..])") // "2.000"

let difference: Decimal = 150% - 500‰
print("150% - 500‰ = \(difference[..])") // "1.000"
```

You can also normalize a ``Decimal`` to simplify its internal representation by removing trailing zeros from its `units`.

```swift
let unnormalized: Decimal = .init(units: 1200, power: -1) // 120.0
let normalized: Decimal = unnormalized.normalized()

print("Normalized \(unnormalized[..]) is \(normalized[..])")
// Normalized 120.0 is 120
```


### Formatting DSL

The library includes a powerful and expressive Domain-Specific Language (DSL) for formatting numbers.

Use `..` followed by a number to specify the number of decimal places.

```swift
let value: Decimal = 12345‱ // Represents 1.2345

print("Value with 2 places: \(value[..2])") // "1.23"
print("Value with 5 places: \(value[..5])") // "1.23450"
```

Omitting the digits specifier (`[..]`) formats the value with its natural number of decimal places.

```swift
print("Value with natural places: \(value[..])") // "1.2345"
```

Use the special format sigils (`%`, `‰`, or `‱`) to format the number as a percentage, permille, or basis point value, optionally followed by a number to specify the desired precision.

```swift
print("As percentage (natural): \(value[%])") // "123.45%"
print("As permillage (natural): \(value[‰])") // "1234.5‰"
print("As basis points (natural): \(value[‱])") // "12345‱"

print("As a percentage (1 place): \(value[%1])") // "123.5%"
print("As a permillage (1 place): \(value[‰1])") // "1234.5‰"
print("As basis points (1 place): \(value[‱1])") // "12345.0‱"

print("As a percentage (3 places): \(value[%3])") // "123.450%"
print("As a permillage (3 places): \(value[‰3])") // "1234.500‰"
print("As basis points (3 places): \(value[‱3])") // "12345.000‱"
```

Prefixing the format expression with `+` will force a sign to be displayed for positive numbers. Negative numbers are always rendered with a Unicode minus sign (`−`) (`U+2212`), not a hyphen.

```swift
print("Forced sign: \(+value[..2])") // "+1.23"
print("Negative sign: \((-value)[%0])") // "−123%"
```

The formatting DSL can help you group digits when displaying standard integer types. Use the `/` operator to specify digit grouping.

```swift
let integer: Int = 1234567890

print("Grouped by 3 (thousands): \(integer[/3])") // "1,234,567,890"
print("Grouped by 2 (hundreds): \(integer[/2])") // "12,34,56,78,90"
print("Grouped by 4 (myriads): \(integer[/4])") // "12,3456,7890"
print("Forced sign: \(+integer[/3])") // "+1,234,567,890"
```


### Zero elision

The library provides two special prefix operators to handle cases where zero values should not be displayed.

The `+?` prefix operator returns a signed string representation of the number, or nil if the number is zero.

```swift
let zero: Decimal = 0
let nonzero: Decimal = 55%

print(+?zero[..] as Any) // nil
print(+?nonzero[..] as Any) // "+0.55"
```

The `??` prefix operator returns a standard string representation of the number, or nil if the number is zero.

```swift
print(??zero[..] as Any) // nil
print(??nonzero[..] as Any) // "0.55"
```

This is not always ergonomic on its own, but can be extremely powerful when coupled with an elision-friendly client API. For example, subscript-assignment patterns dovetail incredibly well with elision prefix operators.

```swift
// Note: HTML DSL not included with this library!
let html: HTML = .init {
    $0[.em] = +?quantity // elides the <em> tag if the value is zero
}
```


### Integration with `Double`

The formatting DSL is also available for the standard ``Double`` type, allowing you to easily format floating-point numbers.

```swift
let pi: Double = 3.1415926535

print("π as permille (1 place): \(pi[‰1])") // "3141.6‰"
print("π with 4 places and a leading plus sign: \(+pi[..4])") // "+3.1416"
```

A ``Decimal`` value can be converted to a ``Double`` through its failable `init(_:)`.

```swift
let double: Double = .init(125%)
print("125% as a Double is: \(double)") // "1.25"
print("125% as a Double is: \(double[..3])") // "1.250"
```

Beware that “natural” precision for a ``Double`` may include many decimal places.

```swift
let inexact: Double = 1 / 3
print("1/3 as a Double is: \(+inexact[..])") // "+0.3333333333333333"
```
