//
//  ProfileListView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Profile/ProfileListView.swift
//
//  🎯 ファイルの目的:
//      保存された CompanionProfile 一覧を表示・削除するビュー。
//      - swipeActions により削除操作を提供。
//      - ProfileStorage から読み込み・更新。
//      - 削除確認アラートを表示し、ユーザーの意志を尊重。
//
//  🔗 依存:
//      - ProfileStorage.swift（保存・削除）
//      - CompanionProfile.swift（モデル）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月4日

import SwiftUI

struct ProfileListView: View {
    @State private var profiles: [CompanionProfile] = ProfileStorage.loadProfiles()
    @State private var profileToDelete: CompanionProfile? = nil
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(Array(profiles.enumerated()), id: \.element.id) { index, profile in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(profile.name).font(.headline)
                        Text("アバター: \(profile.avatar.rawValue)")
                        Text("声: \(profile.voice.style.rawValue) × \(profile.voice.tone.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            profileToDelete = profile
                            showDeleteAlert = true
                        } label: {
                            Label("削除", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("保存されたコンパニオン")
            .alert("削除の確認", isPresented: $showDeleteAlert, presenting: profileToDelete) { profile in
                Button("削除", role: .destructive) {
                    if let index = profiles.firstIndex(of: profile) {
                        ProfileStorage.deleteProfile(at: index)
                        profiles = ProfileStorage.loadProfiles()
                    }
                }
                Button("キャンセル", role: .cancel) {}
            } message: { profile in
                Text("""
                以下のプロフィールを削除しますか？

                名前: \(profile.name)
                アバター: \(profile.avatar.rawValue)
                声: \(profile.voice.style.rawValue) × \(profile.voice.tone.rawValue)
                """)
            }
        }
    }
}
