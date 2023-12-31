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
            .get()
        XCTAssertEqual(object.name, expectedName)
    }

    func testThrowsAErrorBecauseARequiredValueHasNotBeenSet() {
        XCTAssertThrowsError(try TestObject.Builder().build().get()) { error in
            let error = error as? BuilderErrors
            XCTAssertEqual(error, .validationError)
        }
    }

    func testThrowsAErrorBecauseOfCustomValidation() {
        let builderResult = TestObjectWithCustomValidation
            .Builder()
            .setName("Failure")
            .build()
        XCTAssertThrowsError(try builderResult.get()) { error in
            let error = error as? BuilderErrors
            XCTAssertEqual(error, .validationError)
        }
    }

    func testSetsPropertiesBecauseItWentPastCustomValidation() throws {
        let expectedName = "Not Failure"
        let object = try TestObjectWithCustomValidation
            .Builder()
            .setName(expectedName)
            .build()
            .get()
        XCTAssertEqual(object.name, expectedName)
    }

    func testDoesntFailBecauseValueIsNotRequired() throws {
        let object = try TestObjectWithCustomValidation
            .Builder()
            .build()
            .get()
        XCTAssertNil(object.name)
    }
}

@Builder
private final class TestObjectWithCustomValidation: Buildable {
    var name: String?

    init(name: String?) {
        self.name = name
    }

    static func validate(_ container: [BuildableProperties : Any]) -> Bool {
        (container[.name] as? String) != "Failure"
    }

    static func build(_ container: [BuildableProperties : Any]) -> TestObjectWithCustomValidation {
        TestObjectWithCustomValidation(name: container[.name] as? String)
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
