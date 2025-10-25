//
//  CompanionHomeView.swift
//  QuestMe
//
//  📂 格納場所（動的）:
//      QuestMe/Companion/Home/{profile.id}/CompanionHomeView.swift
//
//  🎯 ファイルの目的:
//      認証後に表示されるコンパニオンのホーム画面。
//      - CompanionProfile の内容を表示。
//      - ロール・声のスタイル・AIエンジンなどを確認可能。
//      - LocalizationManager による多言語対応（UI表示）
//
//  🔗 依存:
//      - CompanionProfile.swift
//      - LocalizationManager.swift（@EnvironmentObject）
//
//  👤 製作者: 津村 淳一
//  📅 修正日: 2025年10月16日
//

import SwiftUI

struct CompanionHomeView: View {
    let profile: CompanionProfile
    @EnvironmentObject var locale: LocalizationManager

    var body: some View {
        VStack(spacing: 20) {
            Text(locale.localized("companion_home_welcome", ["name": profile.name]))
                .font(.largeTitle)
                .bold()

            Text(locale.localized("companion_avatar_description", ["avatar": profile.avatar.rawValue]))
                .font(.title2)

            Text(locale.localized("companion_home_voice_style", ["style": profile.voice.style.rawValue]))
            Text(locale.localized("companion_voice_tone", ["tone": profile.voice.tone.rawValue]))
            Text(locale.localized("companion_voice_speed", ["speed": profile.voice.speed.rawValue]))

            Text(locale.localized("companion_home_ai_engine", ["engine": profile.aiEngine.displayName]))
                .foregroundColor(.secondary)

            Text("プロフィールID: \(profile.id.uuidString)")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .padding()
        .navigationTitle("Companion Home")
    }
}
