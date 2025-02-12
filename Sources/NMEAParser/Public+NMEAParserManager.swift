//
//  NMEAParserManager.swift
//  NMEAParser
//
//  Created by Sindre on 12/02/2025.
//

import Combine

public final class NMEAParserManager {
    // MARK: - Attributes
    
    @MainActor static let shared = NMEAParserManager()
    
    // Publishers for different parsed outputs.
    private let ggaSubject = PassthroughSubject<GGAData, Never>()
    private let rawGGASubject = PassthroughSubject<String, Never>()
    var ggaPublisher: AnyPublisher<GGAData, Never> { ggaSubject.eraseToAnyPublisher() }
    var rawGGAPublisher: AnyPublisher<String, Never> { rawGGASubject.eraseToAnyPublisher() }
    
    // The GGAParser instance.
    private let ggaParser = GGAParser()
    
    // MARK: - Public Methods
    
    /// Parses a raw NMEA sentence and routes it to the correct parser.
    public func parse(sentence: String) {
        // Check if the sentence starts with any supported GGA identifier.
        if GGAParser.validSentenceIdentifiers.contains(where: { sentence.hasPrefix($0) }) {
            do {
                let data = try ggaParser.parse(sentence: sentence)
                rawGGASubject.send(sentence)
                ggaSubject.send(data)
            } catch {
                print("Error parsing GGA sentence: \(error)")
            }
        } else {
            // Handle other sentence types or ignore.
            print("Unsupported sentence type: \(sentence)")
        }
    }
}
