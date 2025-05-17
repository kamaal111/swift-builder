//
//  Builder.swift
//
//
//  Created by Kamaal M Farah on 28/12/2023.
//

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

enum BuilderErrors: CustomStringConvertible, Error {
    case unsupportedType
    case insufficientProperties
    case invalidType

    var description: String {
        switch self {
        case .unsupportedType: "Object must be either a class or a struct"
        case .insufficientProperties: "Object must have atleast 1 property"
        case .invalidType: "Object must conform to `Buildable` protocol"
        }
    }
}

private let PROPERTIES_ENUM_NAME = TokenSyntax("BuildableProperties")
private let BUILDER_NAME = TokenSyntax("Builder")
private let BUILDER_CONTAINER_NAME = TokenSyntax("container")

public struct Builder: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        var objectName: TokenSyntax?
        if let classDecleration = declaration.as(ClassDeclSyntax.self) {
            objectName = classDecleration.name
        }
        if let structDecleration = declaration.as(StructDeclSyntax.self) {
            objectName = structDecleration.name
        }
        guard let objectName else { throw BuilderErrors.unsupportedType }

        let inheritsBuildable = declaration
            .inheritanceClause?
            .inheritedTypes
            .first(where: { inheritedType in
                let inheritedTypeText = inheritedType
                    .type
                    .as(IdentifierTypeSyntax.self)?
                    .name
                    .text
                return inheritedTypeText == "Buildable"
            }) != nil
        guard inheritsBuildable else { throw BuilderErrors.invalidType }

        let variableDeclarations = SyntaxExtractor.extractVariableDeclarations(declaration)
        guard !variableDeclarations.isEmpty else { throw BuilderErrors.insufficientProperties }

        let variableNames = variableDeclarations
            .flatMap({ variableDeclaration in SyntaxExtractor.extractVariableNames(variableDeclaration) })
        let isPublic = declaration.modifiers
            .first(where: { modifier in modifier.name.text == "public" }) != nil
        let propertiesEnum = try SyntaxGenerators.generatePropertiesEnum(
            variableNames,
            named: PROPERTIES_ENUM_NAME,
            isPublic: isPublic
        )
        let typealiasPrefix: SyntaxNodeString = if isPublic { "public " } else { "" }
        let lazyBuildSelfTypeAlias = try TypeAliasDeclSyntax(
            "\(typealiasPrefix)typealias BuildableSelf = \(objectName)"
        )
        let lazyBuildablePropertiesTypeAlias = try TypeAliasDeclSyntax(
            "\(typealiasPrefix)typealias BuildableContainerProperties = \(PROPERTIES_ENUM_NAME)"
        )
        let builderClass = try makeBuilderClass(
            variableDeclarations: variableDeclarations,
            objectName: objectName,
            isPublic: isPublic
        )

        return [
            DeclSyntax(lazyBuildSelfTypeAlias),
            DeclSyntax(lazyBuildablePropertiesTypeAlias),
            DeclSyntax(propertiesEnum),
            DeclSyntax(builderClass)
        ]
    }

    private static func makeBuilderClass(
        variableDeclarations: [VariableDeclSyntax],
        objectName: TokenSyntax,
        isPublic: Bool
    ) throws -> ClassDeclSyntax {
        let setters = try SyntaxGenerators.generateSetters(
            variableDeclarations,
            builderName: BUILDER_NAME,
            containerPropertyName: BUILDER_CONTAINER_NAME,
            isPublic: isPublic
        )
        let variableNamesAndTypeAnnotations = variableDeclarations
            .flatMap({ variableDeclaration in
                SyntaxExtractor.extractVariableNamesAndTypeAnnotations(variableDeclaration)
            })
        let publicPrefixIfIsPublic: SyntaxNodeString = if isPublic { "public " } else { "" }
        return try ClassDeclSyntax("\(publicPrefixIfIsPublic)class \(BUILDER_NAME)") {
            try VariableDeclSyntax("private var \(BUILDER_CONTAINER_NAME) = [\(PROPERTIES_ENUM_NAME): Any]()")
            try InitializerDeclSyntax("\(publicPrefixIfIsPublic)init()") { }
            for setter in setters {
                setter
            }
            try FunctionDeclSyntax("\(publicPrefixIfIsPublic)func build() -> Result<\(objectName), BuilderErrors>") {
                try GuardStmtSyntax("guard \(objectName).validate(container) else") {
                    "return .failure(.validationError)"
                }
                try ForStmtSyntax("for property in BuildableContainerProperties.allCases") {
                    try SwitchExprSyntax("switch property") {
                        for (variableName, typeAnnotations) in variableNamesAndTypeAnnotations {
                            SwitchCaseSyntax("""
                            case .\(variableName):
                                \(raw: makeOptionalCheckForBuildValidator(typeAnnotation: typeAnnotations))
                            """)
                        }
                    }
                }
                CodeBlockItemListSyntax("return .success(\(objectName).build(container))")
            }
        }
    }

    private static func makeOptionalCheckForBuildValidator(
        typeAnnotation: TypeAnnotationInfo
    ) -> CodeBlockItemListSyntax {
        if typeAnnotation.isOptional {
            return "break"
        }

        return """
        if container[property] == nil {
                return .failure(.validationError)
        }
        """
    }
}
