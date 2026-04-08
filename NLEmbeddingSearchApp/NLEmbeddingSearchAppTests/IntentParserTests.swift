//
//  IntentParserTests.swift
//  NLEmbeddingSearch
//
//  Created by Preet Singh on 4/8/26.
//

import Testing
@testable import NLEmbeddingSearch

@Suite("IntentParser")
struct IntentParserTests {
    private let parser = IntentParser()

    @Test("Cafe-related query extracts cafe category")
    func cafeCategory() {
        let intent = parser.parse("quiet coffee shop")
        #expect(intent.category == "cafe")
    }

    @Test("Restaurant-related query extracts restaurant category")
    func restaurantCategory() {
        let intent = parser.parse("good food nearby")
        #expect(intent.category == "restaurant")
    }

    @Test("Outdoors-related query extracts outdoors category")
    func outdoorsCategory() {
        let intent = parser.parse("park with benches")
        #expect(intent.category == "outdoors")
    }

    @Test("Unknown query preserves raw query string")
    func unknownQueryPreservesRaw() {
        let intent = parser.parse("something completely unrelated")
        #expect(intent.rawQuery == "something completely unrelated")
    }

    @Test("Keywords are extracted from query")
    func keywordsExtracted() {
        let intent = parser.parse("cozy Italian restaurant")
        #expect(!intent.keywords.isEmpty, "Should extract at least one keyword")
    }
}
