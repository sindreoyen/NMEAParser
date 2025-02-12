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
    
    /// The valid NMEA identifiers for GGA sentences from various constellations.
    static let validSentenceIdentifiers = GGAData.Identifiers.allCases.map { $0.rawValue }
    
    // MARK: - Public Methods
    
    /// Parses a raw GGA sentence string.
    func parse(sentence: String) throws -> GGAData {
        // Validate that the sentence starts with '$'
        guard sentence.first == "$" else {
            throw NMEAParserError.invalidFormat
        }
        
        // Validate that the sentence identifier is one of the supported types.
        guard GGAParser.validSentenceIdentifiers.contains(where: { sentence.hasPrefix($0) }) else {
            throw NMEAParserError.invalidFormat
        }
        
        // Validate checksum
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
        
        //  Split fields by comma.
        let trimmedDataPart = String(dataPart.dropFirst())
        let fields = trimmedDataPart.components(separatedBy: ",")
        
        // Ensure we have at least the expected number of fields.
        guard fields.count > 9 else {
            throw NMEAParserError.insufficientFields(expected: 10, got: fields.count)
        }
        
        // Parse individual fields.
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
