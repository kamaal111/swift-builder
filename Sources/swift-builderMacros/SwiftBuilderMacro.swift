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
        guard let classDecleration = declaration.as(ClassDeclSyntax.self) else {
            // TODO: Emit error here
            return []
        }

        let className = classDecleration.name.text
        let setters = try classDecleration.memberBlock.members
            .compactMap({ member in member.decl.as(VariableDeclSyntax.self) })
            .filter({ variableMember in variableMember.bindingSpecifier.text == "var" })
            .compactMap({ variableMember in
                return try variableMember.bindings
                    .compactMap({ binding -> FunctionDeclSyntax? in
                        guard let id = binding.pattern.as(IdentifierPatternSyntax.self) else { return nil }
                        guard let typeAnnotation = binding.typeAnnotation?.type else { return nil }

                        let stringTypeAnnotation: String
                        if let optionalTypeAnnotation = typeAnnotation.as(OptionalTypeSyntax.self),
                           let wrappedType = optionalTypeAnnotation.wrappedType.as(IdentifierTypeSyntax.self) {
                            stringTypeAnnotation = "\(wrappedType.name)?"
                        } else if let typeAnnotation = typeAnnotation.as(IdentifierTypeSyntax.self) {
                            stringTypeAnnotation = typeAnnotation.name.text
                        } else {
                            return nil
                        }

                        let identifier = id.identifier
                        let header = "func set\(identifier.text.capitalized)(_ \(identifier): \(stringTypeAnnotation)) -> \(className)"
                        return try FunctionDeclSyntax(SyntaxNodeString(stringLiteral: header)) {
                            CodeBlockItemListSyntax("""
                            self.\(identifier) = \(identifier)
                            return self
                            """)
                        }
                    })
            })
            .flatMap({ setter in setter })

        return setters
            .map({ setter in DeclSyntax(setter) })
    }
}

@main
struct SwiftBuilderPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ObjectBuilder.self
    ]
}
