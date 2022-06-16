//
//  Chapter_1_Tests.swift
//  Chapter_1_Tests
//
//  Created by Rudolf Farkas on 11.06.22.
//

@testable import FlightSchoolCodable
import RudifaUtilPkg
import XCTest

class Chapter_1_Tests: XCTestCase {
    override func setUpWithError() throws {}

    override func tearDownWithError() throws {}

    func test_FirstFlight() throws {
        struct Plane: Codable, Equatable {
            var manufacturer: String
            var model: String
            var seats: Int

            /*   */
            // also works without the code below,
            // because the compiler generates the equivalent code

            private enum CodingKeys: String, CodingKey {
                case manufacturer
                case model
                case seats
            }

            init(manufacturer: String, model: String, seats: Int) {
                self.manufacturer = manufacturer
                self.model = model
                self.seats = seats
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                manufacturer = try container.decode(String.self, forKey: .manufacturer)
                model = try container.decode(String.self, forKey: .model)
                seats = try container.decode(Int.self, forKey: .seats)
            }
        }

        do {
            let jsonData = """
            {
                "manufacturer": "Airbus",
                "model": "A380",
                "seats": 532
            }
            """.data(using: .utf8)!

            let decoder = JSONDecoder()
            let encoder = JSONEncoder()

            let plane = try decoder.decode(Plane.self, from: jsonData)

            printClassAndFunc("plane: \(plane)")

            XCTAssertEqual(plane, Plane(manufacturer: "Airbus", model: "A380", seats: 532))

            let encodedPlane = try encoder.encode(plane)

            printClassAndFunc("encodedPlane: \(encodedPlane)")

            let encodedPlaneString: String = plane.encode()!

            printClassAndFunc("encodedPlaneString: \(encodedPlaneString)")
        }

        do {
            let jsonData = """
            [
                {
                    "manufacturer": "Airbus",
                    "model": "A380",
                    "seats": 532
                },
                {
                    "manufacturer": "Boeing",
                    "model": "747",
                    "seats": 242

                },
                {
                    "manufacturer": "Airbus",
                    "model": "A320",
                    "seats": 180
                }
            ]
            """.data(using: .utf8)!

            let decoder = JSONDecoder()

            let planes = try decoder.decode([Plane].self, from: jsonData)

            printClassAndFunc("planes: \(planes)")

            XCTAssertEqual(planes, [
                Plane(manufacturer: "Airbus", model: "A380", seats: 532),
                Plane(manufacturer: "Boeing", model: "747", seats: 242),
                Plane(manufacturer: "Airbus", model: "A320", seats: 180),
            ])
        }
    }
}
