//
//  CompanionIntroView.swift
//  QuestMe
//
//  Created by Junichi Tsumura on 2025/10/02.
//  このビューは選択されたコンパニオンの紹介画面です。
//  - プロフィール情報（名前、アバター、声、AIエンジン）を表示
//  - ユーザーに「コンパニオン」としての存在を印象づける
//

import SwiftUI

struct CompanionIntroView: View {
    let profile: CompanionProfile

    var body: some View {
        VStack(spacing: 20) {
            // アバター表示
            Text("アバター: \(profile.avatar.rawValue)")
                .font(.title2)

            // 声のスタイル＋声色
            Text("声: \(profile.voice.style.rawValue) × \(profile.voice.tone.rawValue)")
                .font(.headline)

            // AIエンジン（必須プロパティなので Optional unwrap 不要）
            Text("AIエンジン: \(profile.aiEngine.rawValue)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Divider()

            // 紹介文
            Text(introductionText(for: profile))
                .padding()
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding()
        .navigationTitle(profile.name)
    }

    // MARK: - 紹介文生成
    private func introductionText(for profile: CompanionProfile) -> String {
        return """
        私は \(profile.name)。
        あなたに寄り添うコンパニオンとして、\(profile.avatar.rawValue) の新たな経験と知恵と
        \(profile.voice.style.rawValue) な声で支えます。
        私の力の源は \(profile.aiEngine.rawValue)。
        あなた自身に秘められた経験の旅のお手伝いをさせていただきます！
        """
    }
}
