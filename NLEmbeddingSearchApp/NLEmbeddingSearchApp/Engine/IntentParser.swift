//
//  IntentParser.swift
//  NLEmbeddingSearch
//
//  Created by Preet Singh on 4/8/26.
//

import Foundation
import NaturalLanguage

/// Extracts structured intent from natural language queries using NLTagger.
///
/// Combines two NLTagger schemes:
/// - **lexicalClass**: POS tagging to pull out nouns and adjectives (the "meaty" words).
/// - **nameType**: Named entity recognition for place names, people, etc.
///
/// The extracted nouns/adjectives are mapped through a simple keyword → category
/// lookup. A production system would replace this with a trained classifier or
/// embeddings-based category matcher.
struct IntentParser {

    /// Parse a query string into a structured `SearchIntent`.
    func parse(_ query: String) -> SearchIntent {
        let tagger = NLTagger(tagSchemes: [.nameType, .lexicalClass])
        tagger.string = query

        var nouns: [String] = []
        var adjectives: [String] = []
        var entities: [String] = []

        let range = query.startIndex..<query.endIndex

        // Extract parts of speech
        tagger.enumerateTags(in: range, unit: .word, scheme: .lexicalClass) { tag, tokenRange in
            let word = String(query[tokenRange])
            switch tag {
            case .noun: nouns.append(word)
            case .adjective: adjectives.append(word)
            default: break
            }
            return true
        }

        // Extract named entities (places, people, organizations)
        tagger.enumerateTags(in: range, unit: .word, scheme: .nameType) { tag, tokenRange in
            if let tag, tag != .otherWord {
                entities.append(String(query[tokenRange]))
            }
            return true
        }

        // Map extracted words to a known category
        let category = inferCategory(from: nouns + adjectives)

        return SearchIntent(
            rawQuery: query,
            category: category,
            keywords: nouns + adjectives,
            entities: entities
        )
    }

    // MARK: - Private

    /// Simple keyword → category mapping. Extend this or replace with a classifier
    /// for broader category coverage.
    private let categoryMap: [String: String] = [
        "coffee": "cafe", "cafe": "cafe", "espresso": "cafe", "tea": "cafe",
        "food": "restaurant", "restaurant": "restaurant", "eat": "restaurant",
        "lunch": "restaurant", "dinner": "restaurant", "pizza": "restaurant",
        "work": "coworking", "office": "coworking", "desk": "coworking",
        "quiet": "cafe", "cozy": "cafe", "study": "coworking",
        "park": "outdoors", "outdoor": "outdoors", "garden": "outdoors",
        "walk": "outdoors", "nature": "outdoors",
    ]

    private func inferCategory(from words: [String]) -> String? {
        for word in words {
            if let category = categoryMap[word.lowercased()] {
                return category
            }
        }
        return nil
    }
}
