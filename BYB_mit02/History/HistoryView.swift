//
//  HistoryView.swift
//  BYB_mit02
//
//  Created by Vituruch Sinthusate on 7/1/2569 BE.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var store: HistoryStore

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.items) { r in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(r.level == .low ? "SAFE" : "NOT SAFE").bold()
                        Text("Type: \(r.type.rawValue)")
                            .font(.subheadline)
                        Text(r.input)
                            .lineLimit(2)
                            .font(.caption)
                        Text(r.timestamp.formatted())
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("History")
            .toolbar {
                Button("Clear") { store.clear() }
            }
        }
    }
}
