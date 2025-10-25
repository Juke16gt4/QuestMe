//
//  CompanionManager.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/CompanionManager.swift
//
//  🎯 ファイルの目的:
//      CompanionProfile の一覧と管理を行うビュー。
//      - 生成・保存・削除に対応。
//      - aiEngine は enum で指定。
//      - CompanionProfile の構造に準拠。
//
//  🔗 依存:
//      - CompanionProfile.swift（モデル）
//      - VoiceProfile.swift（声）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月2日

import SwiftUI

struct CompanionManager: View {
    @State private var companions: [CompanionProfile] = []

    var body: some View {
        NavigationStack {
            List {
                ForEach(companions) { profile in
                    VStack(alignment: .leading) {
                        Text(profile.name)
                            .font(.headline)
                        Text("アバター: \(profile.avatar.rawValue)")
                        Text("声: \(profile.voice.style.rawValue) × \(profile.voice.tone.rawValue)")
                        Text("AIエンジン: \(profile.aiEngine.rawValue)")
                        Text("作成日: \(profile.createdAt.formatted(date: .abbreviated, time: .shortened))")
                    }
                }
                .onDelete(perform: deleteCompanion)
            }
            .navigationTitle("コンパニオン管理")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        addCompanion()
                    }
                }
            }
        }
    }

    // MARK: - コンパニオン追加
    private func addCompanion() {
        let newProfile = CompanionProfile(
            name: "新しいコンパニオン",
            avatar: .mentor,
            voice: VoiceProfile(style: .calm, tone: .neutral),
            aiEngine: .copilot // ✅ String ではなく enum case
        )
        companions.append(newProfile)
    }

    // MARK: - コンパニオン削除
    private func deleteCompanion(at offsets: IndexSet) {
        companions.remove(atOffsets: offsets)
    }
}
