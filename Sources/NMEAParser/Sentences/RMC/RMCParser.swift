//
//  RMCParser.swift
//  NMEAParser
//
//  Created by Sindre on 14/02/2025.
//

import Foundation
import CoreLocation

/// Parses RMC NMEA sentences into `RMCData` objects.
final class RMCParser {
    // MARK: - Public Methods
    
    /**
     Parses a raw RMC sentence string into an `RMCData` object.
     
     The parser performs the following steps:
     
     1. Validates that the sentence starts with '$' and that its identifier is supported.
     2. Splits the sentence into its data and checksum parts.
     3. Validates that the checksum is correct.
     4. Extracts comma-separated fields.
     5. Converts fields into an `RMCData` instance.
     
     - Parameter sentence: The raw RMC sentence string.
     - Throws: An error of type `NMEAParserError` if the sentence is malformed or any field cannot be parsed.
     - Returns: An `RMCData` object populated with the parsed values.
     */
    func parse(sentence: String) throws -> RMCData {
        try validateStartAndIdentifier(sentence)
        
        let (dataPart, checksumPart) = try NMEAParserUtilities.splitSentence(sentence)
        try NMEAParserUtilities.validateChecksum(dataPart: dataPart, expected: checksumPart)
        
        let fields = NMEAParserUtilities.extractFields(from: dataPart)
        try NMEAParserUtilities.validateFieldCount(fields, minimumExpected: 12)
        
        return try parseRMCData(from: fields)
    }
    
    // MARK: - Private Methods
    
    /**
     Validates that the sentence starts with '$' and that its identifier is one of the supported RMC identifiers.
     
     - Parameter sentence: The raw NMEA sentence.
     - Throws: `NMEAParserError.invalidFormat` if the sentence format is wrong, or
       `NMEAParserError.unsupportedIdentifier` if the identifier is not recognized.
     */
    private func validateStartAndIdentifier(_ sentence: String) throws {
        guard let commaIndex = sentence.firstIndex(of: ",") else {
            throw NMEAParserError.invalidFormat
        }
        let identifier = String(sentence[sentence.startIndex..<commaIndex])
        guard RMCData.Identifier(rawValue: identifier) != nil else {
            throw NMEAParserError.unsupportedIdentifier(identifier: identifier)
        }
    }
    
    /**
     Parses the RMC data from the array of fields.
     
     Expected field order:
     
     - Field 0: Identifier (e.g., "GPRMC")
     - Field 1: Time (hhmmss.ss)
     - Field 2: Status ("A" for active, "V" for void)
     - Field 3: Latitude (ddmm.mmmm)
     - Field 4: N/S Indicator
     - Field 5: Longitude (dddmm.mmmm)
     - Field 6: E/W Indicator
     - Field 7: Speed over ground (knots, optional)
     - Field 8: Course over ground (degrees, optional)
     - Field 9: Date (ddmmyy, optional)
     - Field 10: Magnetic variation (degrees, optional)
     - Field 11: Magnetic variation direction (E/W, optional)
     - Field 12: Mode indicator (optional)
     
     - Parameter fields: The array of fields extracted from the sentence.
     - Returns: An `RMCData` object populated with the parsed values.
     - Throws: An error if any required field is invalid.
     */
    private func parseRMCData(from fields: [String]) throws -> RMCData {
        let timeField = fields[1]
        let statusField = fields[2]
        
        let latitude = try NMEAParserUtilities
            .parseCoordinate(from: fields, valueIndex: 3, directionIndex: 4, fieldName: "latitude")
        let longitude = try NMEAParserUtilities
            .parseCoordinate(from: fields, valueIndex: 5, directionIndex: 6, fieldName: "longitude")
        
        // Optional fields – if the field is empty, use nil.
        let speedOverGround = parseOptionalDouble(fields[7])
        let courseOverGround = parseOptionalDouble(fields[8])
        let dateField = fields[9].isEmpty ? nil : fields[9]
        let magneticVariation = parseOptionalDouble(fields[10])
        let magneticVariationDirection = fields[11].isEmpty ? nil : fields[11]
        let modeField = fields.count > 12 ? (fields[12].isEmpty ? nil : fields[12]) : nil
        
        return RMCData(
            time: timeField.isEmpty ? nil : timeField,
            status: statusField.isEmpty ? nil : statusField,
            latitude: latitude,
            longitude: longitude,
            speedOverGround: speedOverGround,
            courseOverGround: courseOverGround,
            date: dateField,
            magneticVariation: magneticVariation,
            magneticVariationDirection: magneticVariationDirection,
            mode: modeField
        )
    }
    
    /**
     Parses an optional Double value from a string.
     
     - Parameter field: The string representation of the field.
     - Returns: A Double if the field is non-empty and can be converted; otherwise, nil.
     */
    private func parseOptionalDouble(_ field: String) -> Double? {
        return field.isEmpty ? nil : Double(field)
    }
}
