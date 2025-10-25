//
//  SupplementListView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Supplement/SupplementListView.swift
//
//  🎯 ファイルの目的:
//      登録されたサプリメント一覧を表示するビュー。
//      - SupplementManager.shared.supplements を監視。
//      - CompanionOverlay による音声命令（追加・削除）に対応。
//      - 今後は摂取記録や栄養分析との連携も可能。
//
//  🔗 依存:
//      - SupplementManager.swift（保存・削除）
//      - CompanionOverlay.swift（音声連携）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月4日

import SwiftUI

struct SupplementListView: View {
    @ObservedObject var supplementManager = SupplementManager.shared
    
    var body: some View {
        List {
            ForEach(supplementManager.supplements) { supp in
                Text("\(supp.name) \(supp.dosage ?? "")")
            }
            .onDelete { indexSet in
                supplementManager.delete(at: indexSet)
            }
        }
        .navigationTitle("サプリメント一覧")
        .onAppear {
            CompanionOverlay.shared.attach(to: self)
        }
    }
}
