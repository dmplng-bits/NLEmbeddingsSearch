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

## Building from source

### Prerequisites

| Requirement | Version | Notes |
|---|---|---|
| macOS | 14 Sonoma or later | Needed to run Xcode 15+ |
| Xcode | 15.0 or later | Ships with the Swift 5.9 toolchain and iOS 17 SDK |
| iOS Deployment Target | 17.0 | `NLEmbedding` and Swift Testing both require iOS 17+ |
| Apple Developer account | optional | Free account is fine. Only needed to run on a physical device |

There are no third‑party dependencies. No CocoaPods, no Swift Package Manager packages, no API keys, no network calls at runtime.

### Clone and open

```bash
git clone https://github.com/dmplng-bits/NLEmbeddingSearch.git
cd NLEmbeddingSearch/NLEmbeddingSearchApp
open NLEmbeddingSearchApp.xcodeproj
```

### Run in Xcode

1. Wait for indexing to finish after the first open.
2. In the toolbar, select the `NLEmbeddingSearchApp` scheme.
3. Pick a destination — any iPhone simulator on iOS 17+ works, or plug in your device.
4. Press **⌘R** (Product → Run).
5. The app launches straight into `SearchView`. Type a natural language query and watch the results re‑rank as you type.

### Running tests

The test suite uses the new Swift Testing framework (`import Testing`, `@Suite`, `@Test`, `#expect`), not XCTest.

- **In Xcode:** press **⌘U** or open the Test Navigator (⌘6) and hit the Run All button.
- **From the command line:**

```bash
cd NLEmbeddingSearchApp
xcodebuild \
  -project NLEmbeddingSearchApp.xcodeproj \
  -scheme NLEmbeddingSearchApp \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  test
```

### Running on a physical device (signing)

First time on a real iPhone:

1. Select the project in the navigator → `NLEmbeddingSearchApp` target → **Signing & Capabilities**.
2. Change the **Team** dropdown to your Apple ID (free personal team is fine).
3. Change the **Bundle Identifier** to something unique, e.g. `com.yourname.NLEmbeddingSearchApp`.
4. Build and run. On the phone, trust the certificate under **Settings → General → VPN & Device Management**.

### Building from the command line

```bash
cd NLEmbeddingSearchApp
xcodebuild \
  -project NLEmbeddingSearchApp.xcodeproj \
  -scheme NLEmbeddingSearchApp \
  -destination 'platform=iOS Simulator,name=iPhone 15' \
  build
```

### Troubleshooting

| Symptom | Fix |
|---|---|
| `NLEmbedding.wordEmbedding(for:)` returns nil | The language isn't supported or the model hasn't downloaded. Run on a simulator with full internet the first time. |
| Build fails with `cannot find 'Testing' in scope` | You're on Xcode 14. Upgrade to Xcode 15 or later — Swift Testing ships with 15.0+. |
| `Bundle identifier is not available` when signing | Change the bundle ID to something unique like `com.<yourname>.NLEmbeddingSearchApp` |
| Search returns empty results | Check that `SampleListings.json` is present in the target's Copy Bundle Resources build phase |

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
