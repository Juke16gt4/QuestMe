//
//  MedicationListView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Medication/MedicationListView.swift
//
//  🎯 ファイルの目的:
//      登録された薬剤一覧を表示するビュー。
//      - CompanionOverlay による音声操作（削除・追加）に対応。
//      - MedicationManager.shared.medications を監視。
//      - 音声命令に応じて対象薬剤をハイライト可能（今後拡張）。
//
//  🔗 依存:
//      - MedicationManager.swift（保存・削除）
//      - CompanionOverlay.swift（音声連携）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月4日

import SwiftUI

struct MedicationListView: View {
    @ObservedObject var medicationManager = MedicationManager.shared
    
    var body: some View {
        List {
            ForEach(medicationManager.medications) { med in
                Text(med.name)
            }
            .onDelete { indexSet in
                medicationManager.delete(at: indexSet)
            }
        }
        .navigationTitle("おくすり一覧")
        .onAppear {
            CompanionOverlay.shared.attach(to: self)
        }
    }
}
