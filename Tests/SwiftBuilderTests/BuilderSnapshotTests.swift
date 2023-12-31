//
//  BuilderSnapshotTests.swift
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

final class BuilderSnapshotTests: XCTestCase {
    func testBuilderMacro() throws {
        let snapshotName = try XCTUnwrap(#function.split(separator: "()").first)
        let snapshotNameString = String(snapshotName)
        assertMacroExpansion(
            try getSnapshot(named: snapshotNameString, ofType: .source),
            expandedSource: try getSnapshot(named: snapshotNameString, ofType: .expanded),
            macros: testMacros
        )
    }

    func testBuilderMacroForPublicClass() throws {
        let snapshotName = try XCTUnwrap(#function.split(separator: "()").first)
        let snapshotNameString = String(snapshotName)
        assertMacroExpansion(
            try getSnapshot(named: snapshotNameString, ofType: .source),
            expandedSource: try getSnapshot(named: snapshotNameString, ofType: .expanded),
            macros: testMacros
        )
    }

    func testBuilderMacroUnsupportedType() throws {
        let snapshotName = try XCTUnwrap(#function.split(separator: "()").first)
        let snapshotNameString = String(snapshotName)
        assertMacroExpansion(
            try getSnapshot(named: snapshotNameString, ofType: .source),
            expandedSource: try getSnapshot(named: snapshotNameString, ofType: .expanded),
            diagnostics: [.init(message: "@Builder only supports classes", line: 1, column: 1)],
            macros: testMacros
        )
    }

    func testBuilderMacroInsufficientProperties() throws {
        let snapshotName = try XCTUnwrap(#function.split(separator: "()").first)
        let snapshotNameString = String(snapshotName)
        assertMacroExpansion(
            try getSnapshot(named: snapshotNameString, ofType: .source),
            expandedSource: try getSnapshot(named: snapshotNameString, ofType: .expanded),
            diagnostics: [.init(message: "Must have atleast mutable 1 property", line: 1, column: 1)],
            macros: testMacros
        )
    }

    private func getSnapshot(named name: String, ofType type: SnapshotTypes) throws -> String {
        let path = try XCTUnwrap(Bundle.module.path(forResource: name, ofType: type.rawValue))
        let url = URL(fileURLWithPath: path)
        return try String(contentsOf: url)
    }

    private enum SnapshotTypes: String {
        case expanded
        case source
    }
}
