//
//  QuestMeAppFlow.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Flow/QuestMeAppFlow.swift
//
//  🎯 ファイルの目的:
//      初回案内から常駐ボタン・拡大表示・設定画面までの一連の遷移を管理。
//      - 初回のみ CompanionWelcomeView を表示
//      - その後 CompanionSetupView → QuestMeLaunchButtonView
//      - 拡大表示から設定画面へ自然に遷移
//

import SwiftUI

struct QuestMeAppFlow: View {
    @AppStorage("questme.hasShownLaunchButtonIntro") private var hasShownIntro: Bool = false
    @State private var profile: CompanionProfile = ProfileStorage.loadProfiles().first ?? CompanionProfile.defaultProfile()

    var body: some View {
        NavigationStack {
            if !hasShownIntro {
                // ✅ 初回案内
                CompanionWelcomeView(language: .japanese)
            } else if !ProfileStorage.hasProfile() {
                // ✅ 初回セットアップ
                CompanionSetupView()
            } else {
                // ✅ メイン画面（常駐ボタン付き）
                CockpitView()
                    .overlay(QuestMeLaunchButtonView())
            }
        }
    }
}
