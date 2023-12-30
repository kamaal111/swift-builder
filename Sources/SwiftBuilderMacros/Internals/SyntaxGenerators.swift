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

    static func generateDirectSetters(
        _ variableDeclarations: [VariableDeclSyntax],
        objectName: TokenSyntax
    ) throws -> [FunctionDeclSyntax] {
        try variableDeclarations
            .flatMap { variableDeclaration in
                try variableDeclaration.bindings
                    .compactMap { binding in try generateDirectSetter(binding, objectName: objectName) }
            }
    }

    static func generatePropertiesEnum(
        _ caseNames: [TokenSyntax],
        named: String
    ) throws -> EnumDeclSyntax {
        try EnumDeclSyntax("""
        enum \(raw: named) {
            case \(raw: caseNames.map(\.text).joined(separator: ", "))
        }
        """)
    }

    private static func generateDirectSetter(
        _ binding: PatternBindingListSyntax.Element,
        objectName: TokenSyntax
    ) throws -> FunctionDeclSyntax? {
        guard let typeAnnotation = SyntaxExtractor.extractTypeAnnotation(binding) else { return nil }
        guard let identifier = SyntaxExtractor.extractIdentifier(binding) else { return nil }

        let header = SyntaxNodeString(
            stringLiteral: "func set\(identifier.text.capitalized)(_ \(identifier): \(typeAnnotation)) -> \(objectName)"
        )
        return try FunctionDeclSyntax(header, bodyBuilder: {
            CodeBlockItemListSyntax("""
            self.\(identifier) = \(identifier)
            return self
            """)
        })
    }
}
