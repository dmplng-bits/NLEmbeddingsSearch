//
//  Models.swift
//  NLEmbeddingSearch
//
//  Created by Preet Singh on 4/8/26.
//

import Foundation

// MARK: - ListingItem

/// A searchable item in the dataset (e.g., a place, product, or listing).
///
/// `searchableText` concatenates the fields that should contribute to the
/// embedding vector. Adjust this computed property to change what the
/// semantic search "sees."
struct ListingItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let category: String
    let rating: Double

    /// Combined text used for embedding generation.
    var searchableText: String {
        "\(title) \(description) \(category)"
    }
}

extension ListingItem {
    /// Hardcoded samples for previews and playgrounds when the JSON bundle isn't available.
    static let samples: [ListingItem] = [
        .init(id: UUID(), title: "Quiet coffee shop with WiFi", description: "A peaceful spot with fast internet, perfect for remote work", category: "cafe", rating: 4.7),
        .init(id: UUID(), title: "Sunny rooftop coworking", description: "Open-air workspace with city views and standing desks", category: "coworking", rating: 4.5),
        .init(id: UUID(), title: "Italian trattoria downtown", description: "Authentic pasta and wood-fired pizza in a cozy setting", category: "restaurant", rating: 4.8),
        .init(id: UUID(), title: "Riverside park with benches", description: "Quiet green space along the water, great for reading", category: "outdoors", rating: 4.3),
        .init(id: UUID(), title: "24-hour diner", description: "Classic American diner with bottomless coffee and late-night vibes", category: "restaurant", rating: 4.1),
        .init(id: UUID(), title: "Library reading room", description: "Historic building with high ceilings and complete silence", category: "coworking", rating: 4.6),
        .init(id: UUID(), title: "Artisan bakery and cafe", description: "Fresh pastries, single-origin espresso, and communal tables", category: "cafe", rating: 4.9),
        .init(id: UUID(), title: "Botanical garden", description: "Lush outdoor space with walking paths and seasonal flowers", category: "outdoors", rating: 4.4),
    ]
}

// MARK: - SearchResult

/// A listing paired with its similarity score from the current query.
struct SearchResult: Identifiable {
    let id = UUID()
    let item: ListingItem
    var score: Double
}

// MARK: - SearchIntent

/// Structured representation of what the user is looking for,
/// extracted from their natural language query via NLTagger.
struct SearchIntent {
    let rawQuery: String
    let category: String?
    let keywords: [String]
    let entities: [String]
}
