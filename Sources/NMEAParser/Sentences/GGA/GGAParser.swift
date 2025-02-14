//
//  GGAParser.swift
//  NMEAParser
//
//  Created by Sindre on 12/02/2025.
//

import Foundation
import CoreLocation

/// Parses GGA NMEA sentences into `GGAData` objects.
final class GGAParser {
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
        
        let (dataPart, checksumPart) = try NMEAParserUtilities.splitSentence(sentence)
        try NMEAParserUtilities.validateChecksum(dataPart: dataPart, expected: checksumPart)
        
        let fields = NMEAParserUtilities.extractFields(from: dataPart)
        try NMEAParserUtilities.validateFieldCount(fields, minimumExpected: 10)
        
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
        let latitude = try NMEAParserUtilities
            .parseCoordinate(from: fields, valueIndex: 2, directionIndex: 3, fieldName: "latitude")
        
        // Fields 4 & 5: Longitude and its direction.
        let longitude = try NMEAParserUtilities
            .parseCoordinate(from: fields, valueIndex: 4, directionIndex: 5, fieldName: "longitude")
        
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
}
