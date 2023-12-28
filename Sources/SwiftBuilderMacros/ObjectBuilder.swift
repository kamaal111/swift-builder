//
//  ObjectBuilder.swift
//  
//
//  Created by Kamaal M Farah on 28/12/2023.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

enum ObjectBuilderErrors: CustomStringConvertible, Error {
    case unsupportedType

    var description: String {
        switch self {
        case .unsupportedType: "@ObjectBuilder only supports classes"
        }
    }
}

public struct ObjectBuilder: MemberMacro {
    public static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        var objectName: TokenSyntax?
        var mutableVariableDeclarations: [VariableDeclSyntax]?
        if let classDecleration = declaration.as(ClassDeclSyntax.self) {
            objectName = classDecleration.name
            mutableVariableDeclarations = getMutableVariablesDeclarations(classDecleration)
        }

        // TODO: Support struct as well

        guard let objectName, let mutableVariableDeclarations else { throw ObjectBuilderErrors.unsupportedType }

        let setters = try transformVariableDeclarationBindingsToSetters(
            mutableVariableDeclarations,
            className: objectName
        )
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

        if let typeAnnotation = typeAnnotation.as(SomeOrAnyTypeSyntax.self),
           let constraint = typeAnnotation.constraint.as(IdentifierTypeSyntax.self) {
            return "\(typeAnnotation.someOrAnySpecifier) \(constraint.name)"
        }

        return nil
    }
}
