//
//  CompanionSectionView.swift
//  QuestMe
//
//  📂 格納場所:
//      QuestMe/Views/Shared/CompanionSectionView.swift
//
//  🎯 ファイルの目的:
//      各種記録・履歴・スコア表示に使う汎用セクションビュー。
//      - SwiftUIの型推論曖昧性を防ぐため、AnyViewで固定。
//      - MonthlyCompanionReport.swift や DayInsightView.swift などで使用。

import SwiftUI

struct CompanionSectionView: View {
    let title: String
    let content: AnyView

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
