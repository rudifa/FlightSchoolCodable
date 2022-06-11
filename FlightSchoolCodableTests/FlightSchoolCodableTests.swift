//
//  FlightSchoolCodableTests.swift
//  FlightSchoolCodableTests
//
//  Created by Rudolf Farkas on 11.06.22.
//

@testable import FlightSchoolCodable
import RudifaUtilPkg
import XCTest

class FlightSchoolCodableTests: XCTestCase {
    override func setUpWithError() throws {}

    override func tearDownWithError() throws {}

    func test_FirstFlight() throws {
        struct Plane: Codable, Equatable {
            var manufacturer: String
            var model: String
            var seats: Int

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

        let json = """
        {
            "manufacturer": "Airbus",
            "model": "A380",
            "seats": 532
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()

        let plane = try decoder.decode(Plane.self, from: json)

        printClassAndFunc("plane: \(plane)")

        XCTAssertEqual(plane, Plane(manufacturer: "Airbus", model: "A380", seats: 532))

        let encoder = JSONEncoder()

        let encodedPlane = try encoder.encode(plane)

        printClassAndFunc("encodedPlane: \(encodedPlane)")

        let encodedPlaneString: String = plane.encode()!

        printClassAndFunc("encodedPlaneString: \(encodedPlaneString)")
    }
}
