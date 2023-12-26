//
//  SwiftBuilder.swift
//
//
//  Created by Kamaal M Farah on 26/12/2023.
//

/// A macro that produces both a value and a string containing the
/// source code that generated the value. For example,
///
///     #stringify(x + y)
///
/// produces a tuple `(x + y, "x + y")`.
@freestanding(expression)
public macro stringify<T>(_ value: T) -> (T, String) = #externalMacro(module: "swift_builderMacros", type: "StringifyMacro")
