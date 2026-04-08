//
//  SimilarityScorerTests.swift
//  NLEmbeddingSearch
//
//  Created by Preet Singh on 4/8/26.
//

import Testing
@testable import NLEmbeddingSearch

@Suite("SimilarityScorer")
struct SimilarityScorerTests {

    @Test("Identical vectors return similarity of 1.0")
    func identicalVectors() {
        let vec = [1.0, 0.0, 0.0]
        let score = SimilarityScorer.cosine(vec, vec)
        #expect(abs(score - 1.0) < 1e-10)
    }

    @Test("Orthogonal vectors return similarity of 0.0")
    func orthogonalVectors() {
        let a = [1.0, 0.0, 0.0]
        let b = [0.0, 1.0, 0.0]
        let score = SimilarityScorer.cosine(a, b)
        #expect(abs(score) < 1e-10)
    }

    @Test("Opposite vectors return similarity of -1.0")
    func oppositeVectors() {
        let a = [1.0, 0.0]
        let b = [-1.0, 0.0]
        let score = SimilarityScorer.cosine(a, b)
        #expect(abs(score - (-1.0)) < 1e-10)
    }

    @Test("Empty vectors return 0.0")
    func emptyVectors() {
        let score = SimilarityScorer.cosine([], [])
        #expect(score == 0.0)
    }

    @Test("Mismatched dimensions return 0.0")
    func mismatchedDimensions() {
        let score = SimilarityScorer.cosine([1.0, 2.0], [1.0])
        #expect(score == 0.0)
    }

    @Test("Similar vectors score higher than dissimilar ones")
    func similarVsUnsimilar() {
        let query = [1.0, 1.0, 0.0]
        let similar = [0.9, 1.1, 0.0]
        let dissimilar = [0.0, 0.0, 1.0]

        let scoreSimilar = SimilarityScorer.cosine(query, similar)
        let scoreDissimilar = SimilarityScorer.cosine(query, dissimilar)

        #expect(scoreSimilar > scoreDissimilar)
    }
}
