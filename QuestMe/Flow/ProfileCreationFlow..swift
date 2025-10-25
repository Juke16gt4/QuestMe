//
//  ProfileCreationFlow.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Flow/ProfileCreationFlow.swift
//
//  🎯 ファイルの目的:
//      Companion のプロフィール作成フローを管理する SwiftUI ビュー。
//      - アバター選択 → 声のスタイル・声色選択 → プロフィール確認・保存の流れ。
//      - AIエンジンは Copilot に固定。
//      - 完了後は ProfileListView に遷移可能。
//
//  🔗 依存:
//      - CompanionAvatar.swift（ロール定義）
//      - VoiceSelectionView.swift（声選択）
//      - CompanionProfile.swift（保存構造）
//      - ProfileSummaryView.swift（確認）
//      - ProfileListView.swift（一覧）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月2日

import SwiftUI

struct ProfileCreationFlow: View {
    @State private var selectedAvatar: CompanionAvatar? = nil
    @State private var completedProfile: CompanionProfile? = nil
    @State private var showList = false

    var body: some View {
        NavigationStack {
            AICharacterSelectionView(selectedAvatar: $selectedAvatar)
                .navigationDestination(isPresented: Binding(
                    get: { selectedAvatar != nil },
                    set: { if !$0 { selectedAvatar = nil } }
                )) {
                    if let avatar = selectedAvatar {
                        VoiceSelectionView(selectedAvatar: avatar) { voice in
                            // ✅ aiEngine を必ず渡す
                            completedProfile = CompanionProfile(
                                name: "マイコンパニオン",
                                avatar: avatar,
                                voice: voice,
                                aiEngine: .copilot   // ← ここを追加
                            )
                        }
                        .navigationDestination(isPresented: Binding(
                            get: { completedProfile != nil },
                            set: { if !$0 { completedProfile = nil } }
                        )) {
                            if let profile = completedProfile {
                                ProfileSummaryView(profile: profile)
                                    .onDisappear { showList = true }
                            }
                        }
                    }
                }
                .navigationDestination(isPresented: $showList) {
                    ProfileListView()
                }
        }
    }
}
