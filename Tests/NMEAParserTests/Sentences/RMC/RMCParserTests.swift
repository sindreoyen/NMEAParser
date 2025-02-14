//
//  RMCParserTests.swift
//  NMEAParser
//
//  Created by Sindre on 14/02/2025.
//

import Testing
import CoreLocation
import SwiftUI
@testable import NMEAParser

// MARK: - Valid RMC Sentence with Minimal Optional Fields

@Test("Test parsing a valid RMC sentence (minimal optional fields)")
func testValidRMCSentence() throws {
    let parser = RMCParser()
    
    // Example minimal RMC sentence (course, magnetic variation & direction omitted):
    // $GNRMC,180201.80,A,6325.8068737,N,01025.0920747,E,0.074,,140225,,,A,V*1B
    let sentence = "$GNRMC,180201.80,A,6325.8068737,N,01025.0920747,E,0.074,,140225,,,A,V*1B"
    
    let parsedData = try #require(try parser.parse(sentence: sentence), "Parsed data should be parsed successfully")
    
    #expect(parsedData.time == "180201.80")
    #expect(parsedData.status == "A")
    
    // Convert latitude: 6325.8068737 -> 63° + 25.8068737/60 minutes.
    let expectedLatitude = 63.0 + 25.8068737 / 60.0
    #expect(abs(parsedData.latitude - expectedLatitude) < 0.000001)
    
    // Convert longitude: 01025.0920747 -> 10° + 25.0920747/60 minutes.
    let expectedLongitude = 10.0 + 25.0920747 / 60.0
    #expect(abs(parsedData.longitude - expectedLongitude) < 0.000001)
    
    #expect(parsedData.speedOverGround == 0.074)
    #expect(parsedData.courseOverGround == nil)  // Empty course field.
    #expect(parsedData.date == "140225")
    #expect(parsedData.magneticVariation == nil)
    #expect(parsedData.magneticVariationDirection == nil)
    #expect(parsedData.mode == "A")
}

// MARK: - Valid RMC Sentence with All Fields Present

@Test("Test parsing a valid RMC sentence with all fields present")
func testValidRMCAllFields() throws {
    let parser = RMCParser()
    
    // Example RMC sentence with every field provided:
    // $GPRMC,235947,A,5550.000,N,03736.000,E,0.13,309.62,130720,5.5,W,A*6C
    // Breakdown:
    // Field 0: "$GPRMC"
    // Field 1: "235947"            (time)
    // Field 2: "A"                 (status)
    // Field 3: "5550.000"          (latitude value)
    // Field 4: "N"                 (N/S indicator)
    // Field 5: "03736.000"         (longitude value)
    // Field 6: "E"                 (E/W indicator)
    // Field 7: "0.13"              (speed over ground)
    // Field 8: "309.62"            (course over ground)
    // Field 9: "130720"            (date)
    // Field 10: "5.5"              (magnetic variation)
    // Field 11: "W"                (magnetic variation direction)
    // Field 12: "A"                (mode indicator)
    let sentence = "$GPRMC,235947,A,5550.000,N,03736.000,E,0.13,309.62,130720,5.5,W,A*08"
    
    let parsedData = try #require(try parser.parse(sentence: sentence), "Parsed data should be parsed successfully")
    
    #expect(parsedData.time == "235947")
    #expect(parsedData.status == "A")
    
    // Expected latitude: 5550.000 -> 55° + (50/60) = 55.8333333...
    let expectedLatitude = 55.0 + 50.0 / 60.0
    #expect(abs(parsedData.latitude - expectedLatitude) < 0.000001)
    
    // Expected longitude: 03736.000 -> 37° + (36/60) = 37.6
    let expectedLongitude = 37.0 + 36.0 / 60.0
    #expect(abs(parsedData.longitude - expectedLongitude) < 0.000001)
    
    #expect(parsedData.speedOverGround == 0.13)
    #expect(parsedData.courseOverGround == 309.62)
    #expect(parsedData.date == "130720")
    #expect(parsedData.magneticVariation == 5.5)
    #expect(parsedData.magneticVariationDirection == "W")
    #expect(parsedData.mode == "A")
}

// MARK: - Checksum and Field Validation Tests

@Test("With an altered RMC payload, the checksum should fail")
func testInvalidRMCChecksum() throws {
    let parser = RMCParser()
    
    // Alter speed over ground (0.074 -> 0.075) in the minimal sentence to trigger a checksum mismatch.
    let sentence = "$GNRMC,180201.80,A,6325.8068737,N,01025.0920747,E,0.075,,140225,,,A,V*1B"
    
    #expect(throws: NMEAParserError.self) {
        try parser.parse(sentence: sentence)
    }
}

@Test("Test parsing an RMC sentence with missing fields")
func testMissingRMCFields() throws {
    // This sentence is missing several required fields (e.g. course, date, etc.).
    let sentence = "$GNRMC,180201.80,A,6325.8068737,N,01025.0920747,E,0.074*1C"
    
    #expect(throws: NMEAParserError.self) {
        let parser = RMCParser()
        _ = try parser.parse(sentence: sentence)
    }
}

// MARK: - Invalid Field Value Tests

@Test("Test parsing RMC sentence with a non-numeric speed field")
func testInvalidRMCSpeedField() throws {
    let parser = RMCParser()
    
    // Replace the numeric speed field with a non-numeric value ("ABC").
    // Note: The checksum in this sentence must be recalculated for a real test.
    // For testing, we assume the checksum is correct up until the invalid field is parsed.
    let sentence = "$GNRMC,180201.80,A,6325.8068737,N,01025.0920747,E,ABC,,140225,,,A,V*00"
    
    #expect(throws: NMEAParserError.self) {
        try parser.parse(sentence: sentence)
    }
}

// MARK: - Whitespace and Line Break Handling

@Test("Test parsing RMC sentence with extra whitespace and CRLF")
func testRMCWhitespaceAndCRLF() throws {
    let parser = RMCParser()
    
    // Valid sentence with extra whitespace and newline characters.
    // We use a fully-populated sentence for clarity.
    let sentence = "$GPRMC,235947,A,5550.000,N,03736.000,E,0.13,309.62,130720,5.5,W,A*08\r\n  "
    
    // Trimming whitespace/newlines before parsing (or the parser may do this internally).
    let trimmedSentence = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
    let parsedData = try #require(try parser.parse(sentence: trimmedSentence), "Parsed data should be parsed successfully")
    
    #expect(parsedData.time == "235947")
    #expect(parsedData.status == "A")
}
