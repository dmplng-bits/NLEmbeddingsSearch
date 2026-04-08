//
//  EmbeddingIndexer.swift
//  NLEmbeddingSearch
//
//  Created by Preet Singh on 4/8/26.
//

import Foundation
import NaturalLanguage

/// Builds an in-memory embedding index and performs vector similarity search.
///
/// Uses Apple's `NLEmbedding` to convert text into dense vectors, then ranks
/// results by cosine similarity. The actor isolation guarantees thread-safe
/// access to the index — callers can search from any task without data races.
///
/// **How it works:**
/// 1. `buildIndex(from:)` tokenizes each listing's searchable text and averages
///    the per-word embeddings into a single vector (mean pooling).
/// 2. `findSimilar(to:topK:)` embeds the query the same way, then scores
///    every indexed item using cosine similarity via `SimilarityScorer`.
///
/// **Limitations:**
/// - Mean-pooled word embeddings lose word order ("dog bites man" ≈ "man bites dog").
/// - `NLEmbedding.wordEmbedding` may not cover domain-specific terms.
/// - For production, consider `NLEmbedding.sentenceEmbedding` (iOS 17+) or
///   a Core ML sentence transformer for better accuracy.
actor EmbeddingIndexer {
    private var embeddings: [(item: ListingItem, vector: [Double])] = []
    private let embedding: NLEmbedding?

    init() {
        self.embedding = NLEmbedding.wordEmbedding(for: .english)
    }

    /// Index all listings by computing sentence embeddings from their searchable text.
    func buildIndex(from items: [ListingItem]) {
        embeddings = items.compactMap { item in
            guard let vector = sentenceVector(for: item.searchableText) else { return nil }
            return (item: item, vector: vector)
        }
    }

    /// Find the top-K most similar items to the query string.
    func findSimilar(to query: String, topK: Int = 10) -> [SearchResult] {
        guard let queryVector = sentenceVector(for: query) else { return [] }

        return SimilarityScorer.rank(
            query: queryVector,
            against: embeddings,
            topK: topK
        ) { item, score in
            SearchResult(item: item, score: score)
        }
    }

    // MARK: - Private

    /// Compute a sentence-level vector by averaging word embeddings (mean pooling).
    ///
    /// This is a lightweight baseline that works on iOS 15+. For higher quality,
    /// use `NLEmbedding.sentenceEmbedding(for:)` on iOS 17+ or bring your own
    /// Core ML sentence transformer model.
    private func sentenceVector(for text: String) -> [Double]? {
        guard let embedding else { return nil }

        let lowered = text.lowercased()
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = lowered

        var vectors: [[Double]] = []
        tokenizer.enumerateTokens(in: lowered.startIndex..<lowered.endIndex) { range, _ in
            let word = String(lowered[range])
            if let vec = embedding.vector(for: word) {
                vectors.append(vec)
            }
            return true
        }

        guard !vectors.isEmpty else { return nil }

        // Mean pooling: average all word vectors into one sentence vector
        let dimension = vectors[0].count
        var avg = [Double](repeating: 0, count: dimension)
        for vec in vectors {
            for i in 0..<dimension { avg[i] += vec[i] }
        }
        for i in 0..<dimension { avg[i] /= Double(vectors.count) }
        return avg
    }
}
