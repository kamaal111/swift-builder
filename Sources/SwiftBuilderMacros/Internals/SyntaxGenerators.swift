//
//  SyntaxGenerators.swift
//
//
//  Created by Kamaal M Farah on 30/12/2023.
//

import SwiftSyntax
import SwiftSyntaxBuilder

struct SyntaxGenerators {
    private init() { }

    static func generateSetters(
        _ variableDeclarations: [VariableDeclSyntax],
        className: TokenSyntax
    ) throws -> [FunctionDeclSyntax] {
        try variableDeclarations
            .flatMap { variableDeclaration in
                try variableDeclaration.bindings
                    .compactMap { binding in try generateSetter(binding, className: className) }
            }
    }

    static func generatePropertiesEnum(propertyNames: [TokenSyntax], objectName: TokenSyntax) throws -> EnumDeclSyntax {
        let mutableVariableNamesJoinedByCommas = propertyNames.map(\.text).joined(separator: ",")
        return try EnumDeclSyntax("""
        enum \(raw: objectName.text)Properties {
            case \(raw: mutableVariableNamesJoinedByCommas)
        }
        """)
    }

    private static func generateSetter(
        _ binding: PatternBindingListSyntax.Element,
        className: TokenSyntax
    ) throws -> FunctionDeclSyntax? {
        guard let typeAnnotation = SyntaxExtractor.extractTypeAnnotation(binding) else { return nil }
        guard let identifier = SyntaxExtractor.extractIdentifier(binding) else { return nil }

        let header = SyntaxNodeString(
            stringLiteral: "func set\(identifier.text.capitalized)(_ \(identifier): \(typeAnnotation)) -> \(className)"
        )
        return try FunctionDeclSyntax(header, bodyBuilder: {
            CodeBlockItemListSyntax("""
            self.\(identifier) = \(identifier)
            return self
            """)
        })
    }
}
