//
//  ConvertibleTests.swift
//  Node
//
//  Created by Logan Wright on 7/20/16.
//
//

import XCTest
import Node
import Foundation

class BasicConvertibleTests: XCTestCase {
    static let allTests = [
        ("testBoolInit", testBoolInit),
        ("testBoolRepresent", testBoolRepresent),
        ("testIntegerInit", testIntegerInit),
        ("testIntegerRepresent", testIntegerRepresent),
        ("testDoubleInit", testDoubleInit),
        ("testDoubleRepresent", testDoubleRepresent),

        ("testFloatInit", testFloatInit),
        ("testFloatRepresent", testFloatRepresent),
        ("testUnsignedIntegerInit", testUnsignedIntegerInit),
        ("testUnsignedIntegerRepresent", testUnsignedIntegerRepresent),
        ("testStringInit", testStringInit),
        ("testStringRepresent", testStringRepresent),
        ("testNodeConvertible", testNodeConvertible),
        ("testUUIDConvertible", testUUIDConvertible),
        ("testUUIDConvertibleThrows", testUUIDConvertibleThrows),
    ]

    func testBoolInit() throws {
        let truths: [Node] = [
            "true", "t", "yes", "y", 1, 1.0, "1"
        ]
        try truths.forEach { truth in try XCTAssert(Bool(node: truth)) }

        let falsehoods: [Node] = [
            "false", "f", "no", "n", 0, 0.0, "0"
        ]
        try falsehoods.forEach { falsehood in try XCTAssert(!Bool(node: falsehood)) }

        let fails: [Node] = [
            [1,2,3], ["key": "value"], .null
        ]
        try assert(Bool.self, fails: fails)
    }

    func testBoolRepresent() {
        let truthy = true.makeNode(in: nil)
        let falsy = false.makeNode(in: nil)
        XCTAssert(truthy == .bool(true, in: nil))
        XCTAssert(falsy == .bool(false, in: nil))
    }

    func testIntegerInit() throws {
        let string = Node("400")
        let int = Node(-42)
        let double = Node(55.6)
        let bool = Node(true)

        try XCTAssert(Int(node: string) == 400)
        try XCTAssert(Int(node: int) == -42)
        try XCTAssert(Int(node: double) == 55)
        try XCTAssert(Int(node: bool) == 1)

        let fails: [Node] = [
            [1,2,3], ["key": "value"], .null
        ]
        try assert(Int.self, fails: fails)
    }

    func testIntegerRepresent() throws {
        let node = 124.makeNode(in: nil)
        XCTAssert(node == .number(124, in: nil))
    }

    func testDoubleInit() throws {
        let string = Node("433.1029")
        let int = Node(-42)
        let double = Node(55.6)
        let bool = Node(true)

        try XCTAssert(Double(node: string) == 433.1029)
        try XCTAssert(Double(node: int) == -42.0)
        try XCTAssert(Double(node: double) == 55.6)
        try XCTAssert(Double(node: bool) == 1.0)

        let fails: [Node] = [
            [1,2,3], ["key": "value"], .null
        ]
        try assert(Double.self, fails: fails)
    }

    func testDoubleRepresent() {
        let node = 124.534.makeNode(in: nil)
        XCTAssert(node == .number(124.534, in: nil))
    }

    func testFloatInit() throws {
        let string = Node("433.1029")
        let int = Node(-42)
        let double = Node(55.6)
        let bool = Node(true)

        try XCTAssert(Float(node: string) == 433.1029)
        try XCTAssert(Float(node: int) == -42.0)
        try XCTAssert(Float(node: double) == 55.6)
        try XCTAssert(Float(node: bool) == 1.0)

        let fails: [Node] = [
            [1,2,3], ["key": "value"], .null
        ]
        try assert(Float.self, fails: fails)
    }

    func testFloatRepresent() {
        let float = Float(123.0)
        let node = float.makeNode(in: nil)
        XCTAssert(node == .number(123.0, in: nil))
    }

    func testUnsignedIntegerInit() throws {
        let string = Node("400")
        let int = Node(42)
        let double = Node(55.6)
        let bool = Node(true)

        try XCTAssert(UInt(node: string) == 400)
        try XCTAssert(UInt(node: int) == 42)
        try XCTAssert(UInt(node: double) == 55)
        try XCTAssert(UInt(node: bool) == 1)

        let fails: [Node] = [
            [1,2,3], ["key": "value"], .null
        ]
        try assert(UInt.self, fails: fails)
    }

    func testUnsignedIntegerRepresent() throws {
        let uint = UInt(124)
        let node = uint.makeNode(in: nil)
        XCTAssert(node == .number(124, in: nil))
    }

    func testStringInit() throws {
        let string = Node("hello :)")
        let int = Node(42)
        let double = Node(55.6)
        let bool = Node(true)

        try XCTAssert(String(node: string) == "hello :)")
        try XCTAssert(String(node: int) == "42")
        try XCTAssert(String(node: double) == "55.6")
        try XCTAssert(String(node: bool) == "true")

        let fails: [Node] = [
            [1,2,3], ["key": "value"], .null
        ]
        try assert(String.self, fails: fails)
    }

    func testStringRepresent() {
        let node = "hello :)".makeNode(in: nil)
        XCTAssert(node == .string("hello :)", in: nil))
    }

    func testNodeConvertible() throws {
        let node = Node("hello node")
        let initted = Node(node: node)
        let made = node.makeNode(in: nil)
        XCTAssert(initted == made)
    }

    func testUUIDConvertible() throws {
        let expectation = UUID()
        let node = expectation.makeNode(in: nil)
        XCTAssertEqual(expectation.uuidString, node.string)

        let inverse = try node.converted(to: UUID.self)
        XCTAssertEqual(inverse, expectation)
    }

    func testUUIDConvertibleThrows() throws {
        let node = Node("I'm not a uuid :)")
        do {
            _ = try node.converted(to: UUID.self)
            XCTFail("Should fail")
        } catch is NodeError {
            // ok, expected to fail
        }

    }

    private func assert<N: NodeInitializable>(_ n: N.Type, fails cases: [Node]) throws {
        try cases.forEach { fail in
            do {
                _ = try N(node: fail)
            } catch is NodeError {}
        }
    }
}
