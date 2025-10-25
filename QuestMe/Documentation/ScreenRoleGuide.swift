//
//  ScreenRoleGuide.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Documentation/ScreenRoleGuide.swift
//
//  🎯 ファイルの目的:
//      Companion が画面ごとの役割を説明するための文言ガイド。
//      - 各画面（ScreenID）に対応する説明文を定義。
//      - CompanionNarrationEngine.swift から参照され、音声解説に使用。
//      - UI上で「役割案内」ボタンから呼び出される。
//
//  🔗 依存:
//      - CompanionNarrationEngine.swift（音声解説）
//      - CompanionNavigationButton.swift（UI連携）
//      - SwiftUI（表示）
//
//  👤 製作者: 津村 淳一
//  📅 制作日: 2025年10月6日

import SwiftUI

struct ScreenRoleGuide: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    ScreenRoleGuide()
}
