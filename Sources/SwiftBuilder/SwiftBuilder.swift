//
//  SwiftBuilder.swift
//
//
//  Created by Kamaal M Farah on 26/12/2023.
//

@attached(member, names: arbitrary)
public macro ObjectBuilder() = #externalMacro(module: "SwiftBuilderMacros", type: "ObjectBuilder")

@attached(member, conformances: LazyBuildable)
@attached(member, names: arbitrary)
public macro LazyObjectBuilder() = #externalMacro(module: "SwiftBuilderMacros", type: "LazyObjectBuilder")

public enum LazyObjectBuilderErrors: Error {
    case validationError
}

public protocol LazyBuildable {
    associatedtype LazyBuildableProperties: Hashable
    associatedtype LazyBuildableSelf: LazyBuildable

    static func validate(_ container: [LazyBuildableProperties: Any]) -> Bool
    static func build(_ container: [LazyBuildableProperties: Any]) -> LazyBuildableSelf
}
