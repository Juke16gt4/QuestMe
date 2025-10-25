//
//  CompanionExpandedView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Companion/CompanionExpandedView.swift
//
//  🎯 目的:
//      QuestMeコンパニオンの拡大表示ビュー。
//      - 表情やログを表示
//      - 「閉じる」ボタンで最小化状態に戻る
//
//  🔗 連動:
//      - QuestMeLaunchButtonView.swift（起動状態制御）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月23
//

import SwiftUI

struct CompanionExpandedView: View {
    @Binding var isCompanionActive: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text("🧠 コンパニオン拡大表示")
                .font(.title)

            // 表情やログなどの表示（省略）

            Button("閉じる（最小化に戻る）") {
                isCompanionActive = false
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
