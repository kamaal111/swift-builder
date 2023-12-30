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

    var description: String {
        switch self {
        case .unsupportedType: "@\(String(describing: LazyObjectBuilder.self)) only supports classes"
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

        guard let objectName, let mutableVariableDeclarations else { throw LazyObjectBuilderErrors.unsupportedType }

        let mutableVariableNames = SyntaxExtractor.extractVariableNames(mutableVariableDeclarations)
        guard !mutableVariableNames.isEmpty else { return [] }

        let propertiesEnum = try SyntaxGenerators.generatePropertiesEnum(
            propertyNames: mutableVariableNames,
            objectName: objectName
        )
        return [
            DeclSyntax(propertiesEnum)
        ]
    }
}
