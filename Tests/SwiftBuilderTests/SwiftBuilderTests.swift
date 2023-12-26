//
//  SwiftBuilderTests.swift
//
//
//  Created by Kamaal M Farah on 26/12/2023.
//

import XCTest
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(swift_builderMacros)
import swift_builderMacros

let testMacros: [String: Macro.Type] = [
    "ObjectBuilder": ObjectBuilder.self,
]
#endif

final class SwiftBuilderTests: XCTestCase {
    func testMacro() throws {
        #if canImport(swift_builderMacros)
        assertMacroExpansion(
            """
            @ObjectBuilder
            class SimpleObject {
                var id: UUID?

                init() { }
            }
            """,
            expandedSource: """
            class SimpleObject {
                var id: UUID?

                init() { }

                func setId(_ id: UUID?) -> SimpleObject {
                    self.id = id
                    return self
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
