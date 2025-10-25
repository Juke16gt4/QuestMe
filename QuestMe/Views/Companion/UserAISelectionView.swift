//
//  UserAISelectionView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/UserAISelectionView.swift
//
//  🎯 ファイルの目的:
//      ユーザーが保存済みのコンパニオンを選択するためのビュー。
//      - ProfileStorage.loadProfiles() により一覧表示。
//      - 選択されたプロフィールに応じて Companion を起動可能。
//      - Picker による選択と詳細表示を提供。
//
//  🔗 依存:
//      - ProfileStorage.swift（保存）
//      - CompanionProfile.swift（モデル）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月1日

import SwiftUI

struct UserAISelectionView: View {
    @State private var profiles: [CompanionProfile] = ProfileStorage.loadProfiles()
    @State private var selectedProfile: CompanionProfile? = nil

    var body: some View {
        VStack {
            Text("コンパニオンを選んでください").font(.title2)

            Picker("コンパニオン", selection: $selectedProfile) {
                ForEach(profiles, id: \.id) { profile in
                    Text(profile.name).tag(Optional(profile))
                }
            }
            .pickerStyle(.wheel)

            if let profile = selectedProfile {
                VStack {
                    Text("選択中: \(profile.name)")
                    Text("アバター: \(profile.avatar.rawValue)")
                    Text("声: \(profile.voice.style.rawValue) × \(profile.voice.tone.rawValue)")
                }
                .padding()
            }
        }
        .onAppear { profiles = ProfileStorage.loadProfiles() }
    }
}
