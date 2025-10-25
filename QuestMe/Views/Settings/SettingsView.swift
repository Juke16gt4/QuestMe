//
//  SettingsView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Settings/SettingsView.swift
//
//  🎯 ファイルの目的:
//      登録アプリ終了後に QuestMe を再表示するかどうかを選択する設定ビュー。
//      - AppStorage により永続化。
//      - Companion の起動制御に使用される予定。
//
//  🔗 依存:
//      - AppStorage（永続化）
//      - CockpitView.swift（起動後挙動）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月4日

import SwiftUI

struct SettingsView: View {
    @AppStorage("questme.autoReturnAfterAppLaunch") var autoReturn: Bool = true

    var body: some View {
        Form {
            Section(header: Text("アプリ起動後の動作")) {
                Toggle("登録アプリ終了後にQuestMeを再表示する", isOn: $autoReturn)
            }
        }
        .navigationTitle("設定")
    }
}
