//
//  SearchView.swift
//  QuestMe
//

import SwiftUI

struct SearchView: View {
    @State private var query = ""
    @State private var showResult = false

    var body: some View {
        NavigationStack {
            VStack {
                TextField("検索キーワードを入力", text: $query)
                    .textFieldStyle(.roundedBorder)
                    .padding()

                Button("検索") {
                    showResult = true
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .navigationTitle("検索")
            // ✅ 新しい書き方
            .navigationDestination(isPresented: $showResult) {
                SearchResultView(
                    searchContent: query,
                    onRetry: { showResult = false }
                )
            }
        }
    }
}
