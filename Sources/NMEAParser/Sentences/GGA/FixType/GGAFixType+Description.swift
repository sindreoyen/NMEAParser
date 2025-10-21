//
//  GGAFixType+Description.swift
//  CommonModule
//
//  Created by Sindre on 08/11/2024.
//

import SwiftUI

public extension GGAFixType {
    /// A detailed, human-readable description of the GNSS fix type.
    ///
    /// This provides additional context on the type of fix used for positioning.
    var description: String {
        switch self {
        case .invalid:
            return "Invalid, no position available."
        case .autonomous:
            return "Autonomous GPS fix, no correction data used."
        case .dgps:
            return "DGPS fix, using a local DGPS base station or correction service such as WAAS or EGNOS."
        case .pps:
            return "PPS"
        case .rtk:
            return "RTK fix, high accuracy Real Time Kinematic."
        case .rtkFloat:
            return "RTK Float, better than DGPS, but not quite RTK Fix."
        case .estimated:
            return "Estimated fix (dead reckoning)."
        case .manualInput:
            return "Manual input mode."
        case .simulation:
            return "Simulation mode."
        case .waas:
            return "WAAS fix (not NMEA standard, but NovAtel receivers report this instead of a 2)."
        }
    }
    
    /// A concise label for the GNSS fix type.
    ///
    /// This is useful for displaying a shorter version of the fix type in UI elements.
    var shortDescription: String {
        switch self {
        case .invalid:
            return "Invalid"
        case .autonomous:
            return "GPS"
        case .dgps:
            return "DGPS"
        case .pps:
            return "PPS"
        case .rtk:
            return "RTK Fix"
        case .rtkFloat:
            return "RTK Float"
        case .estimated:
            return "Estimated"
        case .manualInput:
            return "Manual Input"
        case .simulation:
            return "Simulation"
        case .waas:
            return "WAAS"
        }
    }
    
    /// A numeric representation of fix reliability, ranging from **0.0** (no fix) to **1.0** (RTK Fix).
    ///
    /// This is primarily used for UI representation, such as signal strength indicators.
    ///
    /// - Values:
    ///   - **1.0** → RTK Fix (highest accuracy)
    ///   - **0.75** → RTK Float (sub-meter accuracy)
    ///   - **0.5** → DGPS Fix (meter-level accuracy)
    ///   - **0.25** → Autonomous GPS Fix (standard GNSS accuracy)
    ///   - **0.0** → All other fix types (invalid, estimated, manual, simulation)
    ///
    /// - Example usage:
    /// ```swift
    /// Image(systemName: "cellularbars", variableValue: fixType.strength)
    /// ```
    var strength: Double {
        switch self {
        case .rtk:
            return 1.0
        case .rtkFloat:
            return 0.75
        case .dgps:
            return 0.5
        case .autonomous:
            return 0.25
        default:
            return 0
        }
    }
    
    /// A color representation of the GNSS fix type for UI purposes.
    ///
    /// - Colors:
    ///   - **Green** → RTK Fix (best accuracy)
    ///   - **Yellow** → RTK Float (sub-meter accuracy)
    ///   - **Orange** → DGPS Fix (meter-level accuracy)
    ///   - **Red** → Autonomous GPS Fix (weaker accuracy)
    ///   - **Gray (secondary)** → All other fix types (invalid, estimated, manual, simulation)
    var color: Color {
        switch self {
        case .rtk:
            return .green
        case .rtkFloat:
            return .yellow
        case .dgps:
            return .orange
        case.autonomous:
            return .red
        default:
            return .secondary
        }
    }
}
