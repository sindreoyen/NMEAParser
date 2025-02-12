//
//  GGAParserTests.swift
//  NMEAParser
//
//  Created by Sindre on 12/02/2025.
//


import Testing
import CoreLocation
import SwiftUI
@testable import NMEAParser

@Test("Test parsing a valid GGA sentence")
func testValidGGASentence() throws {
    let parser = GGAParser()
    
    let sentence = "$GNGGA,155642.90,6025.8038680,N,01055.0975279,E,2,12,0.59,64.591,M,39.937,M,,*74\r\n"
    let parsedData = try #require(try parser.parse(sentence: sentence), "Parsed data should be parsed successfully")
    
    #expect(parsedData.time == "155642.90")
    #expect(parsedData.latitude == 60.430064466666664)
    #expect(parsedData.longitude == 10.918292131666666)
    #expect(parsedData.fixType == .dgps)
    #expect(parsedData.satellitesUsed == 12)
    #expect(parsedData.hdop == 0.59)
    #expect(parsedData.altitude == 64.591)
}

@Test("With a slightly altered payload, the checksum should fail")
func testInvalidChecksum() throws {
    let parser = GGAParser()
    
    let sentence = "$GNGGA,155642.90,6025.8038680,N,01055.0975279,E,3,12,0.59,64.591,M,39.937,M,,*74\r\n"
    #expect(throws: NMEAParserError.self) {
        try parser.parse(sentence: sentence)
    }
}

@Test("Test parsing with missing fields")
func testMissingFields() throws {
    let sentence = "$GNGGA,123519,4807.038,N,01131.000,E,1,08,,545.4,M,46.9,M,,*5A" // Missing HDOP
    
    #expect(throws: NMEAParserError.self) {
        let parser = GGAParser()
        _ = try parser.parse(sentence: sentence)
    }
}
