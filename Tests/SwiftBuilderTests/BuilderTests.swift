//
//  BuilderTests.swift
//
//
//  Created by Kamaal M Farah on 31/12/2023.
//

import XCTest
import SwiftBuilder

final class BuilderTests: XCTestCase {
    func testSetsPropertyFromBuilder() throws {
        let expectedName = "Kamaal"
        let object = try TestObject
            .Builder()
            .setName(expectedName)
            .build()
        XCTAssertEqual(object.name, expectedName)
    }
}

@Builder
private final class TestObject: Buildable {
    let name: String

    init(name: String) {
        self.name = name
    }

    static func build(_ container: [BuildableProperties : Any]) -> TestObject {
        TestObject(name: container[.name] as! String)
    }
}
