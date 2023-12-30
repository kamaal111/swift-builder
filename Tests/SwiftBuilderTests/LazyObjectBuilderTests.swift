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
    func testLazyObjectBuilderMacro() {
        assertMacroExpansion(
            """
            @LazyObjectBuilder
            class SimpleObject: LazyBuildable {
                var id: UUID?
                var name: String?

                init(id: UUID? = nil, name: String? = nil) {
                    self.id = id
                    self.name = name
                }

                static func validate(_ container: [LazyObjectBuilderProperties : Any]) -> Bool {
                    return false
                }

                static func build(_ container: [LazyObjectBuilderProperties : Any]) -> SimpleObject {
                    SimpleObject(id: container[.id] as? UUID, name: container[.name] as? String)
                }
            }
            """,
            expandedSource: """
            class SimpleObject: LazyBuildable {
                var id: UUID?
                var name: String?

                init(id: UUID? = nil, name: String? = nil) {
                    self.id = id
                    self.name = name
                }

                static func validate(_ container: [LazyObjectBuilderProperties : Any]) -> Bool {
                    return false
                }

                static func build(_ container: [LazyObjectBuilderProperties : Any]) -> SimpleObject {
                    SimpleObject(id: container[.id] as? UUID, name: container[.name] as? String)
                }

                typealias LazyBuildableSelf = SimpleObject

                typealias LazyBuildableProperties = LazyObjectBuilderProperties

                enum LazyObjectBuilderProperties {
                    case id
                    case name
                }

                class Builder {
                    private var container = [LazyObjectBuilderProperties: Any] ()
                    func setId(_ id: UUID?) -> Builder {
                        self.container[.id] = id as Any
                        return self
                    }
                    func setName(_ name: String?) -> Builder {
                        self.container[.name] = name as Any
                        return self
                    }
                }
            }
            """,
            macros: testMacros
        )

    }
}
