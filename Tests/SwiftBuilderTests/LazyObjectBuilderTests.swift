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
    "Builder": Builder.self,
]

final class LazyObjectBuilderTests: XCTestCase {
    func testLazyObjectBuilderMacro() {
        assertMacroExpansion(
            """
            protocol SimpleProtocol { }
            struct SimpleProtocolUser: SimpleProtocol { }
            @Builder
            class SimpleObject: Buildable {
                var id: UUID?
                var name: String?
                var protocolUser: (any SimpleProtocol)?

                init(id: UUID? = nil, name: String? = nil, protocolUser: SimpleProtocol?) {
                    self.id = id
                    self.name = name
                    self.protocolUser = protocolUser
                }

                static func validate(_ container: [BuildableContainerProperties : Any]) -> Bool {
                    true
                }

                static func build(_ container: [BuildableContainerProperties : Any]) -> SimpleObject {
                    SimpleObject(id: container[.id] as? UUID, name: container[.name] as? String)
                }
            }
            """,
            expandedSource: """
            protocol SimpleProtocol { }
            struct SimpleProtocolUser: SimpleProtocol { }
            class SimpleObject: Buildable {
                var id: UUID?
                var name: String?
                var protocolUser: (any SimpleProtocol)?

                init(id: UUID? = nil, name: String? = nil, protocolUser: SimpleProtocol?) {
                    self.id = id
                    self.name = name
                    self.protocolUser = protocolUser
                }

                static func validate(_ container: [BuildableContainerProperties : Any]) -> Bool {
                    true
                }

                static func build(_ container: [BuildableContainerProperties : Any]) -> SimpleObject {
                    SimpleObject(id: container[.id] as? UUID, name: container[.name] as? String)
                }

                typealias BuildableSelf = SimpleObject

                typealias BuildableContainerProperties = BuildableProperties

                enum BuildableProperties {
                    case id
                    case name
                    case protocolUser
                }

                class Builder {
                    private var container = [BuildableProperties: Any] ()
                    func setId(_ id: UUID?) -> Builder {
                        self.container[.id] = id as Any
                        return self
                    }
                    func setName(_ name: String?) -> Builder {
                        self.container[.name] = name as Any
                        return self
                    }
                    func setProtocoluser(_ protocolUser: (any SimpleProtocol)?) -> Builder {
                        self.container[.protocolUser] = protocolUser as Any
                        return self
                    }
                    func build() throws -> SimpleObject {
                        guard SimpleObject.validate(container) else {
                            throw BuilderErrors.validationError
                        }
                        return SimpleObject.build(container)
                    }
                }
            }
            """,
            macros: testMacros
        )

    }
}
