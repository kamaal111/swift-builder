//
//  SwiftBuilderMacro.swift
//
//
//  Created by Kamaal M Farah on 26/12/2023.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder
import SwiftCompilerPlugin

public struct ObjectBuilder: MemberMacro {
    public static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return []
    }
}

@main
struct SwiftBuilderPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ObjectBuilder.self
    ]
}
