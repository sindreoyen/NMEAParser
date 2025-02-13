//
//  NMEAParserError.swift
//  NMEAParser
//
//  Created by Sindre on 12/02/2025.
//

enum NMEAParserError: Error, CustomStringConvertible {
    // MARK: - Error cases
    case invalidFormat
    case insufficientFields(expected: Int, got: Int)
    case checksumMismatch(expected: String, computed: String)
    case invalidField(fieldName: String)
    case unsupportedIdentifier(identifier: String)
    
    // MARK: - CustomStringConvertible
    var description: String {
        switch self {
        case .invalidFormat:
            return "The NMEA sentence format is invalid."
        case let .insufficientFields(expected, got):
            return "Expected at least \(expected) fields but got \(got)."
        case let .checksumMismatch(expected, computed):
            return "Checksum mismatch: expected \(expected) but computed \(computed)."
        case let .invalidField(fieldName):
            return "Could not parse field '\(fieldName)'."
        case let .unsupportedIdentifier(identifier):
            return "Unsupported sentence identifier: \(identifier)."
        }
    }
}
