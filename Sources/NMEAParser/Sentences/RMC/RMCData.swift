//
//  RMCData.swift
//  NMEAParser
//
//  Created by Sindre on 14/02/2025.
//

import Foundation
import CoreLocation

// $GNRMC,180201.80,A,6325.8068737,N,01025.0920747,E,0.074,,140225,,,A,V*1B
public struct RMCData {
    // MARK: - Attributes
    public let time: String?
    public let status: String?
    public let latitude: CLLocationDegrees
    public let longitude: CLLocationDegrees
    public let speedOverGround: Double?
    public let courseOverGround: Double?
    public let date: String?
    public let magneticVariation: Double?
    public let magneticVariationDirection: String?
    public let mode: String?
    
    // MARK: - Identifiers
    /// The identifiers of the NMEA sentence with the RMC data.
    /// - Note: The identifiers are separated by the global navigation satellite system (GNSS) they belong to.
    public enum Identifier: String, CaseIterable {
        case gnRMC = "$GNRMC" // RMC sentence from GPS and GLONASS
        case gpRMC = "$GPRMC" // RMC sentence from GPS
        case glRMC = "$GLRMC" // RMC sentence from GLONASS
        case gaRMC = "$GARMC" // RMC sentence from GALILEO
    }
}
