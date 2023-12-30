//
//  SyntaxTransformer.swift
//  
//
//  Created by Kamaal M Farah on 30/12/2023.
//

import SwiftSyntax
import SwiftSyntaxBuilder

struct SyntaxTransformer {
    private init() { }

    static func transformToSetters(
        _ variableDeclarations: [VariableDeclSyntax],
        className: TokenSyntax
    ) throws -> [FunctionDeclSyntax] {
        try variableDeclarations
            .flatMap { variableDeclaration in
                try variableDeclaration.bindings
                    .compactMap { binding in try transformToSetter(binding, className: className) }
            }
    }

    private static func transformToSetter(
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
