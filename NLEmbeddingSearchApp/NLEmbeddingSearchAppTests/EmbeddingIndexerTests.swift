//
//  EmbeddingIndexerTests.swift
//  NLEmbeddingSearch
//
//  Created by Preet Singh on 4/8/26.
//

import Testing
@testable import NLEmbeddingSearch

@Suite("EmbeddingIndexer")
struct EmbeddingIndexerTests {

    @Test("Indexing and searching returns results")
    func indexAndSearch() async {
        let indexer = EmbeddingIndexer()
        await indexer.buildIndex(from: ListingItem.samples)
        let results = await indexer.findSimilar(to: "coffee shop", topK: 3)

        #expect(!results.isEmpty, "Should return at least one result for 'coffee shop'")
        #expect(results.count <= 3)
    }

    @Test("Empty query returns no results")
    func emptyQuery() async {
        let indexer = EmbeddingIndexer()
        await indexer.buildIndex(from: ListingItem.samples)
        let results = await indexer.findSimilar(to: "", topK: 5)

        #expect(results.isEmpty, "Empty query should return no results")
    }

    @Test("Results are sorted by descending score")
    func resultsSortedByScore() async {
        let indexer = EmbeddingIndexer()
        await indexer.buildIndex(from: ListingItem.samples)
        let results = await indexer.findSimilar(to: "quiet place to read", topK: 5)

        for i in 0..<results.count - 1 {
            #expect(
                results[i].score >= results[i + 1].score,
                "Results should be sorted by descending score"
            )
        }
    }

    @Test("Top result for 'coffee' is cafe-related")
    func topResultRelevance() async {
        let indexer = EmbeddingIndexer()
        await indexer.buildIndex(from: ListingItem.samples)
        let results = await indexer.findSimilar(to: "coffee", topK: 1)

        #expect(!results.isEmpty)
        if let top = results.first {
            #expect(
                top.item.category == "cafe",
                "Top result for 'coffee' should be a cafe, got \(top.item.category)"
            )
        }
    }
}
