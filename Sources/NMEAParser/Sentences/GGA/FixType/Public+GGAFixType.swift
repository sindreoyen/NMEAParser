//
//  GGAFixType.swift
//  NMEAParser
//
//  Created by Sindre on 12/02/2025.
//

public enum GGAFixType: UInt8 {
    
    // MARK: - Cases
    
    /// Invalid, no position available.
    case invalid = 0
    
    /// Autonomous GPS fix, no correction data used.
    case autonomous = 1
    
    /// DGPS fix, using a local DGPS base station or correction service such as WAAS or EGNOS.
    case dgps = 2
    
    /// PPS fix
    case pps = 3
    
    /// RTK fix, high accuracy Real Time Kinematic.
    case rtk = 4
    
    /// RTK Float, better than DGPS, but not quite RTK.
    case rtkFloat = 5
    
    /// Estimated fix (dead reckoning).
    case estimated = 6
    
    /// Manual input mode.
    case manualInput = 7
    
    /// Simulation mode.
    case simulation = 8
    
    /// WAAS fix (not NMEA standard, but NovAtel receivers report this instead of a 2).
    case waas = 9
}
