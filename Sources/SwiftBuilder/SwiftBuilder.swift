//
//  SwiftBuilder.swift
//
//
//  Created by Kamaal M Farah on 26/12/2023.
//

@attached(member, names: arbitrary)
public macro ObjectBuilder() = #externalMacro(module: "SwiftBuilderMacros", type: "ObjectBuilder")

@attached(member, conformances: Buildable)
@attached(member, names: arbitrary)
public macro Builder() = #externalMacro(module: "SwiftBuilderMacros", type: "Builder")

public enum BuilderErrors: Error, Equatable {
    case validationError
}

public protocol Buildable {
    associatedtype BuildableContainerProperties: Hashable & CaseIterable
    associatedtype BuildableSelf: Buildable

    static func validate(_ container: [BuildableContainerProperties: Any]) -> Bool
    static func build(_ container: [BuildableContainerProperties: Any]) -> BuildableSelf
}

extension Buildable {
    public static func validate(_ container: [BuildableContainerProperties: Any]) -> Bool {
        true
    }
}
