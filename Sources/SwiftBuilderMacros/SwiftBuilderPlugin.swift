//
//  SwiftBuilderMacro.swift
//
//
//  Created by Kamaal M Farah on 26/12/2023.
//

import SwiftSyntaxMacros
import SwiftCompilerPlugin

@main
struct SwiftBuilderPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ObjectBuilder.self,
        LazyObjectBuilder.self
    ]
}
