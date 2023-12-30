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
        try generateSetters(variableDeclarations) { binding in
            try generateSetter(binding, returnType: objectName) { identifier in
                """
                self.\(identifier) = \(identifier)
                return self
                """
            }
        }
    }

    static func generateDynamicSetters(
        _ variableDeclarations: [VariableDeclSyntax],
        builderName: TokenSyntax,
        containerPropertyName: TokenSyntax
    ) throws -> [FunctionDeclSyntax] {
        try generateSetters(variableDeclarations) { binding in
            try generateSetter(binding, returnType: builderName) { identifier in
                """
                self.\(containerPropertyName)[.\(identifier)] = \(identifier) as Any
                return self
                """
            }
        }
    }

    static func generatePropertiesEnum(
        _ caseNames: [TokenSyntax],
        named: TokenSyntax
    ) throws -> EnumDeclSyntax {
        try EnumDeclSyntax("enum \(named)") {
            for name in caseNames {
                try EnumCaseDeclSyntax("case \(name)")
            }
        }
    }

    static func generateInitializedPrivateProperty(named: TokenSyntax, value: TokenSyntax) throws -> VariableDeclSyntax {
        try VariableDeclSyntax("private var \(named) = \(value)")
    }

    static func generateTypeAlias(name: TokenSyntax, value: TokenSyntax) throws -> TypeAliasDeclSyntax {
        try TypeAliasDeclSyntax("typealias \(name) = \(value)")
    }

    private static func generateSetter(
        _ binding: PatternBindingListSyntax.Element,
        returnType: TokenSyntax,
        body: (TokenSyntax) -> CodeBlockItemListSyntax
    ) throws -> FunctionDeclSyntax? {
        guard let typeAnnotation = SyntaxExtractor.extractTypeAnnotation(binding) else { return nil }
        guard let identifier = SyntaxExtractor.extractIdentifier(binding) else { return nil }

        let header = SyntaxNodeString(
            stringLiteral: "func set\(identifier.text.capitalized)(_ \(identifier): \(typeAnnotation)) -> \(returnType)"
        )
        return try FunctionDeclSyntax(header, bodyBuilder: {
            body(identifier)
        })
    }

    private static func generateSetters(
        _ variableDeclarations: [VariableDeclSyntax],
        body: (PatternBindingListSyntax.Element) throws -> FunctionDeclSyntax?
    ) throws -> [FunctionDeclSyntax] {
        try variableDeclarations
            .flatMap({ variableDeclaration in
                try variableDeclaration
                    .bindings
                    .compactMap({ binding in
                        try body(binding)
                    })
            })
    }
}
