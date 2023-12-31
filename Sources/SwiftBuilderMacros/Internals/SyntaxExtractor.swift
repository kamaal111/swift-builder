//
//  SyntaxExtractor.swift
//  
//
//  Created by Kamaal M Farah on 30/12/2023.
//

import SwiftSyntax
import SwiftSyntaxMacros

struct SyntaxExtractor {
    private init() { }

    static func extractVariableDeclarations(_ classDecleration: ClassDeclSyntax) -> [VariableDeclSyntax] {
        var variableDeclarations = [VariableDeclSyntax]()
        for member in classDecleration.memberBlock.members {
            guard let variableDeclaration = member.decl.as(VariableDeclSyntax.self) else { continue }

            variableDeclarations.append(variableDeclaration)
        }

        return variableDeclarations
    }

    static func extractVariableNames(_ variableDeclaration: VariableDeclSyntax) -> [TokenSyntax] {
        variableDeclaration
            .bindings
            .compactMap({ binding in extractIdentifier(binding) })
    }

    static func extractIdentifier(_ binding: PatternBindingListSyntax.Element) -> TokenSyntax? {
        binding.pattern.as(IdentifierPatternSyntax.self)?.identifier
    }

    static func extractTypeAnnotation(_ binding: PatternBindingListSyntax.Element) -> TokenSyntax? {
        guard let typeAnnotation = binding.typeAnnotation?.type else { return nil }

        if let optionalTypeAnnotation = typeAnnotation.as(OptionalTypeSyntax.self) {
            if let wrappedType = optionalTypeAnnotation.wrappedType.as(IdentifierTypeSyntax.self) {
                return "\(wrappedType.name)?"
            }
            if let wrappedType = optionalTypeAnnotation.wrappedType.as(TupleTypeSyntax.self) {
                return "\(wrappedType)?"
            }
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
