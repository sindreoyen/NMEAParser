//
//  GGAParser.swift
//  NMEAParser
//
//  Created by Sindre on 12/02/2025.
//

import Foundation
import CoreLocation

/// Parses GGA NMEA sentences into `GGAData` objects.
final class GGAParser: NMEASentenceParser {
    // MARK: - Public Methods
    
    /**
     Parses a raw GGA sentence string into a `GGAData` object.
     
     This method performs the following steps:
     
     1. Validates that the sentence starts with '$' and that the identifier is supported.
     2. Splits the sentence into its data and checksum parts.
     3. Validates that the checksum is correct.
     4. Extracts the comma-separated fields.
     5. Parses and converts individual fields into the corresponding properties of `GGAData`.
     
     - Parameter sentence: The raw GGA sentence string.
     - Throws: An error of type `NMEAParserError` if the sentence is invalid or any field is malformed.
     - Returns: A `GGAData` object with the parsed values.
     */
    func parse(sentence: String) throws -> GGAData {
        try validateStartAndIdentifier(sentence)
        
        let (dataPart, checksumPart) = try splitSentence(sentence)
        try validateChecksum(dataPart: dataPart, expected: checksumPart)
        
        let fields = extractFields(from: dataPart)
        try validateFieldCount(fields, minimumExpected: 10)
        
        return try parseGGAData(from: fields)
    }
    
    // MARK: - Private Methods
    
    /**
     Validates that the sentence starts with '$' and that the identifier is one of the supported ones.
     
     - Parameter sentence: The raw NMEA sentence string.
     - Throws: `NMEAParserError.invalidFormat` if the sentence does not start with '$' or has an unsupported identifier.
     */
    private func validateStartAndIdentifier(_ sentence: String) throws {
        // Extract identifier from '$' to the first comma (inclusive of '$', exclusive of comma)
        guard let commaIndex = sentence.firstIndex(of: ",") else {
            throw NMEAParserError.invalidFormat
        }
        let identifier = String(sentence[sentence.startIndex..<commaIndex])
        guard GGAData.Identifier(rawValue: identifier) != nil else {
            throw NMEAParserError.unsupportedIdentifier(identifier: identifier)
        }
    }
    
    /**
     Splits the sentence into the data part and the checksum part.
     
     The expected format is:
     
     ```
     $<data>*<checksum>
     ```
     
     - Parameter sentence: The raw NMEA sentence string.
     - Returns: A tuple containing the data part and the trimmed checksum part.
     - Throws: `NMEAParserError.invalidFormat` if the sentence does not contain exactly one "*" character.
     */
    private func splitSentence(_ sentence: String) throws -> (dataPart: String, checksumPart: String) {
        let parts = sentence.components(separatedBy: "*")
        guard parts.count == 2,
              let dataPart = parts.first,
              let rawChecksum = parts.last else {
            throw NMEAParserError.invalidFormat
        }
        let checksumPart = rawChecksum.trimmingCharacters(in: .whitespacesAndNewlines)
        return (dataPart, checksumPart)
    }
    
    /**
     Validates the checksum of the sentence.
     
     The checksum is computed by XOR-ing all the characters between '$' and '*' (not including these symbols).
     
     - Parameters:
       - dataPart: The part of the sentence containing the data (including the leading '$').
       - expected: The expected checksum as a hexadecimal string.
     - Throws: `NMEAParserError.checksumMismatch` if the computed checksum does not match the expected checksum.
     */
    private func validateChecksum(dataPart: String, expected: String) throws {
        let computedChecksum = computeChecksum(for: dataPart)
        let computedChecksumStr = String(format: "%02X", computedChecksum)
        guard computedChecksumStr == expected else {
            throw NMEAParserError.checksumMismatch(expected: expected, computed: computedChecksumStr)
        }
    }
    
    /**
     Computes the checksum by XOR-ing all characters between '$' and '*' (not inclusive).
     
     - Parameter dataPart: The part of the sentence containing the data (including the leading '$').
     - Returns: The computed checksum as a UInt8.
     */
    private func computeChecksum(for dataPart: String) -> UInt8 {
        // Remove the '$' at the beginning.
        let trimmedData = dataPart.dropFirst()
        var checksum: UInt8 = 0
        for char in trimmedData.utf8 {
            checksum ^= char
        }
        return checksum
    }
    
    /**
     Extracts the comma-separated fields from the data part of the sentence.
     
     - Parameter dataPart: The part of the sentence containing the data (including the leading '$').
     - Returns: An array of strings representing each field.
     */
    private func extractFields(from dataPart: String) -> [String] {
        // Remove '$' and split by comma.
        let trimmedDataPart = String(dataPart.dropFirst())
        return trimmedDataPart.components(separatedBy: ",")
    }
    
    /**
     Validates that the number of fields is at least the specified minimum.
     
     - Parameters:
       - fields: The array of fields extracted from the sentence.
       - minimumExpected: The minimum number of expected fields.
     - Throws: `NMEAParserError.insufficientFields` if the count is less than the minimum expected.
     */
    private func validateFieldCount(_ fields: [String], minimumExpected: Int) throws {
        guard fields.count >= minimumExpected else {
            throw NMEAParserError.insufficientFields(expected: minimumExpected, got: fields.count)
        }
    }
    
    /**
     Parses the GGA data from the array of fields.
     
     The expected order of fields is:
     
     - **Field 0:** Identifier (e.g., "GPGGA")
     - **Field 1:** Time
     - **Field 2:** Latitude (in degrees and minutes)
     - **Field 3:** Latitude direction ("N" or "S")
     - **Field 4:** Longitude (in degrees and minutes)
     - **Field 5:** Longitude direction ("E" or "W")
     - **Field 6:** Fix type
     - **Field 7:** Satellites used
     - **Field 8:** HDOP
     - **Field 9:** Altitude
     
     - Parameter fields: The array of fields extracted from the sentence.
     - Returns: A `GGAData` object populated with the parsed values.
     - Throws: An error if any field cannot be parsed.
     */
    private func parseGGAData(from fields: [String]) throws -> GGAData {
        // Field 1: Time (empty strings are allowed and converted to nil)
        let timeField = fields[1]
        
        // Fields 2 & 3: Latitude and its direction.
        let latitude = try parseCoordinate(from: fields, valueIndex: 2, directionIndex: 3, fieldName: "latitude")
        
        // Fields 4 & 5: Longitude and its direction.
        let longitude = try parseCoordinate(from: fields, valueIndex: 4, directionIndex: 5, fieldName: "longitude")
        
        // Field 6: Fix type (UInt8)
        let fixTypeValue = try parseUInt8Field(fields[6], fieldName: "fixType")
        
        // Field 7: Number of satellites used (UInt8)
        let satellitesUsed = try parseUInt8Field(fields[7], fieldName: "satellitesUsed")
        
        // Field 8: HDOP (Double)
        let hdop = try parseDoubleField(fields[8], fieldName: "hdop")
        
        // Field 9: Altitude (Double)
        let altitude = try parseDoubleField(fields[9], fieldName: "altitude")
        
        return GGAData(
            time: timeField.isEmpty ? nil : timeField,
            latitude: latitude,
            longitude: longitude,
            fixType: GGAFixType(rawValue: fixTypeValue) ?? .invalid,
            satellitesUsed: satellitesUsed,
            hdop: hdop,
            altitude: altitude
        )
    }
    
    /**
     Parses a coordinate from the specified fields and converts it to decimal degrees.
     
     - Parameters:
       - fields: The array of fields from the sentence.
       - valueIndex: The index of the numeric coordinate value (in "degrees and minutes" format).
       - directionIndex: The index of the direction (e.g., "N", "S", "E", or "W").
       - fieldName: A string used for error reporting.
     - Returns: The coordinate in decimal degrees.
     - Throws: `NMEAParserError.invalidField` if the numeric value cannot be parsed.
     */
    private func parseCoordinate(from fields: [String], valueIndex: Int, directionIndex: Int, fieldName: String) throws -> CLLocationDegrees {
        guard let rawValue = Double(fields[valueIndex]) else {
            throw NMEAParserError.invalidField(fieldName: fieldName)
        }
        let direction = fields[directionIndex]
        return convertToDecimalDegrees(rawValue, direction: direction)
    }
    
    /**
     Parses a Double field from a string.
     
     - Parameters:
       - field: The string representation of the field.
       - fieldName: A string used for error reporting.
     - Returns: The Double value parsed from the string.
     - Throws: `NMEAParserError.invalidField` if the conversion fails.
     */
    private func parseDoubleField(_ field: String, fieldName: String) throws -> Double {
        guard let value = Double(field) else {
            throw NMEAParserError.invalidField(fieldName: fieldName)
        }
        return value
    }
    
    /**
     Parses a UInt8 field from a string.
     
     - Parameters:
       - field: The string representation of the field.
       - fieldName: A string used for error reporting.
     - Returns: The UInt8 value parsed from the string.
     - Throws: `NMEAParserError.invalidField` if the conversion fails.
     */
    private func parseUInt8Field(_ field: String, fieldName: String) throws -> UInt8 {
        guard let value = UInt8(field) else {
            throw NMEAParserError.invalidField(fieldName: fieldName)
        }
        return value
    }
    
    /**
     Converts a coordinate from NMEA “degrees and minutes” format to decimal degrees.
     
     The coordinate is given in a format where the first two (or three) digits are degrees and the remainder is minutes.
     
     - Parameters:
       - coordinate: The coordinate value in degrees and minutes (e.g., 4807.038 for 48°07.038').
       - direction: The cardinal direction ("N", "S", "E", or "W"). "S" and "W" yield negative values.
     - Returns: The coordinate converted to decimal degrees.
     */
    private func convertToDecimalDegrees(_ coordinate: Double, direction: String) -> CLLocationDegrees {
        let degrees = Double(Int(coordinate) / 100)
        let minutes = coordinate - (degrees * 100)
        let decimalDegrees = degrees + minutes / 60.0
        return (direction == "S" || direction == "W") ? -decimalDegrees : decimalDegrees
    }
}
