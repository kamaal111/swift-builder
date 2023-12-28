//
//  ObjectBuilderTests.swift
//  
//
//  Created by Kamaal M Farah on 28/12/2023.
//

import XCTest
import SwiftSyntaxMacros
import SwiftBuilderMacros
import SwiftSyntaxMacrosTestSupport

private let testMacros: [String: Macro.Type] = [
    "ObjectBuilder": ObjectBuilder.self,
]

final class ObjectBuilderTests: XCTestCase {
    func testObjectBuilderMacro() throws {
        assertMacroExpansion(
            """
            protocol SimpleProtocol { }
            struct SimpleProtocolUser: SimpleProtocol { }
            @ObjectBuilder
            class SimpleObject {
                var id: UUID?
                private(set) var name: String
                var protocolUser: any SimpleProtocol

                init(name: String, protocolUser: some SimpleProtocol) {
                    self.name = name
                    self.protocolUser = protocolUser
                }
            }
            """,
            expandedSource: """
            protocol SimpleProtocol { }
            struct SimpleProtocolUser: SimpleProtocol { }
            class SimpleObject {
                var id: UUID?
                private(set) var name: String
                var protocolUser: any SimpleProtocol

                init(name: String, protocolUser: some SimpleProtocol) {
                    self.name = name
                    self.protocolUser = protocolUser
                }

                func setId(_ id: UUID?) -> SimpleObject  {
                    self.id = id
                    return self
                }

                func setName(_ name: String) -> SimpleObject  {
                    self.name = name
                    return self
                }

                func setProtocoluser(_ protocolUser: any  SimpleProtocol) -> SimpleObject  {
                    self.protocolUser = protocolUser
                    return self
                }
            }
            """,
            macros: testMacros
        )
    }

    func testObjectBuilderMacroWithEnums() {
        assertMacroExpansion(
            """
            @ObjectBuilder
            enum SimpleEnum {
                case hello
            }
            """,
            expandedSource: """
            enum SimpleEnum {
                case hello
            }
            """,
            diagnostics: [.init(message: "@ObjectBuilder only supports classes", line: 1, column: 1)],
            macros: testMacros
        )
    }
}
