//
//  SimilarityScorer.swift
//  NLEmbeddingSearch
//
//  Created by Preet Singh on 4/8/26.
//

import Foundation

/// Computes cosine similarity between embedding vectors.
///
/// Cosine similarity measures the angle between two vectors in high-dimensional space,
/// returning a value from -1 (opposite) to 1 (identical). This is the standard metric
/// for comparing text embeddings because it captures semantic direction regardless of
/// magnitude — "quiet coffee shop" and "peaceful cafe" point in similar directions
/// even though their raw vectors differ in scale.
enum SimilarityScorer {

    /// Compute cosine similarity between two vectors: dot(a, b) / (||a|| * ||b||)
    ///
    /// - Parameters:
    ///   - a: First embedding vector.
    ///   - b: Second embedding vector. Must have the same dimensionality as `a`.
    /// - Returns: Similarity score in [-1, 1], or 0 if vectors are empty or mismatched.
    static func cosine(_ a: [Double], _ b: [Double]) -> Double {
        guard a.count == b.count, !a.isEmpty else { return 0 }

        var dot = 0.0
        var normA = 0.0
        var normB = 0.0

        for i in 0..<a.count {
            dot += a[i] * b[i]
            normA += a[i] * a[i]
            normB += b[i] * b[i]
        }

        let denominator = sqrt(normA) * sqrt(normB)
        return denominator > 0 ? dot / denominator : 0
    }

    /// Rank items by similarity to a query vector, returning the top K results.
    ///
    /// - Parameters:
    ///   - queryVector: The embedding vector for the search query.
    ///   - candidates: Pairs of items and their pre-computed embedding vectors.
    ///   - topK: Maximum number of results to return.
    /// - Returns: Sorted array of `SearchResult` with highest similarity first.
    static func rank<T>(
        query queryVector: [Double],
        against candidates: [(item: T, vector: [Double])],
        topK: Int,
        transform: (T, Double) -> SearchResult
    ) -> [SearchResult] {
        candidates
            .map { candidate in
                let score = cosine(queryVector, candidate.vector)
                return transform(candidate.item, score)
            }
            .sorted { $0.score > $1.score }
            .prefix(topK)
            .map { $0 }
    }
}
