//
//  ChangeLogView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/ChangeLogView.swift
//
//  🎯 ファイルの目的:
//      ChangeLog.sqlite3 に記録された履歴を一覧表示するビュー。
//      - 日時・対象・フィールド・変更前後・理由を明示。
//      - 将来的に復元・フィルター・エクスポートに対応可能。
//
//  🔗 依存:
//      - ChangeLogManager.swift（履歴取得）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月5日

import SwiftUI

struct ChangeLogView: View {
    @State private var logs: [[String: String]] = []

    var body: some View {
        NavigationView {
            List {
                ForEach(logs, id: \.self) { log in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("🕒 \(log["timestamp"] ?? "")")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("📦 \(log["entityType"] ?? "") (\(log["entityId"] ?? ""))")
                            .font(.subheadline)
                        if let field = log["field"], !field.isEmpty {
                            Text("🔧 \(field): \(log["oldValue"] ?? "") → \(log["newValue"] ?? "")")
                        }
                        Text("🎯 理由: \(log["reason"] ?? "")")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("変更履歴")
            .onAppear {
                logs = ChangeLogManager().fetchAll()
            }
        }
    }
}
