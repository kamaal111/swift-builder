//
//  SyntaxExtractor.swift
//  
//
//  Created by Kamaal M Farah on 30/12/2023.
//

import SwiftSyntax
import SwiftSyntaxMacros

enum SyntaxExtractor {
    static func extractVariableDeclarations(_ declarationGroup: some DeclGroupSyntax) -> [VariableDeclSyntax] {
        var variableDeclarations = [VariableDeclSyntax]()
        for member in declarationGroup.memberBlock.members {
            guard let variableDeclaration = member.decl.as(VariableDeclSyntax.self) else { continue }

            let isNotSetableVariable = variableDeclaration
                .bindings
                .first(where: { binding in binding.accessorBlock != nil }) != nil
            guard !isNotSetableVariable else { continue }

            variableDeclarations.append(variableDeclaration)
        }

        return variableDeclarations
    }

    static func extractVariableNames(_ variableDeclaration: VariableDeclSyntax) -> [TokenSyntax] {
        variableDeclaration
            .bindings
            .compactMap({ binding in extractIdentifier(binding) })
    }

    static func extractVariableNamesAndTypeAnnotations(_ variableDeclaration: VariableDeclSyntax) -> [
        (identifier: TokenSyntax, typeAnnotation: TypeAnnotationInfo)
    ] {
        variableDeclaration
            .bindings
            .compactMap({ binding in
                guard let identifier = extractIdentifier(binding) else { return nil }
                guard let typeAnnotation = extractTypeAnnotation(binding) else { return nil }

                return (identifier, typeAnnotation)
            })
    }

    static func extractIdentifier(_ binding: PatternBindingListSyntax.Element) -> TokenSyntax? {
        binding.pattern.as(IdentifierPatternSyntax.self)?.identifier
    }

    static func extractTypeAnnotation(_ binding: PatternBindingListSyntax.Element) -> TypeAnnotationInfo? {
        guard let typeAnnotation = binding.typeAnnotation?.type else { return nil }

        if let optionalTypeAnnotation = typeAnnotation.as(OptionalTypeSyntax.self) {
            if let wrappedType = optionalTypeAnnotation.wrappedType.as(IdentifierTypeSyntax.self) {
                return TypeAnnotationInfo(name: wrappedType.name, fullType: "\(wrappedType.name)?", isOptional: true)
            }

            if let wrappedType = optionalTypeAnnotation.wrappedType.as(TupleTypeSyntax.self) {
                if let firstElementType = wrappedType.elements.first?.type {
                    let constraint = firstElementType
                        .as(SomeOrAnyTypeSyntax.self)?
                        .constraint
                        .as(IdentifierTypeSyntax.self)
                    if let constraint {
                        return TypeAnnotationInfo(name: constraint.name, fullType: "\(wrappedType)?", isOptional: true)
                    }
                }
            }
        }

        if let typeAnnotation = typeAnnotation.as(IdentifierTypeSyntax.self) {
            return TypeAnnotationInfo(name: typeAnnotation.name, fullType: typeAnnotation.name, isOptional: false)
        }

        if let typeAnnotation = typeAnnotation.as(SomeOrAnyTypeSyntax.self),
           let constraint = typeAnnotation.constraint.as(IdentifierTypeSyntax.self) {
            return TypeAnnotationInfo(name: constraint.name, fullType: constraint.name, isOptional: false)
        }

        return nil
    }
}
