//
//  SearchEngine.swift
//  NLEmbeddingSearch
//
//  Created by Preet Singh on 4/8/26.
//

import Combine
import Foundation
import NaturalLanguage

/// Orchestrates the semantic search pipeline: parse intent → embed query → rank results.
///
/// This is the main entry point for the UI layer. It coordinates between the
/// `IntentParser` (extracts structured intent from natural language) and the
/// `EmbeddingIndexer` (vector similarity search), then applies category boosts
/// to refine ranking.
///
/// Marked `@MainActor` so published properties update the UI directly.
@MainActor
final class SearchEngine: ObservableObject {
    @Published var results: [SearchResult] = []
    @Published var isSearching = false

    private let indexer = EmbeddingIndexer()
    private let intentParser = IntentParser()

    /// Load items into the embedding index. Call once at startup.
    func loadListings(_ items: [ListingItem]) async {
        await indexer.buildIndex(from: items)
    }

    /// Run a semantic search and update `results`.
    ///
    /// The pipeline:
    /// 1. Parse the query into a `SearchIntent` (category, keywords, entities).
    /// 2. Embed the query and find similar items via cosine similarity.
    /// 3. Boost results whose category matches the extracted intent.
    /// 4. Re-sort and truncate to the top 10.
    func search(query: String) async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            results = []
            return
        }

        isSearching = true
        defer { isSearching = false }

        let intent = intentParser.parse(trimmed)
        let scored = await indexer.findSimilar(to: trimmed, topK: 20)

        // Boost results that match the extracted intent category
        let boosted = scored.map { result -> SearchResult in
            var adjusted = result
            if let category = intent.category,
               result.item.category.localizedCaseInsensitiveContains(category) {
                adjusted.score = min(adjusted.score * 1.3, 1.0) // Cap at 1.0
            }
            return adjusted
        }

        results = boosted
            .sorted { $0.score > $1.score }
            .prefix(10)
            .map { $0 }
    }
}
