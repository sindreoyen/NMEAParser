//
//  GGAData.swift
//  NMEAParser
//
//  Created by Sindre on 12/02/2025.
//

import Foundation
import CoreLocation

/// Holds parsed data from a GGA sentence.
struct GGAData {
    let time: String?
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let fixType: GGAFixType
    let satellitesUsed: UInt8
    let hdop: Double
    let altitude: Double
}
