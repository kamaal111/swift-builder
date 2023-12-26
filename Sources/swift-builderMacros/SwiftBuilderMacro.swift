//
//  SwiftBuilderMacro.swift
//
//
//  Created by Kamaal M Farah on 26/12/2023.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct ObjectBuilder: DeclarationMacro {
    public static func expansion(
        of node: some SwiftSyntax.FreestandingMacroExpansionSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        return []
    }
}

@main
struct swift_builderPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ObjectBuilder.self
    ]
}
