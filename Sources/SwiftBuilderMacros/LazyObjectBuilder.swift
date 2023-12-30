//
//  LazyObjectBuilder.swift
//
//
//  Created by Kamaal M Farah on 28/12/2023.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public struct LazyObjectBuilder: MemberMacro {
    public static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return []
    }
}
