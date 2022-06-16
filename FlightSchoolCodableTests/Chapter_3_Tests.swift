//
//  Chapter_2_Tests.swift
//  Chapter_2_Tests
//
//  Created by Rudolf Farkas on 11.06.22.
//

@testable import FlightSchoolCodable
import RudifaUtilPkg
import XCTest

// MARK: decode struct with ...

// Decoding Unknown Keys
// Decoding Indeterminate Types
// Decoding Arbitrary Types
// ...

class Chapter_3_Tests: XCTestCase {
    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    // MARK: types under test

    let flightRouteJSONData = """
    {
        "points": ["KSQL", "KWVI"],
        "KSQL": {
            "code": "KSQL",
            "name": "San Carlos Airport"
        },
        "KWVI": {
            "code": "KWVI",
            "name": "Watsonville Municipal Airport"
        }
    }
    """.data(using: .utf8)!

    // The "points" key has an array of string values that corresponds to the other keys
    // in the top-level object. This pattern may be convenient in some languages,
    // but not as much in Swift with Codable.

    struct Route: Decodable, Equatable {
        struct Airport: Decodable, Equatable {
            var code: String
            var name: String
        }

        var points: [Airport]

        internal init(points: [Airport]) {
            self.points = points
        }

        // CodingKeys requirement can also be satisfied by a structure, which
        // can be conditionally initialized with arbitrary Int or String values.

        private struct CodingKeys: CodingKey {
            var stringValue: String
            var intValue: Int? {
                return nil
            }

            init?(stringValue: String) {
                self.stringValue = stringValue
            }

            init?(intValue: Int) {
                return nil
            }

            static let points =
                CodingKeys(stringValue: "points")!
        }

        // In the init(from:) initializer, we can dynamically build up
        // a list of airports based on the array of codes decoded for the .points key.

        init(from coder: Decoder) throws {
            let container =
                try coder.container(keyedBy: CodingKeys.self)
            var points: [Airport] = []
            let codes = try container.decode([String].self,
                                             forKey: .points)
            for code in codes {
                let key = CodingKeys(stringValue: code)!
                let airport =
                    try container.decode(Airport.self,
                                         forKey: key)
                points.append(airport)
            }
            self.points = points
        }
    }

    // MARK: tests

    func test_03_TakingTheControls() throws {
        do {
            let decoder = JSONDecoder()

            do {
                let route = try decoder.decode(Route.self, from: flightRouteJSONData)
                printClassAndFunc("route: \(route)")

                let expected = Route(points: [
                    Route.Airport(code: "KSQL", name: "San Carlos Airport"),
                    Route.Airport(code: "KWVI", name: "Watsonville Municipal Airport"),
                ])
                XCTAssertEqual(route, expected)
            } catch {
                printClassAndFunc("error: \(error)")
                XCTFail()
            }
        }
    }

    // MARK: more types under test

    let indeterminateTypesJSONData = """
    [
        {
            "type": "bird",
            "genus": "Chaetura",
            "species": "Vauxi"
        },
        {
            "type": "plane",
            "identifier": "NA12345"
        }
    ]
    """.data(using: .utf8)!

    // Swift demands formal types. A bird is a Bird. A plane is a Plane.

    struct Bird: Decodable {
        var genus: String
        var species: String
    }

    struct Plane: Decodable {
        var identifier: String
    }

    // When something can be either, then it is Either.
    // One way to cope with Swift’s horror incognito is to create
    // a conditional extension on Either types whose associated types are Decodable:
    // (see below, extension must be declared at the file scope)

    func test_03_TwoIndeterminateTypes() throws {
        let decoder = JSONDecoder()
        let objects = try! decoder.decode(
            [Either<Bird, Plane>].self,
            from: indeterminateTypesJSONData
        )

        for object in objects {
            switch object {
            case let .left(bird):
                printClassAndFunc("It's a bird \(bird.genus) \(bird.species)!")
                XCTAssertEqual(bird.genus, "Chaetura")
                XCTAssertEqual(bird.species, "Vauxi")
            case let .right(plane):
                printClassAndFunc("It's a plane \(plane.identifier)!")
                XCTAssertEqual(plane.identifier, "NA12345")
            }
        }
    }

    // Decoding Arbitrary Types
    // One possible solution is to create a type-erased, Decodable-conforming type
    // with an interface similar to Any Hashable.
    // https://github.com/flight-school/AnyCodable

}

enum Either<T, U> {
    case left(T)
    case right(U)
}

extension Either: Decodable where T: Decodable, U: Decodable {
    init(from decoder: Decoder) throws {
        if let value = try? T(from: decoder) {
            self = .left(value)
        } else if let value = try? U(from: decoder) {
            self = .right(value)
        } else {
            let context = DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription:
                "Cannot decode \(T.self) or \(U.self)"
            )
            throw DecodingError.dataCorrupted(context)
        }
    }
}
