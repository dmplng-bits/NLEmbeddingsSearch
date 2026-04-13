# NLEmbeddingSearch

> On-device semantic search for iOS using Apple's NaturalLanguage framework. Zero server dependency. Sub-50ms latency.

![Swift](https://img.shields.io/badge/Swift-5.9-orange) ![Platform](https://img.shields.io/badge/Platform-iOS%2017+-blue) ![License](https://img.shields.io/badge/License-MIT-green)

## What it does

Type a natural language query and get semantically relevant results ranked by vector similarity. No backend, no API keys, no network calls.

**Example:** Searching "cozy place to work" returns results like "Quiet coffee shop with WiFi" even though they share zero keywords.

## Architecture

```
┌─────────────────────────────────────────────┐
│                  SwiftUI                     │
│   SearchView → ResultCard / EmptyStateView  │
├─────────────────────────────────────────────┤
│              SearchEngine                    │
│  ┌──────────────┐  ┌────────────────────┐   │
│  │ IntentParser  │  │ EmbeddingIndexer   │   │
│  │ (NLTagger)    │  │ (NLEmbedding)      │   │
│  └──────────────┘  └────────────────────┘   │
│           SimilarityScorer                   │
│         (cosine similarity)                  │
├─────────────────────────────────────────────┤
│           Local Data Layer                   │
│         (JSON / SwiftData)                   │
└─────────────────────────────────────────────┘
```

## Key techniques

- **NLEmbedding** — Apple's on-device word embeddings for vector similarity search
- **NLTagger** — POS tagging + named entity recognition for intent extraction
- **Cosine similarity** — Results scored by semantic distance, not keyword match
- **Swift Concurrency** — Actor-isolated indexer with async/await keeps the UI responsive
- **Mean pooling** — Word vectors averaged into sentence-level embeddings as a lightweight baseline

## Quick start

```bash
git clone https://github.com/dmplng-bits/NLEmbeddingSearch.git
cd NLEmbeddingSearch/NLEmbeddingSearchApp
open NLEmbeddingSearchApp.xcodeproj
# Run on iOS 17+ simulator or device
```

## Project structure

```
NLEmbeddingSearch/
├── LICENSE
├── README.md
└── NLEmbeddingSearchApp/
    ├── NLEmbeddingSearchApp.xcodeproj
    ├── NLEmbeddingSearchApp/
    │   ├── NLEmbeddingSearchApp.swift        # App entry point
    │   ├── Views/
    │   │   ├── SearchView.swift              # Main search interface
    │   │   ├── ResultCard.swift              # Individual result cell
    │   │   └── EmptyStateView.swift          # No results / onboarding
    │   ├── Engine/
    │   │   ├── SearchEngine.swift            # Orchestrates search pipeline
    │   │   ├── EmbeddingIndexer.swift        # NLEmbedding vector operations
    │   │   ├── IntentParser.swift            # NLTagger-based intent extraction
    │   │   └── SimilarityScorer.swift        # Cosine similarity computation
    │   ├── Models/
    │   │   └── Models.swift                  # ListingItem, SearchResult, SearchIntent
    │   ├── Data/
    │   │   └── SampleListings.json           # Demo dataset
    │   └── Assets.xcassets/
    └── NLEmbeddingSearchAppTests/
        ├── SimilarityScorerTests.swift
        ├── IntentParserTests.swift
        └── EmbeddingIndexerTests.swift
```

## How the search pipeline works

1. **Intent parsing** — `IntentParser` runs NLTagger on the query to extract nouns, adjectives, and named entities. These are mapped through a keyword-to-category lookup to identify what type of result the user is looking for.

2. **Embedding & indexing** — `EmbeddingIndexer` tokenizes each listing's text, looks up per-word vectors via `NLEmbedding.wordEmbedding`, and averages them into a single sentence vector (mean pooling).

3. **Similarity scoring** — `SimilarityScorer` computes cosine similarity between the query vector and every indexed item, returning the top K matches.

4. **Category boosting** — `SearchEngine` boosts results whose category matches the parsed intent, then re-sorts and returns the final ranked list.

## What I'd improve for production

- Replace mean-pooled word embeddings with `NLEmbedding.sentenceEmbedding` (iOS 17+) or a Core ML sentence transformer for significantly better accuracy
- Swap the keyword-to-category map for a trained text classifier
- Add SwiftData persistence so the index survives app restarts
- Implement incremental indexing for large datasets instead of rebuilding on every launch

## Why this exists

This is a concept version for learning, where keyword search wasn't cutting it for listing discovery. This is a clean, open-source demonstration of the same techniques — NLEmbedding for semantic matching, NLTagger for intent extraction without any proprietary code.

## License

MIT
