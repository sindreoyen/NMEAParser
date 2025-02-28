//
//  RMCData.swift
//  NMEAParser
//
//  Created by Sindre on 14/02/2025.
//

import Foundation
import CoreLocation

/// Holds parsed data from an RMC sentence.
///
/// The RMC sentence (Recommended Minimum Navigation Information) provides vital navigation data.
/// It contains the following information:
/// - **UTC Time**: The time the fix was taken, in hhmmss.ss format.
/// - **Status**: The validity status of the fix ('A' for active/valid, 'V' for void).
/// - **Latitude**: The latitude in degrees and minutes (converted to decimal degrees).
/// - **Longitude**: The longitude in degrees and minutes (converted to decimal degrees).
/// - **Speed Over Ground**: The speed of the receiver over the ground, in knots.
/// - **Course Over Ground**: The true course over ground, in degrees.
/// - **Date**: The date of the fix, in ddmmyy format.
/// - **Magnetic Variation**: The variation in the magnetic field, in degrees.
/// - **Magnetic Variation Direction**: The direction of the magnetic variation ('E' for east, 'W' for west).
/// - **Mode**: An optional mode indicator providing additional navigational information.
public struct RMCData {
    // MARK: - Attributes
    
    /// UTC time of the fix in hhmmss.ss format.
    public let time: String?
    /// Status of the fix; 'A' indicates valid data, while 'V' indicates void.
    public let status: String?
    /// Latitude of the receiver in decimal degrees.
    public let latitude: CLLocationDegrees
    /// Longitude of the receiver in decimal degrees.
    public let longitude: CLLocationDegrees
    /// Speed over ground in knots.
    public let speedOverGround: Double?
    /// Course over ground (true course) in degrees.
    public let courseOverGround: Double?
    /// Date of the fix in ddmmyy format.
    public let date: String?
    /// Magnetic variation in degrees.
    public let magneticVariation: Double?
    /// Direction of the magnetic variation; typically 'E' for east or 'W' for west.
    public let magneticVariationDirection: String?
    /// Mode indicator providing additional navigational information.
    public let mode: String?
    
    // MARK: - Identifiers
    
    /// The identifiers of the NMEA sentence with the RMC data.
    ///
    /// These identifiers indicate the source GNSS and the specific sentence variant:
    /// - `$GNRMC`: RMC sentence from combined GPS and GLONASS.
    /// - `$GPRMC`: RMC sentence from GPS.
    /// - `$GLRMC`: RMC sentence from GLONASS.
    /// - `$GARMC`: RMC sentence from GALILEO.
    public enum Identifier: String, CaseIterable {
        case gnRMC = "$GNRMC" // RMC sentence from GPS and GLONASS
        case gpRMC = "$GPRMC" // RMC sentence from GPS
        case glRMC = "$GLRMC" // RMC sentence from GLONASS
        case gaRMC = "$GARMC" // RMC sentence from GALILEO
    }
    
    // MARK: - Init
    /// The RMC sentence (Recommended Minimum Navigation Information) provides vital navigation data.
    /// It contains the following information:
    /// - Parameters:
    ///   - time: The time the fix was taken, in hhmmss.ss format.
    ///   - status: The validity status of the fix ('A' for active/valid, 'V' for void).
    ///   - latitude: The latitude in degrees and minutes (converted to decimal degrees).
    ///   - longitude: The longitude in degrees and minutes (converted to decimal degrees).
    ///   - speedOverGround: The speed of the receiver over the ground, in knots.
    ///   - courseOverGround: The true course over ground, in degrees.
    ///   - date: The date of the fix, in ddmmyy format.
    ///   - magneticVariation: The variation in the magnetic field, in degrees.
    ///   - magneticVariationDirection: The direction of the magnetic variation ('E' for east, 'W' for west).
    ///   - mode: An optional mode indicator providing additional navigational information.
    public init(time: String?,
                status: String?,
                latitude: CLLocationDegrees,
                longitude: CLLocationDegrees,
                speedOverGround: Double?,
                courseOverGround: Double?,
                date: String?,
                magneticVariation: Double?,
                magneticVariationDirection: String?,
                mode: String?) {
        self.time = time
        self.status = status
        self.latitude = latitude
        self.longitude = longitude
        self.speedOverGround = speedOverGround
        self.courseOverGround = courseOverGround
        self.date = date
        self.magneticVariation = magneticVariation
        self.magneticVariationDirection = magneticVariationDirection
        self.mode = mode
    }
}
