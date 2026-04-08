//
//  ResultCard.swift
//  NLEmbeddingSearch
//
//  Created by Preet Singh on 4/8/26.
//

import SwiftUI

/// Displays a single search result with its title, description, similarity score, and metadata.
///
/// The score badge shows how semantically close the result is to the query —
/// 85% means the embedding vectors are highly aligned, even if the words differ.
struct ResultCard: View {
    let result: SearchResult

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(result.item.title)
                    .font(.headline)
                Spacer()
                scoreBadge
            }

            Text(result.item.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            metadata
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    // MARK: - Subviews

    private var scoreBadge: some View {
        Text(String(format: "%.0f%%", result.score * 100))
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.ultraThinMaterial, in: Capsule())
    }

    private var metadata: some View {
        HStack(spacing: 12) {
            Label(result.item.category.capitalized, systemImage: "tag")
            Label(String(format: "%.1f", result.item.rating), systemImage: "star.fill")
        }
        .font(.caption)
        .foregroundStyle(.tertiary)
    }
}
