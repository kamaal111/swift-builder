//
//  SwiftBuilder.swift
//
//
//  Created by Kamaal M Farah on 26/12/2023.
//

@attached(member, names: named(func))
public macro ObjectBuilder() = #externalMacro(module: "swift_builderMacros", type: "ObjectBuilder")
