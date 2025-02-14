//
//  NMEAParserManager.swift
//  NMEAParser
//
//  Created by Sindre on 12/02/2025.
//

import Combine
import Foundation

/// A manager that processes raw NMEA sentences and publishes parsed data.
///
/// This singleton manager receives raw NMEA sentences, determines if they are supported
/// (either GGA or RMC), and routes them to the dedicated parser. On successful parsing,
/// it publishes both the raw sentence and the parsed data (`GGAData` or `RMCData`) using Combine publishers.
/// Thread-safe configuration is provided for enabling/disabling specific sentence identifiers.
public final class NMEAParserManager: @unchecked Sendable {
    // MARK: - Attributes
    
    /// The shared singleton instance of `NMEAParserManager`.
    /// - Note: Access to shared mutable states is synchronized using `syncQueue` to ensure thread safety.
    public static let shared = NMEAParserManager()
    
    // MARK: Publishers - GGA
    
    /// Publishes successfully parsed `GGAData` objects.
    private let ggaDataSubject = PassthroughSubject<GGAData, Never>()
    
    /// Publishes raw GGA sentences that have been successfully parsed.
    private let rawGGASentenceSubject = PassthroughSubject<String, Never>()
    
    /// A publisher for parsed `GGAData`.
    public var ggaDataPublisher: AnyPublisher<GGAData, Never> {
        ggaDataSubject.eraseToAnyPublisher()
    }
    
    /// A publisher for raw GGA sentences.
    public var rawGGASentencePublisher: AnyPublisher<String, Never> {
        rawGGASentenceSubject.eraseToAnyPublisher()
    }
    
    // MARK: Publishers - RMC
    
    /// Publishes successfully parsed `RMCData` objects.
    private let rmcDataSubject = PassthroughSubject<RMCData, Never>()
    
    /// Publishes raw RMC sentences that have been successfully parsed.
    private let rawRMCSentenceSubject = PassthroughSubject<String, Never>()
    
    /// A publisher for parsed `RMCData`.
    public var rmcDataPublisher: AnyPublisher<RMCData, Never> {
        rmcDataSubject.eraseToAnyPublisher()
    }
    
    /// A publisher for raw RMC sentences.
    public var rawRMCSentencePublisher: AnyPublisher<String, Never> {
        rawRMCSentenceSubject.eraseToAnyPublisher()
    }
    
    // MARK: Thread-Safe Identifier Configuration
    
    /// The set of enabled GGA sentence identifiers.
    private var enabledGGAIdentifiers: Set<GGAData.Identifier> = []
    
    /// The set of enabled RMC sentence identifiers.
    private var enabledRMCIdentifiers: Set<RMCData.Identifier> = []
    
    /// A serial dispatch queue to synchronize access to configuration.
    private let syncQueue = DispatchQueue(label: "com.nmea.parser.manager.syncQueue")
    
    /// The enabled GGA sentence identifiers (thread-safe).
    public var supportedGGAIdentifiers: Set<GGAData.Identifier> {
        get { syncQueue.sync { enabledGGAIdentifiers } }
        set { syncQueue.sync(flags: .barrier) { enabledGGAIdentifiers = newValue } }
    }
    
    /// The enabled RMC sentence identifiers (thread-safe).
    public var supportedRMCSentenceIdentifiers: Set<RMCData.Identifier> {
        get { syncQueue.sync { enabledRMCIdentifiers } }
        set { syncQueue.sync(flags: .barrier) { enabledRMCIdentifiers = newValue } }
    }
    
    // MARK: Parsers
    
    /// The dedicated parser instance for GGA sentences.
    private let ggaParser = GGAParser()
    
    /// The dedicated parser instance for RMC sentences.
    private let rmcParser = RMCParser()
    
    // MARK: - init
    
    /// Initializes a new instance of `NMEAParserManager` with default configuration.
    private init() {
        self.enabledGGAIdentifiers = Set(GGAData.Identifier.allCases)
        self.enabledRMCIdentifiers = Set(RMCData.Identifier.allCases)
    }
    
    // MARK: - Public Methods
    
    /**
     Attempts to parse a GGA sentence and publish the results.
     
     This method uses the `GGAParser` to parse the sentence. If parsing is successful,
     it publishes the raw sentence via `rawGGASentenceSubject` and the parsed data via `ggaDataSubject`.
     Parsing errors are logged if `verbose` is enabled.
     
     - Parameters:
       - sentence: The raw GGA sentence string.
       - verbose: Whether to print verbose logs. Defaults to `false`.
     */
    func processGGASentence(_ sentence: String, verbose: Bool = false) {
        do {
            let parsedData = try ggaParser.parse(sentence: sentence)
            rawGGASentenceSubject.send(sentence)
            ggaDataSubject.send(parsedData)
        } catch {
            if verbose { print("Error parsing GGA sentence: \(error)") }
        }
    }
    
    /**
     Checks if the provided sentence is a supported GGA sentence.
     
     A sentence is considered supported if it starts with one of the enabled GGA identifiers.
     
     - Parameter sentence: The raw NMEA sentence.
     - Returns: `true` if the sentence is a supported GGA sentence; otherwise, `false`.
     */
    func isSupportedGGASentence(_ sentence: String) -> Bool {
        return supportedGGAIdentifiers.contains { sentence.hasPrefix($0.rawValue) }
    }
    
    /**
     Attempts to parse an RMC sentence and publish the results.
     
     Uses the `RMCParser` to parse the sentence. On success, publishes the raw sentence and parsed data.
     Parsing errors are logged if `verbose` is enabled.
     
     - Parameters:
       - sentence: The raw RMC sentence string.
       - verbose: Whether to print verbose logs. Defaults to `false`.
     */
    func processRMCSentence(_ sentence: String, verbose: Bool = false) {
        do {
            let parsedData = try rmcParser.parse(sentence: sentence)
            rawRMCSentenceSubject.send(sentence)
            rmcDataSubject.send(parsedData)
        } catch {
            if verbose { print("Error parsing RMC sentence: \(error)") }
        }
    }
    
    /**
     Checks if the provided sentence is a supported RMC sentence.
     
     - Parameter sentence: The raw NMEA sentence.
     - Returns: `true` if the sentence is a supported RMC sentence; otherwise, `false`.
     */
    func isSupportedRMCSentence(_ sentence: String) -> Bool {
        return supportedRMCSentenceIdentifiers.contains { sentence.hasPrefix($0.rawValue) }
    }
}
