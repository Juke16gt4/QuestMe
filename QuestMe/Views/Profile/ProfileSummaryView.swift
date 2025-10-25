//
//  ProfileSummaryView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Profile/ProfileSummaryView.swift
//
//  🎯 ファイルの目的:
//      CompanionProfile の内容を確認し、保存するビュー。
//      - 保存成功／失敗に応じてアラート表示。
//      - 保存枠が最大数（5件）を超えた場合は保存不可。
//      - ProfileStorage により永続化。
//
//  🔗 依存:
//      - ProfileStorage.swift（保存）
//      - CompanionProfile.swift（モデル）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月1日

import SwiftUI

struct ProfileSummaryView: View {
    let profile: CompanionProfile
    @State private var showSaveError = false
    @State private var saveSuccess = false

    var body: some View {
        VStack(spacing: 20) {
            Text("プロフィール完成！")
                .font(.title)

            Text("アバター: \(profile.avatar.rawValue)")
            Text("声スタイル: \(profile.voice.style.rawValue)")
            Text("声色: \(profile.voice.tone.rawValue)")

            Spacer()

            Button("このコンパニオンを保存") {
                let success = ProfileStorage.saveProfile(profile)
                if success {
                    saveSuccess = true
                } else {
                    showSaveError = true
                }
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .padding()
        .navigationTitle("プロフィール確認")
        .alert("保存できません", isPresented: $showSaveError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("保存枠がいっぱいです。不要なコンパニオンを削除してから保存してください。")
        }
        .alert("保存しました！", isPresented: $saveSuccess) {
            Button("OK", role: .cancel) {}
        }
    }
}
