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
    
    /// Exposes a stream of parsed GGA data.
    var ggaPublisher: AnyPublisher<GGAData, Never> {
        return ggaSubject.eraseToAnyPublisher()
    }
    
    private let ggaParser = GGAParser()
    
    // MARK: - Init
    
    private init() { }
    
    // MARK: - Public Methods
    
    /// Parses a raw NMEA sentence and routes it to the correct parser.
    public func parse(sentence: String) {
        // Check the sentence type.
        if sentence.hasPrefix(GGAParser.sentenceIdentifier) {
            do {
                let data = try ggaParser.parse(sentence: sentence)
                ggaSubject.send(data)
            } catch {
                // Log the error, notify listeners via a separate error publisher,
                // or handle it however is appropriate for your app.
                print("Error parsing GGA sentence: \(error)")
            }
        } else {
            // Handle other sentence types or ignore.
            print("Unsupported sentence type: \(sentence)")
        }
    }
}
