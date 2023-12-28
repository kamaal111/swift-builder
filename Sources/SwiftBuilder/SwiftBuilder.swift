//
//  SwiftBuilder.swift
//
//
//  Created by Kamaal M Farah on 26/12/2023.
//

@attached(member, names: arbitrary)
public macro ObjectBuilder() = #externalMacro(module: "SwiftBuilderMacros", type: "ObjectBuilder")
