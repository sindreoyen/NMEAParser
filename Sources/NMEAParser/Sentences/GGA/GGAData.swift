//
//  GGAData.swift
//  NMEAParser
//
//  Created by Sindre on 12/02/2025.
//

import Foundation
import CoreLocation

/// Holds parsed data from a GGA sentence.
///
/// The GGA sentence (Global Positioning System Fix Data) provides essential fix data from a GNSS receiver.
/// It contains the following information:
/// - **UTC Time**: The time the fix was taken, in hhmmss.ss format.
/// - **Latitude**: The latitude in degrees and minutes (converted to decimal degrees).
/// - **Longitude**: The longitude in degrees and minutes (converted to decimal degrees).
/// - **Fix Type**: The quality of the fix (e.g., invalid, GPS fix, DGPS fix).
/// - **Satellites Used**: The number of satellites used to compute the fix.
/// - **HDOP**: Horizontal Dilution of Precision, which indicates the quality of the GPS signal.
/// - **Altitude**: The altitude (in meters) above mean sea level.
public struct GGAData {
    // MARK: - Attributes
    
    /// UTC time when the fix was taken, in hhmmss.ss format.
    public let time: String?
    /// Latitude of the receiver in decimal degrees.
    public let latitude: CLLocationDegrees
    /// Longitude of the receiver in decimal degrees.
    public let longitude: CLLocationDegrees
    /// Fix type indicating the quality of the position fix (e.g., invalid, GPS, DGPS).
    public let fixType: GGAFixType
    /// Number of satellites used in the fix.
    public let satellitesUsed: UInt8
    /// Horizontal Dilution of Precision (HDOP), representing the accuracy of the fix.
    public let hdop: Double
    /// Altitude in meters above mean sea level.
    public let altitude: Double
    
    // MARK: - Identifiers
    
    /// The identifiers of the NMEA sentence with the GGA data.
    ///
    /// These identifiers indicate the source GNSS and the specific sentence variant:
    /// - `$GNGGA`: GGA sentence from combined GPS and GLONASS.
    /// - `$GPGGA`: GGA sentence from GPS.
    /// - `$GLGGA`: GGA sentence from GLONASS.
    /// - `$GAGGA`: GGA sentence from GALILEO.
    public enum Identifier: String, CaseIterable {
        case gnGGA = "$GNGGA" // GGA sentence from GPS and GLONASS
        case gpGGA = "$GPGGA" // GGA sentence from GPS
        case glGGA = "$GLGGA" // GGA sentence from GLONASS
        case gaGGA = "$GAGGA" // GGA sentence from GALILEO
    }
}
