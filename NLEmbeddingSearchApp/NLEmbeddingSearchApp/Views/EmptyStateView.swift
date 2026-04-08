//
//  EmptyStateView.swift
//  NLEmbeddingSearch
//
//  Created by Preet Singh on 4/8/26.
//

import SwiftUI

/// Shown when a search query returns no semantically similar results.
struct EmptyStateView: View {
    let query: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
                .foregroundStyle(.tertiary)

            Text("No results for \"\(query)\"")
                .font(.headline)

            Text("Try different words — semantic search finds meaning, not exact matches")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

#Preview {
    EmptyStateView(query: "something obscure")
}
