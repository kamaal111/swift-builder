//
//  LazyObjectBuilder.swift
//
//
//  Created by Kamaal M Farah on 28/12/2023.
//

import SwiftSyntax
import SwiftSyntaxMacros

enum LazyObjectBuilderErrors: CustomStringConvertible, Error {
    case unsupportedType
    case insufficientProperties

    var description: String {
        switch self {
        case .unsupportedType: "@\(String(describing: LazyObjectBuilder.self)) only supports classes"
        case .insufficientProperties: "Must have atleast mutable 1 property"
        }
    }
}

public struct LazyObjectBuilder: MemberMacro {
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

        guard let mutableVariableDeclarations, let objectName else { throw LazyObjectBuilderErrors.unsupportedType }
        guard !mutableVariableDeclarations.isEmpty else { throw LazyObjectBuilderErrors.insufficientProperties }

        let variableNames = mutableVariableDeclarations
            .flatMap({ variableDeclaration in SyntaxExtractor.extractVariableNames(variableDeclaration) })
        let propertiesEnum = try SyntaxGenerators.generatePropertiesEnum(
            variableNames,
            named: "LazyObjectBuilderProperties"
        )
        return [
            DeclSyntax("typealias LazyBuildableSelf = \(objectName)"),
            DeclSyntax("typealias LazyBuildableProperties = LazyObjectBuilderProperties"),
            DeclSyntax(propertiesEnum)
        ]
    }
}
