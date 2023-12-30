//
//  ObjectBuilder.swift
//  
//
//  Created by Kamaal M Farah on 28/12/2023.
//

import SwiftSyntax
import SwiftSyntaxMacros

enum ObjectBuilderErrors: CustomStringConvertible, Error {
    case unsupportedType

    var description: String {
        switch self {
        case .unsupportedType: "@\(String(describing: ObjectBuilder.self)) only supports classes"
        }
    }
}

public struct ObjectBuilder: MemberMacro {
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

        guard let objectName, let mutableVariableDeclarations else { throw ObjectBuilderErrors.unsupportedType }

        return try SyntaxGenerators.generateDirectSetters(mutableVariableDeclarations, objectName: objectName)
            .map { setter in DeclSyntax(setter) }
    }
}
