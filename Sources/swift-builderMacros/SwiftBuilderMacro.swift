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

        let className = classDecleration.name
        let mutableVariableDeclarations = getMutableVariablesDeclarations(classDecleration)
        let setters = try transformVariableDeclarationBindingsToSetters(mutableVariableDeclarations, className: className)

        return setters
            .map { setter in DeclSyntax(setter) }
    }

    private static func transformVariableDeclarationBindingsToSetters(
        _ variableDeclarations: [VariableDeclSyntax],
        className: TokenSyntax
    ) throws -> [FunctionDeclSyntax] {
        try variableDeclarations
            .flatMap { variableDeclaration in
                try variableDeclaration.bindings
                    .compactMap { binding in try transformToSetter(binding, className: className) }
            }
    }

    private static func getMutableVariablesDeclarations(_ classDecleration: ClassDeclSyntax) -> [VariableDeclSyntax] {
        var variableDeclarations = [VariableDeclSyntax]()
        for member in classDecleration.memberBlock.members {
            guard let variableDeclaration = member.decl.as(VariableDeclSyntax.self) else { continue }
            guard variableDeclaration.bindingSpecifier.text == "var" else { continue }

            variableDeclarations.append(variableDeclaration)
        }

        return variableDeclarations
    }

    private static func transformToSetter(
        _ binding: PatternBindingListSyntax.Element,
        className: TokenSyntax
    ) throws -> FunctionDeclSyntax? {
        guard let typeAnnotation = extractTypeAnnotation(binding) else { return nil }
        guard let identifier = extractIdentifier(binding) else { return nil }

        let header = makeSetterMethodHeader(
            identifier: identifier,
            typeAnnotation: typeAnnotation,
            className: className
        )
        return try FunctionDeclSyntax(header, bodyBuilder: {
            CodeBlockItemListSyntax("""
            self.\(identifier) = \(identifier)
            return self
            """)
        })
    }

    private static func makeSetterMethodHeader(
        identifier: TokenSyntax,
        typeAnnotation: TokenSyntax,
        className: TokenSyntax
    ) -> SyntaxNodeString {
        "func set\(raw: identifier.text.capitalized)(_ \(identifier): \(typeAnnotation)) -> \(className)"
    }

    private static func extractIdentifier(_ binding: PatternBindingListSyntax.Element) -> TokenSyntax? {
        binding.pattern.as(IdentifierPatternSyntax.self)?.identifier
    }

    private static func extractTypeAnnotation(_ binding: PatternBindingListSyntax.Element) -> TokenSyntax? {
        guard let typeAnnotation = binding.typeAnnotation?.type else { return nil }

        if let optionalTypeAnnotation = typeAnnotation.as(OptionalTypeSyntax.self),
           let wrappedType = optionalTypeAnnotation.wrappedType.as(IdentifierTypeSyntax.self) {
            return "\(wrappedType.name)?"
        }

        if let typeAnnotation = typeAnnotation.as(IdentifierTypeSyntax.self) {
            return typeAnnotation.name
        }

        return nil
    }
}

@main
struct SwiftBuilderPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ObjectBuilder.self
    ]
}
