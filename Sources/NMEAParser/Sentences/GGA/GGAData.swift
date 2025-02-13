//
//  GGAData.swift
//  NMEAParser
//
//  Created by Sindre on 12/02/2025.
//

import Foundation
import CoreLocation

/// Holds parsed data from a GGA sentence.
public struct GGAData {
    // MARK: - Attributes
    let time: String?
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let fixType: GGAFixType
    let satellitesUsed: UInt8
    let hdop: Double
    let altitude: Double
    
    // MARK: - Identifiers
    /// The identifiers of the NMEA sentence with the GGA data.
    /// - Note: The identifiers are separated by the global navigation satellite system (GNSS) they belong to.
    public enum Identifier: String, CaseIterable {
        case gnGGA = "$GNGGA" // GGA sentence from GPS and GLONASS
        case gpGGA = "$GPGGA" // GGA sentence from GPS
        case glGGA = "$GLGGA" // GGA sentence from GLONASS
        case gaGGA = "$GAGGA" // GGA sentence from GALILEO
    }
}
