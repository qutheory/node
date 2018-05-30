//
//  BasicTypes.swift
//  Genome
//
//  Created by Logan Wright on 9/19/15.
//  Copyright © 2015 lowriDevs. All rights reserved.
//

import XCTest
import Foundation
@testable import Node

struct NoNull: NodeInitializable, Hashable {
    let node: Node

    var hashValue: Int {
        return "\(node)".hashValue
    }

    init(node: Node) throws {
        guard node != .null else {
            throw NodeError.unableToConvert(input: node, expectation: "something not null", path: [])
        }
        
        self.node = node
    }
}

func == (l: NoNull, r: NoNull) -> Bool {
    return l.node == r.node
}

class NodeGetterTests: XCTestCase {
    override func setUp() {
        Node.fuzzy = [Node.self]
    }
    
    static let allTests = [
        ("testGetNoPath", testGetNoPath),
        ("testgetTransform", testgetTransform),
        ("testgetTransformThrows", testgetTransformThrows),
        ("testgetTransformOptionalValue", testgetTransformOptionalValue),
        ("testgetTransformOptionalNil", testgetTransformOptionalNil),
        ("testgetSingle", testgetSingle),
        ("testgetSingleOptional", testgetSingleOptional),
        ("testgetSingleThrows", testgetSingleThrows),
        ("testgetArray", testgetArray),
        ("testgetArrayOptional", testgetArrayOptional),
        ("testgetArrayThrows", testgetArrayThrows),
        ("testgetArrayOfArrays", testgetArrayOfArrays),
        ("testgetArrayOfArraysOptional", testgetArrayOfArraysOptional),
        ("testgetArrayOfArraysThrows", testgetArrayOfArraysThrows),
        ("testgetObject", testgetObject),
        ("testgetObjectOptional", testgetObjectOptional),
        ("testgetObjectThrows", testgetObjectThrows),
        ("testgetObjectOfArrays", testgetObjectOfArrays),
        ("testgetObjectOfArraysOptional", testgetObjectOfArraysOptional),
        ("testgetObjectOfArraysThrows", testgetObjectOfArraysThrows),
        ("testgetSet", testgetSet),
        ("testgetSetOptional", testgetSetOptional),
        ("testgetSetThrows", testgetSetThrows),
        ("testgetDateRFC1123", testgetDateRFC1123),
        ("testgetDateMySQLDATETIME", testgetDateMySQLDATETIME),
        ("testBadObject", testBadObject),
    ]

    func testGetNoPath() throws {
        let node = "foo" as Node
        let foo = try node.get() as String
        XCTAssertEqual(foo, "foo")
    }

    func testgetTransform() throws {
        let dict = ["date": 250]
        let node = try Node(node: dict, in: nil)
        let geted = try node.get("date", transform: Date.fromTimestamp)
        XCTAssert(geted.timeIntervalSince1970 == 250)
    }

    func testgetTransformThrows() throws {
        let node = Node()
        do {
            _ = try node.get("date", transform: Date.fromTimestamp)
            XCTFail("should throw error")
        } catch is NodeError {}
    }

    func testgetTransformOptionalValue() throws {
        let node = try Node(node: ["date": 250], in: nil)
        let geted = try node.get("date", transform: Date.optionalFromTimestamp)
        XCTAssert(geted?.timeIntervalSince1970 == 250)
    }

    func testgetTransformOptionalNil() throws {
        let node = Node()
        let geted = try node.get("date", transform: Date.optionalFromTimestamp)
        XCTAssertNil(geted)
    }

    func testgetSingle() throws {
        let node = try Node(node: ["nest": [ "ed": ["hello": "world", "pi": 3.14159]]])
        let geted = try node.get("nest.ed.hello") as NoNull
        XCTAssert(geted.node.string == "world")
    }

    func testgetSingleOptional() throws {
        let node = try Node(node: ["nest": [ "ed": ["hello": "world", "pi": 3.14159]]])
        let geted: NoNull? = try node.get("nest.ed.hello")
        XCTAssert(geted?.node.string == "world")
    }

    func testgetSingleThrows() throws {
        let node = Node()
        do {
            _ = try node.get("nest.ed.hello") as NoNull
            XCTFail("should throw node error unable to convert")
        } catch is NodeError {}
    }

    func testgetArray() throws {
        let node = try Node(node: ["nest": [ "ed": ["array": [1, 2, 3, 4]]]])
        let geted = try! node.get("nest.ed.array") as [NoNull]
        #if swift(>=4.1)
        let numbers = geted.compactMap { $0.node.int }
        #else
        let numbers = geted.flatMap { $0.node.int }
        #endif
        XCTAssert(numbers == [1,2,3,4])
    }

    func testgetArrayOptional() throws {
        let node = try Node(node: ["nest": [ "ed": ["array": [1, 2, 3, 4]]]])
        let geted: [NoNull]? = try node.get("nest.ed.array")
        #if swift(>=4.1)
        let numbers = geted?.compactMap { $0.node.int } ?? []
        #else
        let numbers = geted?.flatMap { $0.node.int } ?? []
        #endif
        XCTAssert(numbers == [1,2,3,4])
    }

    func testgetArrayThrows() throws {
        let node = Node()
        do {
            _ = try node.get("nest.ed.hello") as [NoNull]
            XCTFail("should throw node error unable to convert")
        } catch is NodeError {}
    }

    func testgetArrayOfArrays() throws {
        let node = try Node(node: ["nest": [ "ed": ["array": [[1], [2], [3], [4]]]]])
        let geted = try node.get("nest.ed.array") as [[NoNull]]
        #if swift(>=4.1)
        let numbers = geted.map { innerArray in
            innerArray.compactMap { $0.node.int }
        }
        #else
        let numbers = geted.map { innerArray in
            innerArray.flatMap { $0.node.int }
        }
        #endif

        guard numbers.count == 4 else {
            XCTFail("failed array of arrays")
            return
        }
        XCTAssert(numbers[0] == [1])
        XCTAssert(numbers[1] == [2])
        XCTAssert(numbers[2] == [3])
        XCTAssert(numbers[3] == [4])
    }

    func testgetArrayOfArraysOptional() throws {
        let node = try Node(node: ["nest": [ "ed": ["array": [[1], [2], [3], [4]]]]])
        let geted: [[NoNull]]? = try node.get("nest.ed.array")
        #if swift(>=4.1)
        let numbers = geted?.map { innerArray in
            innerArray.compactMap { $0.node.int }
        } ?? []
        #else
        let numbers = geted?.map { innerArray in
            innerArray.flatMap { $0.node.int }
        } ?? []
        #endif

        guard numbers.count == 4 else {
            XCTFail("failed array of arrays optional")
            return
        }
        XCTAssert(numbers[0] == [1])
        XCTAssert(numbers[1] == [2])
        XCTAssert(numbers[2] == [3])
        XCTAssert(numbers[3] == [4])
    }

    func testgetArrayOfArraysThrows() throws {
        do {
            let node = Node()
            _ = try node.get("nest.ed.array") as [[NoNull]]
            XCTFail("should throw node error unable to convert")
        } catch is NodeError {}
    }

    func testgetObject() throws {
        let node = try Node(node: ["nest": [ "ed": ["object": ["hello": "world"]]]])
        let geted = try node.get("nest.ed.object") as [String: NoNull]
        XCTAssert(geted["hello"]?.node.string == "world")
    }

    func testgetObjectOptional() throws {
        let node = try Node(node: ["nest": [ "ed": ["object": ["hello": "world"]]]])
        let geted: [String: NoNull]? = try node.get("nest.ed.object")
        XCTAssert(geted?["hello"]?.node.string == "world")
    }

    func testgetObjectThrows() throws {
        let node = Node()
        do {
            _ = try node.get("dont.exist.0") as [String: NoNull]
            XCTFail("should throw node error unable to convert")
        } catch {}
    }

    func testgetObjectOfArrays() throws {
        let node = try Node(node: ["nest": [ "ed": ["object": ["hello": [1,2,3,4]]]]])
        let geted = try node.get("nest.ed.object") as [String: [NoNull]]
        #if swift(>=4.1)
        let ints = geted["hello"]?.compactMap({ $0.node.int }) ?? []
        #else
        let ints = geted["hello"]?.flatMap({ $0.node.int }) ?? []
        #endif
        XCTAssert(ints == [1,2,3,4])
    }

    func testgetObjectOfArraysOptional() throws {
        let node = try Node(node: ["nest": [ "ed": ["object": ["hello": [1,2,3,4]]]]])
        let geted: [String: [NoNull]]? = try node.get("nest.ed.object")
        #if swift(>=4.1)
        let ints = geted?["hello"]?.compactMap({ $0.node.int }) ?? []
        #else
        let ints = geted?["hello"]?.flatMap({ $0.node.int }) ?? []
        #endif
        XCTAssert(ints == [1,2,3,4])
    }

    func testgetObjectOfArraysThrows() throws {
        let node = Node()
        do {
            _ = try node.get("dont.exist.0") as [String: [NoNull]]
            XCTFail("should throw node error unable to convert")
        } catch {}
    }

    func testgetSet() throws {
        let node = try Node(node: ["nest": [ "ed": ["array": [1, 2, 3, 4]]]])
        let geted = try node.get("nest.ed.array") as Set<NoNull>
        let ints = [1,2,3,4]
        let compare = try ints.converted(to: Set<NoNull>.self, in: nil)
        XCTAssert(geted == compare)
    }

    func testgetSetOptional() throws {
        let node = try Node(node: ["nest": [ "ed": ["array": [1, 2, 3, 4]]]])
        let geted: Set<NoNull>? = try node.get("nest.ed.array")
        let ints = [1,2,3,4]
        let compare = try ints.converted(to: Set<NoNull>.self, in: nil)
        XCTAssert(geted == compare)
    }

    func testgetSetThrows() throws {
        let node = Node()
        do {
            _ = try node.get("dont.exist.0") as Set<NoNull>
            XCTFail("should throw node error unable to convert")
        } catch is NodeError {}
    }
    
    func testgetDateRFC1123() throws {
        let node = try Node(node: ["time": "Sun, 16 May 2010 15:20:00 GMT"])
        let date: Date = try node.get("time")
        XCTAssertEqual(date.timeIntervalSince1970, 1274023200.0)
    }
    
    func testgetDateMySQLDATETIME() throws {
        let node = try Node(node: ["time": "2010-05-16 15:20:00"])
        let date: Date = try node.get("time")
        XCTAssertEqual(date.timeIntervalSince1970, 1274023200.0)
    }

    func testBadObject() throws {
        // there was an issue where calling keys on an array of 
        // string objects would stack overflow,
        // this test asserts that doesn't happen
        let arrayNotObject = Node(["key", "typo"])
        XCTAssertNotNil(arrayNotObject.array)
        XCTAssertNil(arrayNotObject.object)
        // assert this doesn't stack overflow
        _ = arrayNotObject["key"]
    }
}

extension Date {
    static func fromTimestamp(_ timestamp: Int) -> Date {
        return Date(timeIntervalSince1970: TimeInterval(timestamp))
    }

    static func optionalFromTimestamp(_ timestamp: Int?) -> Date? {
        guard let stamp = timestamp else { return nil }
        return fromTimestamp(stamp)
    }
}
