//
//  NMEAParserManager.swift
//  NMEAParser
//
//  Created by Sindre on 12/02/2025.
//

import Combine
import Foundation

/// A manager that processes raw NMEA sentences and publishes parsed GGA data.
///
/// This singleton manager receives raw NMEA sentences, determines if they are supported GGA sentences,
/// and then routes them to a dedicated parser. On successful parsing, it publishes both the raw sentence
/// and the parsed `GGAData` using Combine publishers. It also offers a thread-safe configuration
/// for enabling or disabling specific GGA sentence identifiers.
public final class NMEAParserManager {
    // MARK: - Attributes
    
    /// The shared singleton instance of `NMEAParserManager`.
    /// - Note: shared mutable states are synchronized using `syncQueue`.
    /// Thus, this singleton is thread-safe for reading and writing and
    /// the nonisolated(unsafe) can be ignored.
    nonisolated(unsafe) public static let shared = NMEAParserManager()
    
    // MARK: Publishers
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
    
    // MARK: Thread-Safe GGA Identifier Configuration
    /// The set of enabled GGA sentence identifiers.
    private var enabledGGAIdentifiers: Set<GGAData.Identifier> = []
    
    /// A serial dispatch queue to synchronize access to `enabledGGAIdentifiers`.
    private let syncQueue = DispatchQueue(label: "com.nmea.parser.manager.syncQueue")
    
    /// The enabled GGA sentence identifiers. Access is thread safe.
    public var ggaIdentifiers: Set<GGAData.Identifier> {
        get { syncQueue.sync { enabledGGAIdentifiers } }
        set { syncQueue.sync { enabledGGAIdentifiers = newValue } }
    }
    
    // MARK: Parsers
    /// The dedicated parser instance for GGA sentences.
    private let ggaParser = GGAParser()
    
    // MARK: - init
    
    /// Initializes a new instance of `NMEAParserManager`.
    ///
    /// This initializer sets the default enabled GGA sentence identifiers to include all available identifiers.
    private init() { self.enabledGGAIdentifiers = Set(GGAData.Identifier.allCases) }
    
    // MARK: - Public Methods
    
    /**
     Processes a raw NMEA sentence.
     
     This method first checks whether the incoming sentence is a supported GGA sentence.
     If it is, the sentence is parsed and both the raw sentence and parsed data are published.
     Otherwise, the sentence is ignored (with an informational log).
     
     - Parameter sentence: The raw NMEA sentence string.
     - Parameter verbose: Whether the method should print verbose logs. Defaults to `false`.
     */
    public func process(sentence: String, verbose: Bool = false) {
        if isSupportedGGASentence(sentence) {
            processGGASentence(sentence)
        } else {
            print("Unsupported sentence type: \(sentence)")
        }
    }
    
    /// Processes a raw NMEA sentence in Data format.
    /// 
    /// This method first checks whether the incoming sentence is a supported GGA sentence.
    /// If it is, the sentence is parsed and both the raw sentence and parsed data are published.
    /// Otherwise, the sentence is ignored (with an informational log).
    /// 
    /// - Parameters:
    ///   - sentence: the raw NMEA sentence in Data format.
    ///   - encoding: the encoding to use when converting the Data to a String. Defaults to `.ascii`.
    ///   - verbose: whether the method should print verbose logs. Defaults to `false`.
    /// - Warning: By default,`.ascii` is used for the conversion to a String. If it fails, the sentence is ignored.
    /// Make sure to use the correct encoding if the data is not ASCII encoded.
    public func process(sentence: Data?,
                        encoding: String.Encoding = .ascii,
                        verbose: Bool = false) {
        guard let sentence, let sentenceString = String(data: sentence, encoding: encoding) else {
            return
        }
        process(sentence: sentenceString, verbose: verbose)
    }
    
    // MARK: - Private Methods
    
    /**
     Checks if the provided sentence is a supported GGA sentence.
     
     A sentence is considered supported if it starts with one of the enabled GGA identifiers.
     
     - Parameter sentence: The raw NMEA sentence string.
     - Returns: `true` if the sentence is a supported GGA sentence; otherwise, `false`.
     */
    private func isSupportedGGASentence(_ sentence: String) -> Bool {
        return ggaIdentifiers.contains { sentence.hasPrefix($0.rawValue) }
    }
    
    /**
     Attempts to parse a GGA sentence and publish the results.
     
     This method uses the `GGAParser` to parse the sentence. If parsing is successful, it publishes the raw
     sentence via `rawGGASentenceSubject` and the parsed data via `ggaDataSubject`. Parsing errors are logged.
     
     - Parameter sentence: The raw GGA sentence string.
     - Parameter verbose: whether the method should print verbose logs. Defaults to `false`.
     */
    private func processGGASentence(_ sentence: String, verbose: Bool = false) {
        do {
            let parsedData = try ggaParser.parse(sentence: sentence)
            rawGGASentenceSubject.send(sentence)
            ggaDataSubject.send(parsedData)
        } catch {
            if verbose { print("Error parsing GGA sentence: \(error)") }
        }
    }
}
