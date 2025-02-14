//
//  NMEAParserUtilities.swift
//  NMEAParser
//
//  Created by Sindre on 14/02/2025.
//

import Foundation
import CoreLocation

/// Utility functions common to parsing NMEA sentences.
enum NMEAParserUtilities {
    // MARK: - Checksum validation
    
    /**
     Validates the checksum of an NMEA sentence.
     
     - Parameters:
       - dataPart: The part of the sentence containing the data (including the leading '$').
       - expected: The expected checksum (as a hexadecimal string).
     - Throws: `NMEAParserError.checksumMismatch` if the computed checksum does not match the expected value.
     */
    static func validateChecksum(dataPart: String, expected: String) throws {
        let computedChecksum = computeChecksum(for: dataPart)
        let computedChecksumStr = String(format: "%02X", computedChecksum)
        guard computedChecksumStr == expected else {
            throw NMEAParserError.checksumMismatch(expected: expected, computed: computedChecksumStr)
        }
    }
    
    /**
     Computes the checksum for a given data part of an NMEA sentence.
     
     The checksum is computed by XOR-ing all characters between '$' and '*' (excluding both).
     
     - Parameter dataPart: The part of the sentence containing the data (including the leading '$').
     - Returns: The computed checksum as a UInt8.
     */
    static func computeChecksum(for dataPart: String) -> UInt8 {
        let trimmedData = dataPart.dropFirst() // remove the leading '$'
        var checksum: UInt8 = 0
        for char in trimmedData.utf8 {
            checksum ^= char
        }
        return checksum
    }
    
    // MARK: - Sentence parsing
    
    /**
     Splits an NMEA sentence into its data part and checksum part.
     
     The expected format is:
     
         $<data>*<checksum>
     
     - Parameter sentence: The raw NMEA sentence.
     - Returns: A tuple containing the data part and the trimmed checksum.
     - Throws: `NMEAParserError.invalidFormat` if the sentence does not contain exactly one "*" character.
     */
    static func splitSentence(_ sentence: String) throws -> (dataPart: String, checksumPart: String) {
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
     Extracts comma-separated fields from the data part of an NMEA sentence.
     
     - Parameter dataPart: The part of the sentence containing the data (including the leading '$').
     - Returns: An array of strings representing each field.
     */
    static func extractFields(from dataPart: String) -> [String] {
        let trimmedDataPart = String(dataPart.dropFirst()) // remove '$'
        return trimmedDataPart.components(separatedBy: ",")
    }
    
    /**
     Validates that the number of fields meets a specified minimum.
     
     - Parameters:
       - fields: The array of extracted fields.
       - minimumExpected: The minimum number of fields required.
     - Throws: `NMEAParserError.insufficientFields` if there are fewer than `minimumExpected` fields.
     */
    static func validateFieldCount(_ fields: [String], minimumExpected: Int) throws {
        guard fields.count >= minimumExpected else {
            throw NMEAParserError.insufficientFields(expected: minimumExpected, got: fields.count)
        }
    }
    
    /**
     Parses a coordinate from the specified fields and converts it to decimal degrees.
     
     - Parameters:
       - fields: The array of fields from the sentence.
       - valueIndex: The index for the coordinate value (in "degrees and minutes" format).
       - directionIndex: The index for the cardinal direction ("N", "S", "E", "W").
       - fieldName: A name for the field used in error reporting.
     - Returns: The coordinate in decimal degrees.
     - Throws: `NMEAParserError.invalidField` if conversion fails.
     */
    static func parseCoordinate(from fields: [String], valueIndex: Int, directionIndex: Int, fieldName: String) throws -> CLLocationDegrees {
        guard let rawValue = Double(fields[valueIndex]) else {
            throw NMEAParserError.invalidField(fieldName: fieldName)
        }
        let direction = fields[directionIndex]
        return convertToDecimalDegrees(rawValue, direction: direction)
    }
    
    /**
     Converts a coordinate from NMEA “degrees and minutes” format to decimal degrees.
     
     - Parameters:
       - coordinate: The coordinate in "degrees and minutes" format (e.g., 4807.038).
       - direction: The cardinal direction ("N", "S", "E", or "W"). Negative for "S" and "W".
     - Returns: The coordinate in decimal degrees.
     */
    private static func convertToDecimalDegrees(_ coordinate: Double, direction: String) -> CLLocationDegrees {
        let degrees = Double(Int(coordinate) / 100)
        let minutes = coordinate - (degrees * 100)
        let decimalDegrees = degrees + minutes / 60.0
        return (direction == "S" || direction == "W") ? -decimalDegrees : decimalDegrees
    }
}
