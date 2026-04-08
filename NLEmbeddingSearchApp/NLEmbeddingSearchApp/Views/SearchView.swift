//
//  SearchView.swift
//  NLEmbeddingSearch
//
//  Created by Preet Singh on 4/8/26.
//

import SwiftUI

/// Main search interface. Type a natural language query and see semantically ranked results.
///
/// The view wires together the search engine and handles the UI lifecycle:
/// sample data loads once on appear, and every keystroke triggers an async search.
struct SearchView: View {
    @StateObject private var engine = SearchEngine()
    @State private var query = ""
    @State private var hasLoaded = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar

                if engine.isSearching {
                    ProgressView()
                        .padding(.top, 40)
                    Spacer()
                } else if engine.results.isEmpty && !query.isEmpty {
                    EmptyStateView(query: query)
                    Spacer()
                } else {
                    resultsList
                }
            }
            .navigationTitle("Semantic Search")
            .task {
                guard !hasLoaded else { return }
                hasLoaded = true
                await loadSampleData()
            }
        }
    }

    // MARK: - Subviews

    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Try: cozy place to work", text: $query)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
                .onChange(of: query) { _, newValue in
                    Task { await engine.search(query: newValue) }
                }

            if !query.isEmpty {
                Button { query = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var resultsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(engine.results) { result in
                    ResultCard(result: result)
                }
            }
            .padding()
        }
    }

    // MARK: - Data Loading

    /// Loads sample listings from the bundled JSON file.
    /// Falls back to an empty array if the file is missing or malformed.
    private func loadSampleData() async {
        let listings: [ListingItem]

        if let url = Bundle.main.url(forResource: "SampleListings", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            listings = (try? JSONDecoder().decode([ListingItem].self, from: data)) ?? []
        } else {
            // Fallback: hardcoded samples for playground / preview use
            listings = ListingItem.samples
        }

        await engine.loadListings(listings)
    }
}

#Preview {
    SearchView()
}
