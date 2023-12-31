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
        builderName: TokenSyntax,
        containerPropertyName: TokenSyntax,
        isPublic: Bool
    ) throws -> [FunctionDeclSyntax] {
        try mapBindingsToFunctions(variableDeclarations) { binding in
            try generateSetter(binding, isPublic: isPublic, returnType: builderName) { identifier in
                """
                self.\(containerPropertyName)[.\(identifier)] = \(identifier) as Any
                return self
                """
            }
        }
    }

    static func generatePropertiesEnum(
        _ caseNames: [TokenSyntax],
        named: TokenSyntax,
        isPublic: Bool
    ) throws -> EnumDeclSyntax {
        let publicPrefixIfIsPublic: SyntaxNodeString = if isPublic { "public " } else { "" }
        return try EnumDeclSyntax("\(publicPrefixIfIsPublic)enum \(named): CaseIterable") {
            for name in caseNames {
                try EnumCaseDeclSyntax("case \(name)")
            }
        }
    }

    private static func generateSetter(
        _ binding: PatternBindingListSyntax.Element,
        isPublic: Bool,
        returnType: TokenSyntax,
        body: (TokenSyntax) -> CodeBlockItemListSyntax
    ) throws -> FunctionDeclSyntax? {
        guard let typeAnnotation = SyntaxExtractor.extractTypeAnnotation(binding) else { return nil }
        guard let identifier = SyntaxExtractor.extractIdentifier(binding) else { return nil }

        let identifierText = identifier.text
        let methodName = "set\(identifierText.prefix(1).uppercased())\(identifierText.dropFirst())"
        let headerPrefix: SyntaxNodeString = if isPublic { "public " } else { "" }
        let header = SyntaxNodeString(
            "\(headerPrefix)func \(raw: methodName)(_ \(identifier): \(typeAnnotation.fullType)) -> \(returnType)"
        )
        return try FunctionDeclSyntax(header, bodyBuilder: {
            body(identifier)
        })
    }

    private static func mapBindingsToFunctions(
        _ variableDeclarations: [VariableDeclSyntax],
        transformer: (PatternBindingListSyntax.Element) throws -> FunctionDeclSyntax?
    ) throws -> [FunctionDeclSyntax] {
        try variableDeclarations
            .flatMap({ variableDeclaration in
                try variableDeclaration
                    .bindings
                    .compactMap({ binding in
                        try transformer(binding)
                    })
            })
    }
}
