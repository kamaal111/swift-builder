//
//  TypeAnnotationInfo.swift
//  
//
//  Created by Kamaal M Farah on 31/12/2023.
//

import SwiftSyntax

struct TypeAnnotationInfo {
    let name: TokenSyntax
    let fullType: TokenSyntax
    let isOptional: Bool
}
