//
//  Builder.swift
//
//
//  Created by Kamaal M Farah on 28/12/2023.
//

import SwiftSyntax
import SwiftSyntaxMacros

enum BuilderErrors: CustomStringConvertible, Error {
    case unsupportedType
    case insufficientProperties

    var description: String {
        switch self {
        case .unsupportedType: "@\(String(describing: Builder.self)) only supports classes"
        case .insufficientProperties: "Must have atleast mutable 1 property"
        }
    }
}

private let PROPERTIES_ENUM_NAME = TokenSyntax("BuildableProperties")
private let BUILDER_NAME = TokenSyntax("Builder")
private let BUILDER_CONTAINER_NAME = TokenSyntax("container")

public struct Builder: MemberMacro {
    public static func expansion(
        of attribute: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        var objectName: TokenSyntax?
        var variableDeclarations: [VariableDeclSyntax]?
        if let classDecleration = declaration.as(ClassDeclSyntax.self) {
            objectName = classDecleration.name
            variableDeclarations = SyntaxExtractor.extractVariableDeclarations(classDecleration)
        }

        // TODO: Support struct as well

        guard let variableDeclarations, let objectName else { throw BuilderErrors.unsupportedType }
        guard !variableDeclarations.isEmpty else { throw BuilderErrors.insufficientProperties }

        let variableNames = variableDeclarations
            .flatMap({ variableDeclaration in SyntaxExtractor.extractVariableNames(variableDeclaration) })
        let propertiesEnum = try SyntaxGenerators.generatePropertiesEnum(
            variableNames,
            named: PROPERTIES_ENUM_NAME
        )
        let lazyBuildSelfTypeAlias = try TypeAliasDeclSyntax("typealias BuildableSelf = \(objectName)")
        let lazyBuildablePropertiesTypeAlias = try TypeAliasDeclSyntax(
            "typealias BuildableContainerProperties = \(PROPERTIES_ENUM_NAME)"
        )
        let builderClass = try makeBuilderClass(variableDeclarations: variableDeclarations, objectName: objectName)

        return [
            DeclSyntax(lazyBuildSelfTypeAlias),
            DeclSyntax(lazyBuildablePropertiesTypeAlias),
            DeclSyntax(propertiesEnum),
            DeclSyntax(builderClass)
        ]
    }

    private static func makeBuilderClass(
        variableDeclarations: [VariableDeclSyntax],
        objectName: TokenSyntax
    ) throws -> ClassDeclSyntax{
        let setters = try SyntaxGenerators.generateSetters(
            variableDeclarations,
            builderName: BUILDER_NAME,
            containerPropertyName: BUILDER_CONTAINER_NAME
        )
        return try ClassDeclSyntax("class \(BUILDER_NAME)") {
            try VariableDeclSyntax("private var \(BUILDER_CONTAINER_NAME) = [\(PROPERTIES_ENUM_NAME): Any]()")
            for setter in setters {
                setter
            }
            try FunctionDeclSyntax("func build() throws -> \(objectName)") {
                try GuardStmtSyntax("guard \(objectName).validate(container) else") {
                    "throw BuilderErrors.validationError"
                }
                CodeBlockItemListSyntax("return \(objectName).build(container)")
            }
        }
    }
}
