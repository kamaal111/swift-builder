//
//  LazyObjectBuilderTests.swift
//  
//
//  Created by Kamaal M Farah on 30/12/2023.
//

import XCTest
import SwiftSyntaxMacros
import SwiftBuilderMacros
import SwiftSyntaxMacrosTestSupport

private let testMacros: [String: Macro.Type] = [
    "LazyObjectBuilder": LazyObjectBuilder.self,
]

final class LazyObjectBuilderTests: XCTestCase {
    func testLazyObjectBuilderMacroFinal() throws {
//        assertMacroExpansion(
//            """
//            @LazyObjectBuilder
//            class SimpleObject {
//                var id: UUID?
//                private(set) var name: String
//
//                init(name: String) {
//                    self.name = name
//                }
//            }
//            """,
//            expandedSource: """
//            class SimpleObject {
//                var id: UUID?
//                private(set) var name: String
//
//                init(name: String) {
//                    self.name = name
//                }
//
//                enum SimpleObjectProperties {
//                    case id, name
//                }
//
//                private var container: [SimpleObjectProperties: Any]?
//
//                func setId(_ id: UUID?) -> SimpleObject  {
//                    if container == nil {
//                        container = [:]
//                    }
//                    container[.id] = id
//                    return self
//                }
//
//                func setName(_ name: String) -> SimpleObject  {
//                    if container == nil {
//                        container = [:]
//                    }
//                    container[.name] = name
//                    return self
//                }
//            }
//            """,
//            macros: testMacros
//        )
    }

    func testLazyObjectBuilderMacro() {
        assertMacroExpansion(
            """
            @LazyObjectBuilder
            class SimpleObject {
                var id: UUID?
                private(set) var name: String

                init(name: String) {
                    self.name = name
                }
            }
            """,
            expandedSource: """
            class SimpleObject {
                var id: UUID?
                private(set) var name: String

                init(name: String) {
                    self.name = name
                }

                enum SimpleObjectProperties {
                    case id, name
                }
            }
            """,
            macros: testMacros
        )

    }
}
