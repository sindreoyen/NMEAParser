//
//  NMEAParserManager+Process.swift
//  NMEAParser
//
//  Created by Sindre on 13/02/2025.
//

import Foundation

public extension NMEAParserManager {
    /**
     Processes a raw NMEA sentence string.
     
     This method splits the input into individual sentences (by the '$' character),
     and for each sentence, checks if it is supported as either a GGA or RMC sentence.
     The sentence is then passed to the appropriate parser.
     
     - Parameters:
       - sentence: The raw NMEA sentence string.
       - verbose: Whether to print verbose logs. Defaults to `false`.
     */
    func process(sentence: String, verbose: Bool = false) {
        // Split the input by "$". If the string starts with "$", the first element will be empty.
        let rawSentences = sentence.components(separatedBy: "$")
        
        // Reconstruct sentences by prepending the '$' sign.
        let sentences = rawSentences.enumerated().compactMap { (index, part) -> String? in
            guard !part.isEmpty else { return nil }
            return "$" + part
        }
        
        // Process each sentence concurrently.
        DispatchQueue.concurrentPerform(iterations: sentences.count) { [weak self] index in
            guard let self else { return }
            let sentence = sentences[index]
            if isSupportedGGASentence(sentence) {
                processGGASentence(sentence, verbose: verbose)
            } else if isSupportedRMCSentence(sentence) {
                processRMCSentence(sentence, verbose: verbose)
            } else if verbose {
                print("Unsupported sentence type: \(sentence)")
            }
        }
    }
    
    /**
     Processes a raw NMEA sentence provided in Data format.
     
     This method attempts to convert the Data to a String using the specified encoding
     (defaulting to ASCII), and then processes the sentence.
     
     - Parameters:
       - sentence: The raw NMEA sentence in Data format.
       - encoding: The string encoding to use. Defaults to `.ascii`.
       - verbose: Whether to print verbose logs. Defaults to `false`.
     - Note: If the data cannot be converted using the given encoding, the sentence is ignored.
     */
    func process(sentence: Data?,
                 encoding: String.Encoding = .ascii,
                 verbose: Bool = false) {
        guard let sentence,
              let sentenceString = String(data: sentence, encoding: encoding) else {
            return
        }
        process(sentence: sentenceString, verbose: verbose)
    }
}
