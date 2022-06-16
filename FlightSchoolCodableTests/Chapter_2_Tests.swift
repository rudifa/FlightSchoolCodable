//
//  Chapter_2_Tests.swift
//  Chapter_2_Tests
//
//  Created by Rudolf Farkas on 11.06.22.
//

@testable import FlightSchoolCodable
import RudifaUtilPkg
import XCTest

// MARK: decode struct with nested structs and enums

// Decoding a Nested Object
// Decoding an Array of Strings
// Decoding an Enumeration from a String
// Handling Key / Property Name Mismatches
// Decoding Dates from Timestamps
// Decoding Null Values with Optional or Default Values


class Chapter_2_Tests: XCTestCase {
    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}

    // MARK: types under test

    struct Aircraft: Codable, Equatable {
        var identification: String
        var color: String
    }

    enum FlightRules: String, Codable, Equatable {
        case visual = "VFR"
        case instrument = "IFR"
    }

    struct FlightPlan: Codable, Equatable {
        var aircraft: Aircraft
        var route: [String]
        var flightRules: FlightRules
        private var departureDates: [String: Date]
        var remarks: String?

        private enum CodingKeys: String, CodingKey {
            case aircraft
            case route
            case flightRules = "flight_rules"
            case departureDates = "departure_time"
            case remarks
        }

        var proposedDepartureDate: Date? {
            return departureDates["proposed"]
        }

        var actualDepartureDate: Date? {
            return departureDates["actual"]
        }

        init(aircraft: Aircraft, route: [String], flightRules: FlightRules, departureDates: [String: Date], remarks: String?) {
            self.aircraft = aircraft
            self.route = route
            self.flightRules = flightRules
            self.departureDates = departureDates
            self.remarks = remarks
        }
    }

    // MARK: tests

    func test_HoldingPatterns() throws {
        do {
            let jsonData = """
            {
                "aircraft": {
                    "identification": "NA12345",
                    "color": "Blue/White"
                },
                "route": ["KTTD", "KHIO"],
                "flight_rules": "VFR",
                "departure_time": {
                    "proposed": "2018-04-20T14:15:00-07:00",
                    "actual": "2018-04-20T14:20:00-07:00"
                },
                "remarks": null
            }
            """.data(using: .utf8)!

            let decoder = JSONDecoder()
            // decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601

            do {
                let plan = try decoder.decode(FlightPlan.self, from: jsonData)
                printClassAndFunc("plan: \(plan)")

                let expected = FlightPlan(
                    aircraft: Aircraft(
                        identification: "NA12345",
                        color: "Blue/White"
                    ),
                    route: ["KTTD", "KHIO"],
                    flightRules: .visual,
                    departureDates: [
                        "proposed": Date(timeIntervalSince1970: 1_524_258_900),
                        "actual": Date(timeIntervalSince1970: 1_524_259_200),
                    ],
                    remarks: nil
                )
                printClassAndFunc("expected: \(expected)")

                XCTAssertEqual(plan, expected)

            } catch {
                printClassAndFunc("error: \(error)")
            }
        }

        let date1 = Date(iso8601String: "2018-04-20T14:15:00-07:00")!
        printClassAndFunc("date1= \(date1) \(date1.timeIntervalSince1970) ")

        let date2 = Date(iso8601String: "2018-04-20T14:20:00-07:00")!
        printClassAndFunc("date2= \(date2) \(date2.timeIntervalSince1970) ")
    }
}
