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
        var mutableVariableDeclarations: [VariableDeclSyntax]?
        if let classDecleration = declaration.as(ClassDeclSyntax.self) {
            objectName = classDecleration.name
            mutableVariableDeclarations = SyntaxExtractor.extractMutableVariablesDeclarations(classDecleration)
        }

        // TODO: Support struct as well

        guard let mutableVariableDeclarations, let objectName else { throw BuilderErrors.unsupportedType }
        guard !mutableVariableDeclarations.isEmpty else { throw BuilderErrors.insufficientProperties }

        let variableNames = mutableVariableDeclarations
            .flatMap({ variableDeclaration in SyntaxExtractor.extractVariableNames(variableDeclaration) })
        let propertiesEnum = try SyntaxGenerators.generatePropertiesEnum(
            variableNames,
            named: PROPERTIES_ENUM_NAME
        )
        let lazyBuildSelfTypeAlias = try SyntaxGenerators.generateTypeAlias(
            name: "BuildableSelf",
            value: objectName
        )
        let lazyBuildablePropertiesTypeAlias = try SyntaxGenerators.generateTypeAlias(
            name: "BuildableContainerProperties",
            value: PROPERTIES_ENUM_NAME
        )
        let setters = try SyntaxGenerators.generateDynamicSetters(
            mutableVariableDeclarations,
            builderName: BUILDER_NAME,
            containerPropertyName: BUILDER_CONTAINER_NAME
        )
        let builderClass = try ClassDeclSyntax("class \(BUILDER_NAME)") {
            try SyntaxGenerators.generateInitializedPrivateProperty(
                named: BUILDER_CONTAINER_NAME,
                value: "[\(PROPERTIES_ENUM_NAME): Any]()"
            )
            for setter in setters {
                setter
            }
            try FunctionDeclSyntax("func build() throws -> \(objectName)") {
                CodeBlockItemListSyntax("""
                guard \(objectName).validate(container) else { throw BuilderErrors.validationError }
                return \(objectName).build(container)
                """)
            }
        }

        return [
            DeclSyntax(lazyBuildSelfTypeAlias),
            DeclSyntax(lazyBuildablePropertiesTypeAlias),
            DeclSyntax(propertiesEnum),
            DeclSyntax(builderClass)
        ]
    }
}
