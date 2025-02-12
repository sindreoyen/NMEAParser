//
//  GGAParser.swift
//  NMEAParser
//
//  Created by Sindre on 12/02/2025.
//

import Foundation
import CoreLocation

final class GGAParser: NMEASentenceParser {
    // MARK: - Attributes
    
    // The NMEA identifier for GGA sentences.
    static let sentenceIdentifier = "$GNGGA"
    
    // MARK: - Public Methods
    
    /// Parses a raw GGA sentence string.
    func parse(sentence: String) throws -> GGAData {
        // 1. Validate that the sentence starts with '$'
        guard sentence.first == "$" else {
            throw NMEAParserError.invalidFormat
        }
        
        // 2. Validate checksum
        let parts = sentence.components(separatedBy: "*")
        guard parts.count == 2,
              let dataPart = parts.first,
              let checksumPart = parts.last?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            throw NMEAParserError.invalidFormat
        }
        let computedChecksum = computeChecksum(for: dataPart)
        let computedChecksumStr = String(format: "%02X", computedChecksum)
        guard computedChecksumStr == checksumPart else {
            throw NMEAParserError.checksumMismatch(expected: checksumPart, computed: computedChecksumStr)
        }
        
        // 3. Split fields by comma.
        // Remove the leading "$" before splitting if desired.
        let trimmedDataPart = String(dataPart.dropFirst())
        let fields = trimmedDataPart.components(separatedBy: ",")
        
        // Ensure we have at least 10 fields (per your original enum)
        guard fields.count > 9 else {
            throw NMEAParserError.insufficientFields(expected: 10, got: fields.count)
        }
        
        // 4. Parse individual fields using safe unwrapping.
        // Field positions are defined by the GGA sentence:
        // 0: "GNGGA", 1: time, 2: latitude, 3: latitude direction, 4: longitude, 5: longitude direction, etc.
        let timeField = fields[1]
        
        guard let rawLat = Double(fields[2]) else {
            throw NMEAParserError.invalidField(fieldName: "latitude")
        }
        let latDirection = fields[3]
        let latitude = convertToDecimalDegrees(rawLat, direction: latDirection)
        
        guard let rawLon = Double(fields[4]) else {
            throw NMEAParserError.invalidField(fieldName: "longitude")
        }
        let lonDirection = fields[5]
        let longitude = convertToDecimalDegrees(rawLon, direction: lonDirection)
        
        guard let fixType = UInt8(fields[6]) else {
            throw NMEAParserError.invalidField(fieldName: "fixType")
        }
        guard let satellitesUsed = UInt8(fields[7]) else {
            throw NMEAParserError.invalidField(fieldName: "satellitesUsed")
        }
        guard let hdop = Double(fields[8]) else {
            throw NMEAParserError.invalidField(fieldName: "hdop")
        }
        guard let altitude = Double(fields[9]) else {
            throw NMEAParserError.invalidField(fieldName: "altitude")
        }
        
        return GGAData(
            time: timeField.isEmpty ? nil : timeField,
            latitude: latitude,
            longitude: longitude,
            fixType: GGAFixType(rawValue: fixType) ?? .invalid,
            satellitesUsed: satellitesUsed,
            hdop: hdop,
            altitude: altitude
        )
    }
    
    // MARK: - Private Methods
    
    /// Computes the checksum by XOR-ing all characters between "$" and "*" (not inclusive).
    private func computeChecksum(for dataPart: String) -> UInt8 {
        // Ensure that we start computing AFTER the '$'
        let trimmedData = dataPart.dropFirst() // Remove '$'
        
        var checksum: UInt8 = 0
        for char in trimmedData.utf8 {
            checksum ^= char
        }
        return checksum
    }
    
    /// Converts from NMEA “degrees and minutes” format to decimal degrees.
    private func convertToDecimalDegrees(_ coordinate: Double, direction: String) -> CLLocationDegrees {
        let degrees = Double(Int(coordinate) / 100)
        let minutes = coordinate - (degrees * 100)
        let decimalDegrees = degrees + minutes / 60.0
        return (direction == "S" || direction == "W") ? -decimalDegrees : decimalDegrees
    }
}
