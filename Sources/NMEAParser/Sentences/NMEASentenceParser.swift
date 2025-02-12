//
//  NMEASentenceParser.swift
//  NMEAParser
//
//  Created by Sindre on 12/02/2025.
//

protocol NMEASentenceParser {
    associatedtype Output
    /// Parses a raw NMEA sentence string.
    /// - Parameter sentence: The complete raw sentence.
    /// - Throws: An error if the sentence is malformed or fields cannot be parsed.
    /// - Returns: A parsed data structure of type `Output`.
    func parse(sentence: String) throws -> Output
}
